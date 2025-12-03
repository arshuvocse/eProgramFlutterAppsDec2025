import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

class AttendanceViewModel extends ChangeNotifier {
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

  String? get statusMessage => _statusMessage;
  bool get statusVisible => _statusVisible;

  // ========== Init ==========
  Future<void> init() async {
    await _ensureLocation();
    await _getCurrentLocation();
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
      // extra: update location at punch
      await _getCurrentLocation();
      // open front camera
      final XFile? shot = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 85,
      );
      if (shot == null) {
        _setBusy(false);
        return; // cancelled
      }
      _photoFile = File(shot.path);
      _punchedIn = true;
      _punchedAt = DateTime.now();
      notifyListeners();

      // TODO: এখানে আপনার API কল করুন
      // await repo.punchIn(file: _photoFile!, lat: ..., lon: ..., remarks: _remarks, time: _punchedAt!)

    } catch (_) {
      // you may capture error message if needed
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
        _setBusy(false);
        return; // cancelled
      }
      _photoFile = File(shot.path);
      _punchedOut = true;
      _punchedOutAt = DateTime.now();
      notifyListeners();

      // TODO: API: repo.punchOut(...)
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

  @override
  void dispose() {
    _statusTimer?.cancel();
    mapController?.dispose();
    super.dispose();
  }
}
