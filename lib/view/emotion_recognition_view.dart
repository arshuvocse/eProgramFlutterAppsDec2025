import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class EmotionRecognitionView extends StatefulWidget {
  const EmotionRecognitionView({super.key});

  @override
  State<EmotionRecognitionView> createState() => _EmotionRecognitionViewState();
}

class _EmotionRecognitionViewState extends State<EmotionRecognitionView> {
  static const _darkPanel = Color(0xFF0D1A39);
  static const _card = Color(0xFF0F234A);
  static const _muted = Color(0xFF7EA0D0);
  static const _accent = Color(0xFF1BD0F2);

  final Map<String, double> _distribution = {
    'Angry': 0,
    'Disgust': 0,
    'Fear': 0,
    'Happy': 0,
    'Sad': 0,
    'Surprise': 0,
    'Neutral': 0,
  };

  bool _permissionGranted = false;
  bool _isStreaming = false;
  String _currentEmotion = '--';
  bool _hasDetection = false;
  String? _selectedSource;
  List<CameraDescription> _cameras = [];
  CameraDescription? _selectedCamera;
  CameraController? _cameraController;
  Future<void>? _initializeControllerFuture;
  String? _cameraError;
  bool _isLoadingCameras = false;
  bool _isStartingCamera = false;
  Timer? _frameTimer;
  bool _isSendingFrame = false;
  final Uri _pythonEndpoint = Uri.parse('http://10.0.2.2:8000/predict'); // change to your server
  final Duration _frameInterval = const Duration(milliseconds: 1500);

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _frameTimer?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleSpacing: 0,
        title: LayoutBuilder(
          builder: (context, constraints) {
            final bool compact = constraints.maxWidth < 360;
            final double textMaxWidth = math.max(120, constraints.maxWidth - 140);
            return Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF27E0F6), Color(0xFF3F60E0)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Text(
                    'RT',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: textMaxWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Real-time Face Emotion Recognition',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: compact ? 15 : 18,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Use your camera, stream ',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: const Color(0xCCB5C7EA),
                          fontSize: compact ? 11 : 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  fit: FlexFit.loose,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: _StatusChip(
                        label: _isStreaming ? 'Detecting' : 'Camera idle',
                        color: _isStreaming ? Colors.greenAccent.shade400 : const Color(0xFFAA3D59),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A0F24), Color(0xFF0B2341)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 900;
                final liveFeed = isWide
                    ? Expanded(flex: 7, child: _buildLiveFeedCard())
                    : _buildLiveFeedCard();
                final controls = isWide
                    ? Expanded(flex: 5, child: _buildControlPanel(context))
                    : _buildControlPanel(context);
                return Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: _darkPanel.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            liveFeed,
                            const SizedBox(width: 16),
                            controls,
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            liveFeed,
                            const SizedBox(height: 16),
                            controls,
                          ],
                        ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLiveFeedCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Live Feed',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              Text(
                'Detecting every 1.5s',
                style: TextStyle(color: _muted, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0B152B),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: _buildCameraPreview(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.04)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _isStreaming
                        ? (_hasDetection
                            ? 'Face detected: $_currentEmotion.'
                            : 'Camera streaming. Watching for faces...')
                        : 'Camera stopped. Click Start to begin.',
                    style: const TextStyle(color: _muted, fontSize: 13),
                  ),
                ),
                Text(
                  _isStreaming ? 'Python detector: active' : 'Python detector: idle',
                  style: TextStyle(
                    color: _isStreaming ? Colors.greenAccent.shade200 : _muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlPanel(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _card.withOpacity(0.94),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final bool isNarrow = constraints.maxWidth < 460;
                  final options = _cameras.map(_cameraLabel).toList();
                  final dropdownField = DropdownButtonFormField<String>(
                    value: options.contains(_selectedSource) ? _selectedSource : null,
                    dropdownColor: const Color(0xFF112449),
                    style: const TextStyle(color: Colors.white),
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Source',
                      labelStyle: const TextStyle(color: _muted, fontSize: 13),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.06),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: _accent, width: 1.4),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    hint: Text(
                      _isLoadingCameras ? 'Loading cameras...' : 'Select a camera',
                      style: const TextStyle(color: _muted, fontSize: 13),
                    ),
                    items: options
                        .map(
                          (label) => DropdownMenuItem<String>(
                            value: label,
                            child: Text(label),
                          ),
                        )
                        .toList(),
                    onChanged: options.isEmpty
                        ? null
                        : (val) {
                            if (val == null) return;
                            final camera = _cameras.firstWhere(
                              (cam) => _cameraLabel(cam) == val,
                              orElse: () => _cameras.first,
                            );
                            setState(() {
                              _selectedSource = val;
                              _selectedCamera = camera;
                            });
                          },
                  );

                  final permissionButton = OutlinedButton(
                    onPressed: _permissionGranted ? null : _grantPermission,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withOpacity(0.2)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Grant Camera Permission'),
                  );

                  if (isNarrow) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        dropdownField,
                        const SizedBox(height: 12),
                        permissionButton,
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(child: dropdownField),
                      const SizedBox(width: 12),
                      permissionButton,
                    ],
                  );
                },
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (_selectedCamera != null && _permissionGranted && !_isStreaming && !_isStartingCamera)
                          ? _startCamera
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3C5BF6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: _isStartingCamera
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text('Starting...'),
                              ],
                            )
                          : const Text('Start Camera'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _isStreaming ? _stopCamera : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF343A49),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Stop'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose a camera then press Start.',
                style: TextStyle(color: _muted, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _glassCard(
          title: 'Current Emotion',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              Text(
                _currentEmotion,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 26,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _isStreaming ? 'Live inference running' : 'Waiting for first detection',
                style: const TextStyle(color: _muted, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _glassCard(
          title: 'Emotion Distribution',
          action: _isStreaming ? 'Live' : '-',
          child: Column(
            children: _distribution.entries
                .map(
                  (entry) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 72,
                          child: Text(
                            entry.key,
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.07),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: entry.value / 100,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF28E0F5), Color(0xFF405AF5)],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 36,
                          child: Text(
                            '${entry.value.toStringAsFixed(0)}%',
                            textAlign: TextAlign.right,
                            style: const TextStyle(color: _muted, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 14),
        _glassCard(
          title: 'Log',
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white.withOpacity(0.8), size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(_logMessage(), style: const TextStyle(color: _muted, fontSize: 13)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _glassCard({required String title, String? action, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card.withOpacity(0.9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              if (action != null)
                Text(
                  action,
                  style: const TextStyle(color: _muted, fontSize: 12),
                ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Future<void> _grantPermission() async {
    final granted = await _checkPermission();
    if (granted) {
      await _loadCameras();
    }
  }

  Future<void> _startCamera() async {
    if (_selectedCamera == null) return;
    final granted = await _checkPermission();
    if (!granted) {
      setState(() {
        _cameraError = 'Camera permission is required.';
      });
      return;
    }

    setState(() {
      _isStartingCamera = true;
      _cameraError = null;
    });

    _cameraController?.dispose();
    _cameraController = CameraController(
      _selectedCamera!,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );
    _initializeControllerFuture = _cameraController!.initialize();

    try {
      await _initializeControllerFuture;
      if (!mounted) return;
      setState(() {
        _isStreaming = true;
        _isStartingCamera = false;
        _currentEmotion = 'Neutral';
        _hasDetection = false;
        _distribution.updateAll((key, value) => 0);
      });
      _startFrameLoop();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _cameraError = 'Failed to start camera: $e';
        _isStreaming = false;
        _isStartingCamera = false;
      });
    }
  }

  void _stopCamera() {
    _frameTimer?.cancel();
    _frameTimer = null;
    _cameraController?.dispose();
    _cameraController = null;
    _initializeControllerFuture = null;
    setState(() {
      _isStreaming = false;
      _currentEmotion = '--';
      _hasDetection = false;
      _distribution.updateAll((key, value) => 0);
    });
  }

  void _simulateDetection() async {
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted || !_isStreaming) return;
    const samples = [
      {
        'Angry': 4.0,
        'Disgust': 2.0,
        'Fear': 6.0,
        'Happy': 55.0,
        'Sad': 6.0,
        'Surprise': 12.0,
        'Neutral': 15.0,
      },
      {
        'Angry': 9.0,
        'Disgust': 3.0,
        'Fear': 10.0,
        'Happy': 20.0,
        'Sad': 22.0,
        'Surprise': 12.0,
        'Neutral': 24.0,
      },
      {
        'Angry': 3.0,
        'Disgust': 1.0,
        'Fear': 4.0,
        'Happy': 18.0,
        'Sad': 8.0,
        'Surprise': 28.0,
        'Neutral': 38.0,
      },
      {
        'Angry': 7.0,
        'Disgust': 2.0,
        'Fear': 15.0,
        'Happy': 12.0,
        'Sad': 12.0,
        'Surprise': 10.0,
        'Neutral': 42.0,
      },
    ];
    final sample = samples[math.Random().nextInt(samples.length)];
    String topEmotion = 'Neutral';
    double topScore = -1;
    sample.forEach((key, value) {
      if (value > topScore) {
        topScore = value;
        topEmotion = key;
      }
    });
    _applyDetection(topEmotion, sample);
  }

  void _startFrameLoop() {
    _frameTimer?.cancel();
    _frameTimer = Timer.periodic(_frameInterval, (_) => _sendFrameToPython());
    // fire immediately
    _sendFrameToPython();
  }

  Future<void> _sendFrameToPython() async {
    if (_isSendingFrame || !_isStreaming || _cameraController == null) return;
    _isSendingFrame = true;
    try {
      final picture = await _cameraController!.takePicture();
      final bytes = await picture.readAsBytes();
      final encoded = base64Encode(bytes);
      final response = await http
          .post(
            _pythonEndpoint,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'image': encoded}),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final emotion = (data['emotion'] ?? data['label'] ?? '--').toString();
        final distRaw = data['distribution'] ?? data['probs'] ?? {};
        final Map<String, double> dist = {};
        if (distRaw is Map) {
          distRaw.forEach((key, value) {
            final v = (value is num) ? value.toDouble() : double.tryParse(value.toString()) ?? 0;
            dist[key.toString()] = v;
          });
        }
        if (dist.isEmpty && data['scores'] is List && data['classes'] is List) {
          final classes = List<String>.from(data['classes']);
          final scores = List<dynamic>.from(data['scores']);
          for (int i = 0; i < classes.length && i < scores.length; i++) {
            final v = scores[i];
            dist[classes[i]] = (v is num) ? v.toDouble() : double.tryParse(v.toString()) ?? 0;
          }
        }
        if (!mounted) return;
        _applyDetection(emotion.isEmpty ? '--' : emotion, dist);
      } else {
        if (!mounted) return;
        setState(() {
          _cameraError = 'Python response ${response.statusCode}: ${response.body}';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _cameraError = 'Python request failed: $e';
      });
    } finally {
      _isSendingFrame = false;
    }
  }

  void _applyDetection(String emotion, Map<String, double> dist) {
    if (!mounted) return;
    setState(() {
      _cameraError = null;
      _hasDetection = true;
      _currentEmotion = emotion;
      if (dist.isNotEmpty) {
        _distribution.updateAll((key, value) => dist[key] ?? 0);
      }
    });
  }

  Widget _buildCameraPreview() {
    if (_cameraError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            _cameraError!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
      );
    }

    if (_initializeControllerFuture != null && _cameraController != null) {
      return FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                CameraPreview(_cameraController!),
                Container(
                  alignment: Alignment.bottomCenter,
                  padding: const EdgeInsets.all(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.45),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _isStreaming
                          ? (_hasDetection ? 'Detected: $_currentEmotion' : 'Streaming... waiting for detection')
                          : 'Camera stopped. Click Start to begin.',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Camera error: ${snapshot.error}',
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          }
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        },
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _isStreaming ? Icons.videocam : Icons.videocam_off,
            color: Colors.white.withOpacity(0.8),
            size: 48,
          ),
          const SizedBox(height: 10),
          Text(
            _isStreaming
                ? (_hasDetection
                    ? 'Detected: $_currentEmotion'
                    : 'Streaming... waiting for detection')
                : 'Camera stopped. Click Start to begin.',
            style: const TextStyle(color: _muted),
          ),
        ],
      ),
    );
  }

  String _logMessage() {
    if (_cameraError != null) return _cameraError!;
    if (!_permissionGranted) {
      return 'Camera permission not granted. Tap "Grant Camera Permission" above.';
    }
    if (_isLoadingCameras) return 'Loading cameras...';
    if (_hasDetection) return 'Detection found: $_currentEmotion.';
    if (_selectedSource != null) return _selectedSource!;
    return 'Select a camera source to start.';
  }

  Future<void> _init() async {
    final granted = await _checkPermission();
    if (granted) {
      await _loadCameras();
    }
  }

  Future<bool> _checkPermission() async {
    final status = await Permission.camera.status;
    if (status.isGranted) {
      setState(() => _permissionGranted = true);
      return true;
    }

    final result = await Permission.camera.request();
    final granted = result.isGranted;
    setState(() {
      _permissionGranted = granted;
      if (!granted && result.isPermanentlyDenied) {
        _cameraError = 'Camera permission permanently denied. Enable it from Settings.';
      } else if (!granted) {
        _cameraError = 'Camera permission denied.';
      } else {
        _cameraError = null;
      }
    });
    return granted;
  }

  Future<void> _loadCameras() async {
    setState(() {
      _isLoadingCameras = true;
      _cameraError = null;
    });

    try {
      final cams = await availableCameras();
      CameraDescription? preferred;
      if (cams.isNotEmpty) {
        preferred = cams.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.front,
          orElse: () => cams.first,
        );
      }
      if (!mounted) return;
      setState(() {
        _cameras = cams;
        if (preferred != null) {
          _selectedCamera ??= preferred;
          _selectedSource ??= _cameraLabel(preferred);
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _cameraError = 'Failed to load cameras: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingCameras = false;
        });
      }
    }
  }

  String _cameraLabel(CameraDescription cam) {
    switch (cam.lensDirection) {
      case CameraLensDirection.front:
        return 'Front Camera';
      case CameraLensDirection.back:
        return 'Rear Camera';
      case CameraLensDirection.external:
        return 'External Camera';
      default:
        return 'Camera (${cam.name})';
    }
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.7)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}
