import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:e_program_apps/data/database_helper.dart';
import '../config/api_config.dart';

/// Handles periodic location collection and posting it to the API
/// both in foreground and via a lightweight background service.
@pragma('vm:entry-point')
class LocationTrackingService {
  LocationTrackingService._internal();
  static final LocationTrackingService _instance = LocationTrackingService._internal();
  factory LocationTrackingService() => _instance;

  static const Duration _interval = Duration(minutes: 1);

  Timer? _foregroundTimer;
  bool _isConfigured = false;
  final DatabaseHelper _db = DatabaseHelper();
  bool _isSyncingOffline = false;
  int? _userId;

  Future<void> init() async {
    if (_shouldSkipPlatform) return;
    await _configureBackgroundService();
    await _ensurePermissions();
  }

  Future<void> start() async {
    if (_shouldSkipPlatform) return;
    await _ensurePermissions();
    await FlutterBackgroundService().startService();
    _startForegroundTimer();
  }

  Future<void> stop() async {
    _foregroundTimer?.cancel();
    FlutterBackgroundService().invoke('stopService');
  }

  Future<void> _configureBackgroundService() async {
    if (_isConfigured) return;
    _isConfigured = true;

    await FlutterBackgroundService().configure(
      androidConfiguration: AndroidConfiguration(
        onStart: _onStart,
        autoStart: false,
        isForegroundMode: true,
        initialNotificationTitle: 'Location tracking active',
        initialNotificationContent: 'Sharing your position every minute',
        foregroundServiceNotificationId: 991,
        foregroundServiceTypes: [
          AndroidForegroundType.location,
        ],
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: _onStart,
        onBackground: _onIosBackground,
      ),
    );
  }

  void _startForegroundTimer() {
    _foregroundTimer?.cancel();
    _foregroundTimer = Timer.periodic(_interval, (_) => _sendLocationUpdate());
    unawaited(_sendLocationUpdate()); // kick off immediately
  }

  static bool get _shouldSkipPlatform =>
      kIsWeb || !(Platform.isAndroid || Platform.isIOS);

  Future<void> _sendLocationUpdate() async {
    final userId = await _getUserId();
    if (userId <= 0) {
      debugPrint('Location post skipped: no userId found.');
      return;
    }
    final position = await _getPosition();
    if (position == null) return;

    final now = DateTime.now();
    final timeString =
      '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

    final payload = {
      'userId': userId,
      'latValue': position.latitude.toStringAsFixed(6),
      'longValue': position.longitude.toStringAsFixed(6),
      'addressName':
          'Lat ${position.latitude.toStringAsFixed(5)}, Lng ${position.longitude.toStringAsFixed(5)}',
      'time': timeString,
      'trackDate': now.toIso8601String(),
    };

    final connected = await _hasConnectivity();

    try {
      if (!connected) {
        await _storeOffline(payload);
        return;
      }

      debugPrint('Posting location payload: ${jsonEncode(payload)}');
      final response = await http.post(
        Uri.parse(ApiConfig.saveUserLocationTracking),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      final body = response.body;
      debugPrint('Location post response (${response.statusCode}): $body');
      if (_isResponseSuccess(response.statusCode, body)) {
        debugPrint('Location post success');
        await _syncOfflineQueue();
      } else {
        debugPrint('Location post failed: ${response.statusCode} $body');
        await _storeOffline(payload);
      }
    } catch (e, st) {
      debugPrint('Location post error: $e');
      debugPrint('$st');
      await _storeOffline(payload);
    }
  }

  static Future<bool> _ensurePermissions() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      return false;
    }

    return true;
  }

  static Future<Position?> _getPosition() async {
    final permitted = await _ensurePermissions();
    if (!permitted) return null;

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } catch (e, st) {
      debugPrint('Location fetch failed: $e');
      debugPrint('$st');
      return null;
    }
  }

  @pragma('vm:entry-point')
  static void _onStart(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    final tracker = LocationTrackingService();

    if (service is AndroidServiceInstance) {
      service.setAsForegroundService();
      service.setForegroundNotificationInfo(
        title: 'Location tracking active',
        content: 'Sharing your position every minute',
      );
    }

    service.on('stopService').listen((_) {
      service.stopSelf();
    });

    Timer.periodic(_interval, (_) => tracker._sendLocationUpdate());
    unawaited(tracker._sendLocationUpdate());
  }

  @pragma('vm:entry-point')
  static Future<bool> _onIosBackground(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();
    return true;
  }

  static Future<bool> _hasConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    return result.contains(ConnectivityResult.mobile) ||
        result.contains(ConnectivityResult.wifi) ||
        result.contains(ConnectivityResult.ethernet);
  }

  Future<void> _storeOffline(Map<String, dynamic> payload) async {
    try {
      final userIdRaw = payload['userId'];
      final userId = userIdRaw is int ? userIdRaw : int.tryParse('$userIdRaw') ?? await _getUserId();
      await _db.insertOfflineLocation(
        // Reuse existing column to avoid a schema change; value now represents userId.
        empInfoId: userId,
        latValue: payload['latValue']?.toString() ?? '',
        longValue: payload['longValue']?.toString() ?? '',
        addressName: payload['addressName']?.toString() ?? '',
        timeValue: payload['time']?.toString() ?? '',
        trackDate: payload['trackDate']?.toString() ?? '',
      );
      debugPrint('Stored offline location');
    } catch (e, st) {
      debugPrint('Failed to store offline location: $e');
      debugPrint('$st');
    }
  }

  Future<void> _syncOfflineQueue() async {
    if (_isSyncingOffline) return;
    if (!await _hasConnectivity()) return;
    _isSyncingOffline = true;
    try {
      final pending = await _db.getOfflineLocations(limit: 50);
      for (final row in pending) {
        final payload = {
          'userId': row['emp_info_id'] ?? await _getUserId(),
          'latValue': row['lat_value'] ?? '',
          'longValue': row['long_value'] ?? '',
          'addressName': row['address_name'] ?? '',
          'time': row['time_value'] ?? '',
          'trackDate': row['track_date'] ?? '',
        };
        try {
          final response = await http.post(
            Uri.parse(ApiConfig.saveUserLocationTracking),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          );
          if (_isResponseSuccess(response.statusCode, response.body)) {
            await _db.deleteOfflineLocation(row['id'] as int);
          } else {
            debugPrint('Retry post failed (${response.statusCode}): ${response.body}');
            break;
          }
        } catch (e, st) {
          debugPrint('Retry post error: $e');
          debugPrint('$st');
          break;
        }
      }
    } finally {
      _isSyncingOffline = false;
    }
  }

  Future<int> _getUserId() async {
    if (_userId != null && _userId! > 0) return _userId!;
    final stored = await _db.getUserId();
    if (stored != null && stored > 0) {
      _userId = stored;
      return stored;
    }
    _userId = 0; // keep trying on next calls
    return 0;
  }

  bool _isResponseSuccess(int statusCode, String body) {
    if (statusCode < 200 || statusCode >= 300) return false;
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final status = decoded['status'];
        if (status is int && status != 200) return false;
        if (status is String && status != '200') return false;
      }
    } catch (_) {
      // Ignore JSON parse errors; rely on HTTP status only.
    }
    return true;
  }
}
