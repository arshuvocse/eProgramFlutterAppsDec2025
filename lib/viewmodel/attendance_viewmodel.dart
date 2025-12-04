import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../data/database_helper.dart';
import '../config/api_config.dart';
import '../utils/app_snackbar.dart';

class AttendanceViewModel extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();

  // Map & Location
  GoogleMapController? mapController;
  Position? _currentPos;
  Position? get currentPos => _currentPos;

  LatLng? _center;
  LatLng? get center => _center;

  Set<Marker> _markers = {};
  Set<Marker> get markers => _markers;

  // UI state
  bool _busy = false;
  bool get busy => _busy;

  bool _punchedIn = false;
  bool get punchedIn => _punchedIn;

  DateTime? _punchedAt;
  DateTime? get punchedAt => _punchedAt;

  bool _punchedOut = false;
  bool get punchedOut => _punchedOut;

  DateTime? _punchedOutAt;
  DateTime? get punchedOutAt => _punchedOutAt;

  String _remarks = '';
  String get remarks => _remarks;
  void setRemarks(String v) {
    _remarks = v;
  }

  File? _photoFile;
  File? get photoFile => _photoFile;

  final ImagePicker _picker = ImagePicker();

  // status message for location service
  String? _statusMessage;
  bool _statusVisible = false;
  Timer? _statusTimer;

  // transient snack messages (e.g., API errors)
  String? _snackMessage;
  SnackTone _snackTone = SnackTone.success;

  String? get statusMessage => _statusMessage;
  bool get statusVisible => _statusVisible;
  String? get snackMessage => _snackMessage;
  SnackTone get snackTone => _snackTone;

  // ========== Init ==========
  Future<void> init() async {
    await _ensureLocation();
    await _getCurrentLocation();
    await _loadPunchState();
    _updateMarker();
    notifyListeners();
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (_center != null) {
      mapController!.animateCamera(CameraUpdate.newLatLngZoom(_center!, 16));
    }
  }

  // ========== Actions ==========
  Future<void> refreshLocation() async {
    await _getCurrentLocation();
    _updateMarker();
    if (_center != null && mapController != null) {
      mapController!.animateCamera(CameraUpdate.newLatLng(_center!));
    }
    notifyListeners();
  }

  Future<void> punchIn() async {
    if (_busy) return;
    _setBusy(true);

    try {
      await _getCurrentLocation();
      final XFile? shot = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 85,
      );
      if (shot == null) {
        return; // cancelled
      }
      _photoFile = File(shot.path);

      final success = await _sendPunch(isPunchIn: true);
      if (success) {
        _punchedIn = true;
        _punchedAt = DateTime.now();
        _snackMessage = 'Punch In successful';
        _snackTone = SnackTone.success;
        notifyListeners();
        await _loadPunchState(); // refresh flags from server after submit
      }

    } catch (_) {
      // ignore or capture
    } finally {
      _setBusy(false);
    }
  }

  Future<void> punchOut() async {
    if (_busy || !_punchedIn || _punchedOut) return;
    _setBusy(true);

    try {
      await _getCurrentLocation();
      final XFile? shot = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 85,
      );
      if (shot == null) {
        return; // cancelled
      }
      _photoFile = File(shot.path);

      final success = await _sendPunch(isPunchIn: false);
      if (success) {
        _punchedOut = true;
        _punchedOutAt = DateTime.now();
        _snackMessage = 'Punch Out successful';
        _snackTone = SnackTone.success;
        notifyListeners();
        await _loadPunchState(); // refresh flags from server after submit
      }
    } catch (_) {
      // ignore or capture
    } finally {
      _setBusy(false);
    }
  }

  // ========== Helpers ==========
  Future<void> _ensureLocation() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      _showStatusMessage('Location service is turned off. Please enable GPS to record attendance.');
      return;
    }

    LocationPermission p = await Geolocator.checkPermission();
    if (p == LocationPermission.denied) {
      p = await Geolocator.requestPermission();
    }
    if (p == LocationPermission.deniedForever || p == LocationPermission.denied) {
      _showStatusMessage('Location permission is required. Please allow access and try again.');
      return;
    }

    hideStatusMessage();
  }

  Future<void> _getCurrentLocation() async {
    try {
      _currentPos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      _center = LatLng(_currentPos!.latitude, _currentPos!.longitude);
      hideStatusMessage();
    } catch (_) {
      _showStatusMessage('Unable to read your location. Please enable GPS and try again.');
    }
  }

  void _updateMarker() {
    if (_center == null) return;
    _markers = {
      Marker(
        markerId: const MarkerId('me'),
        position: _center!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta),
      )
    };
  }

  void _setBusy(bool v) {
    _busy = v;
    notifyListeners();
  }

  Future<void> _loadPunchState() async {
    try {
      final empInfoId = await _db.getEmpInfoId();
      if (empInfoId == null || empInfoId <= 0) return;

      final uri = Uri.parse(ApiConfig.punchInfo)
          .replace(queryParameters: {'EmpInfoId': empInfoId.toString()});

      // Align with working curl: POST with query param, empty body.
      final res = await http.post(uri).timeout(const Duration(seconds: 20));

      debugPrint('GetPunchInOutInfo POST $uri -> ${res.statusCode} ${res.body}');
      if (res.statusCode != 200) return;

      final decoded = jsonDecode(res.body);
      if (decoded is! Map<String, dynamic>) return;

      final punchInFlag = (decoded['punchInBtn'] ?? '').toString().trim().toUpperCase();
      final punchOutFlag = (decoded['punchOUTBtn'] ?? decoded['punchOutBtn'] ?? '').toString().trim().toUpperCase();

      // Server contract: ON => button is available to press, OFF => action already completed.
      final showPunchIn = punchInFlag == 'ON';
      final showPunchOut = punchOutFlag == 'ON';

      if (!showPunchIn && !showPunchOut) {
        // Both OFF => both actions already done.
        _punchedIn = true;
        _punchedOut = true;
      } else {
        _punchedIn = !showPunchIn;   // if punch-in button is OFF, user already punched in
        _punchedOut = !showPunchOut; // if punch-out button is OFF, user already punched out
      }

      debugPrint('Punch state mapped -> punchedIn=$_punchedIn punchedOut=$_punchedOut');

      notifyListeners();
    } catch (_) {
      // Fail silently to avoid breaking UI; button defaults remain
    }
  }

  void hideStatusMessage() {
    _statusTimer?.cancel();
    if (!_statusVisible && _statusMessage == null) return;
    _statusVisible = false;
    _statusMessage = null;
    notifyListeners();
  }

  void _showStatusMessage(String message) {
    _statusTimer?.cancel();
    _statusMessage = message;
    _statusVisible = true;
    notifyListeners();
    _statusTimer = Timer(const Duration(seconds: 4), () {
      _statusVisible = false;
      _statusMessage = null;
      notifyListeners();
    });
  }

  void consumeSnackMessage() {
    if (_snackMessage == null) return;
    _snackMessage = null;
    _snackTone = SnackTone.success;
  }

  Future<bool> _sendPunch({required bool isPunchIn}) async {
    try {
      final empInfoId = await _db.getEmpInfoId();
      if (empInfoId == null || empInfoId <= 0) return false;

      final now = DateTime.now();
      final timeString = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      final lat = _currentPos?.latitude.toString() ?? '';
      final lng = _currentPos?.longitude.toString() ?? '';
      final imgBase64 = _photoFile != null ? base64Encode(await _photoFile!.readAsBytes()) : '';

      final payload = {
        'attendanceId': 0,
        'empInfoId': empInfoId,
        'punchInTime': timeString,
        'pInLat': lat,
        'pInLog': lng,
        'pOutRemarks': _remarks,
        'attendanceDate': now.toUtc().toIso8601String(),
        // Use attType 1 for punch in, 2 for punch out (so backend can distinguish).
        'attType': isPunchIn ? 1 : 2,
        'attAddress': 'Lat $lat, Lng $lng',
        'attImg': imgBase64,
      };

      final logPayload = Map<String, dynamic>.from(payload);
      logPayload['attImg'] = 'base64_length=${imgBase64.length}';
      debugPrint('SavePunch request -> $logPayload');

      final res = await http
          .post(
            Uri.parse(ApiConfig.savePunch),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 20));

      debugPrint('SavePunch response ${res.statusCode} ${res.body}');

      if (res.statusCode < 200 || res.statusCode >= 300) {
        _snackMessage = 'Punch failed (${res.statusCode}). Please try again.';
        _snackTone = SnackTone.error;
        notifyListeners();
        return false;
      }

      final decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic>) {
        final status = decoded['status'];
        if (status is int && status != 200) {
          final msg = (decoded['message'] ?? 'Punch failed').toString();
          _snackMessage = msg;
          _snackTone = SnackTone.error;
          notifyListeners();
          return false;
        }
        if (status is String && status != '200') {
          final msg = (decoded['message'] ?? 'Punch failed').toString();
          _snackMessage = msg;
          _snackTone = SnackTone.error;
          notifyListeners();
          return false;
        }
      }
      return true;
    } catch (_) {
      _snackMessage = 'Punch failed. Please check your connection and try again.';
      _snackTone = SnackTone.error;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    mapController?.dispose();
    super.dispose();
  }
}
