import 'dart:io';
import 'dart:math' as math;
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../widgets/skeleton_painter.dart';
import '../bloc/pose_bloc.dart';
import '../bloc/pose_event.dart';
import '../bloc/pose_state.dart';

class PoseCameraPage extends StatefulWidget {
  final List<CameraDescription> cameras;

  const PoseCameraPage({Key? key, required this.cameras}) : super(key: key);

  @override
  State<PoseCameraPage> createState() => _PoseCameraPageState();
}

class _PoseCameraPageState extends State<PoseCameraPage>
    with SingleTickerProviderStateMixin {
  CameraController? _controller;
  bool _isStreamStarted = false;
  // Varsayılan: arka kamera (index 0 genellikle arka kamera)
  int _currentCameraIndex = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    _initializeCamera(_currentCameraIndex);
  }

  Future<void> _initializeCamera(int cameraIndex) async {
    // 9:16 için en yakın çözünürlüğü elde etmek üzere medium preset kullan
    final controller = CameraController(
      widget.cameras[cameraIndex],
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );

    try {
      await controller.initialize();
    } catch (e) {
      developer.log("Kamera başlatma hatası: $e",
          level: 1000, name: 'PoseCameraPage');
      return;
    }

    if (!mounted) return;

    _controller = controller;
    _isStreamStarted = false;
    setState(() {});
    _startImageStream();
  }

  void _startImageStream() {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isStreamStarted) return;

    _isStreamStarted = true;
    _controller!.startImageStream((CameraImage image) {
      final inputImage = _convertCameraImageToInputImage(image);
      if (inputImage != null) {
        context.read<PoseBloc>().add(ProcessFrameEvent(inputImage));
      }
    });
    developer.log("Image stream başlatıldı", name: 'PoseCameraPage');
  }

  InputImage? _convertCameraImageToInputImage(CameraImage image) {
    final selectedCamera = widget.cameras[_currentCameraIndex];
    final sensorOrientation = selectedCamera.sensorOrientation;

    // --- Rotation hesabı ---
    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation = sensorOrientation;

      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }
    if (rotation == null) return null;

    // --- Format kontrolü ---
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) return null;

    // Android: nv21 formatı bekle
    if (Platform.isAndroid && format != InputImageFormat.nv21) return null;
    // iOS: bgra8888 formatı bekle
    if (Platform.isIOS && format != InputImageFormat.bgra8888) return null;

    if (image.planes.isEmpty) return null;

    // --- Byte dizisi oluşturma ---
    final bytes = Platform.isAndroid
        ? _concatenatePlanes(image.planes)
        : image.planes.first.bytes;

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );
  }

  Uint8List _concatenatePlanes(List<Plane> planes) {
    int totalSize = 0;
    for (final Plane plane in planes) {
      totalSize += plane.bytes.length;
    }
    final bytes = Uint8List(totalSize);
    int offset = 0;
    for (final Plane plane in planes) {
      bytes.setRange(offset, offset + plane.bytes.length, plane.bytes);
      offset += plane.bytes.length;
    }
    return bytes;
  }

  PoseDrawingData? _getDrawingData(PoseState state) {
    if (state is PoseRecording) return state.drawingData;
    if (state is PosePreparing) return state.drawingData;
    if (state is PoseInitial) return state.drawingData;
    return null;
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    if (_isStreamStarted && _controller != null) {
      try {
        _controller!.stopImageStream();
      } catch (_) {}
    }
    _controller?.dispose();
    super.dispose();
  }

  // ============================================================
  //  B U I L D
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocListener<PoseBloc, PoseState>(
        listener: (context, state) {
          if (state is PoseAnalysisSuccess) {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                backgroundColor: const Color(0xFF1B3B2F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: const Text("Analiz Sonucu",
                    style: TextStyle(color: Colors.white)),
                content: Text(state.analysisResult,
                    style: const TextStyle(color: Colors.white70)),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Tamam",
                        style: TextStyle(color: Color(0xFF5CAF8E))),
                  ),
                ],
              ),
            );
          } else if (state is PoseError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red.shade800,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── KAMERA VE İSKELET ÇİZİMİ (Fullscreen) ──
            _buildCameraStack(),

            // ── ÜST BAR: Geri Ok + Başlık ──
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              right: 16,
              child: _buildTopBar(),
            ),

            // ── DURUM ETİKETİ (Frame count, etc.) ──
            Positioned(
              top: MediaQuery.of(context).padding.top + 70,
              left: 0,
              right: 0,
              child: Center(
                child: _buildStatusBadge(),
              ),
            ),

            // ── GERİ SAYIM ──
            _buildCountdownOverlay(),

            // ── ALT KONTROLLER: Shutter ──
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 40,
              left: 0,
              right: 0,
              child: _buildBottomControls(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraStack() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF006400)),
      );
    }

    final size = MediaQuery.of(context).size;
    var scale = size.aspectRatio * controller.value.aspectRatio;
    if (scale < 1) scale = 1 / scale;

    return Transform.scale(
      scale: scale,
      child: Center(
        child: AspectRatio(
          aspectRatio: 1 / controller.value.aspectRatio,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CameraPreview(controller),
              _buildSkeletonOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonOverlay() {
    return BlocBuilder<PoseBloc, PoseState>(
      builder: (context, state) {
        final drawingData = _getDrawingData(state);

        if (drawingData == null || drawingData.poses.isEmpty) {
          return const SizedBox.shrink();
        }

        return CustomPaint(
          size: Size.infinite,
          painter: SkeletonPainter(
            poses: drawingData.poses,
            imageSize: drawingData.imageSize,
            rotation: drawingData.rotation,
          ),
        );
      },
    );
  }

  Widget _buildCountdownOverlay() {
    return BlocBuilder<PoseBloc, PoseState>(
      buildWhen: (prev, curr) => curr is PosePreparing || prev is PosePreparing,
      builder: (context, state) {
        if (state is! PosePreparing) return const SizedBox.shrink();
        return Center(
          child: Text(
            "${state.countdown}",
            style: const TextStyle(
              fontSize: 140,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              shadows: [
                Shadow(blurRadius: 30, color: Color(0xFF006400)),
                Shadow(blurRadius: 60, color: Color(0xFF006400)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).maybePop(),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 26,
            ),
          ),
        ),
        const Text(
          "HAREKET ANALİZİ",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            shadows: [Shadow(blurRadius: 10, color: Colors.black)],
          ),
        ),
        const SizedBox(width: 46), // Boşluk, başlığı ortalamak için
      ],
    );
  }

  Widget _buildStatusBadge() {
    return BlocBuilder<PoseBloc, PoseState>(
      builder: (context, state) {
        Widget? badge;

        if (state is PoseRecording) {
          badge = Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: const Color(0xFF006400).withValues(alpha: 0.8),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF006400).withValues(alpha: 0.5),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Color(0xFF006400),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF006400),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "${state.framesCollected} kare",
                  style: const TextStyle(
                    color: Color(0xFF006400),
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    shadows: [
                      Shadow(
                        color: Color(0xFF006400),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else if (state is PosePreparing) {
          badge = Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.orange.withValues(alpha: 0.8),
                width: 1.5,
              ),
            ),
            child: const Text(
              "Hazırlan!",
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          );
        } else if (state is PoseProcessingData) {
          badge = Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.blue.withValues(alpha: 0.8),
                width: 1.5,
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    color: Colors.blue,
                    strokeWidth: 2.5,
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  "Analiz ediliyor...",
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        if (badge == null) return const SizedBox.shrink();

        return badge;
      },
    );
  }

  Widget _buildBottomControls() {
    return BlocBuilder<PoseBloc, PoseState>(
      builder: (context, state) {
        final bool isRecording = state is PoseRecording;
        final bool isPreparing = state is PosePreparing;
        final bool isProcessing = state is PoseProcessingData;
        final bool isActive = isRecording || isPreparing || isProcessing;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: isActive
                  ? null
                  : () => context.read<PoseBloc>().add(StartRecordingEvent()),
              child: Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF006400).withValues(alpha: 0.5),
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF006400).withValues(alpha: 0.7),
                      blurRadius: 25,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: const BoxDecoration(
                      color: Color(0xFF006400),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: isRecording ? 28 : 70,
                        height: isRecording ? 28 : 70,
                        decoration: BoxDecoration(
                          color: isRecording
                              ? Colors.white
                              : const Color(0xFF006400),
                          borderRadius:
                              BorderRadius.circular(isRecording ? 6 : 35),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}