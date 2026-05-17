import 'dart:io';
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
import '../../domain/exercise_analyzer.dart';
import '../../../reports/presentation/pages/analiz_raporu.dart';
import 'analysis_loading_screen.dart';

class PoseCameraPage extends StatefulWidget {
  final List<CameraDescription> cameras;
  final ExerciseType selectedExercise;

  const PoseCameraPage({
    Key? key,
    required this.cameras,
    required this.selectedExercise,
  }) : super(key: key);

  @override
  State<PoseCameraPage> createState() => _PoseCameraPageState();
}

class _PoseCameraPageState extends State<PoseCameraPage>
    with SingleTickerProviderStateMixin {
  CameraController? _controller;
  bool _isStreamStarted = false;
  int _currentCameraIndex = 0;

  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 4, end: 16).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    // Ana renk: #2A2647 (lacivert), nokta: #1E104E

    _initializeCamera(_currentCameraIndex);
  }

  // ============================================================
  //  KAMERA & GÖRÜNTÜ İŞLEME — DEĞİŞTİRME
  // ============================================================

  Future<void> _initializeCamera(int cameraIndex) async {
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
      developer.log("Kamera başlatma hatası: $e", level: 1000, name: 'PoseCameraPage');
      return;
    }
    if (!mounted) return;
    _controller = controller;
    _isStreamStarted = false;
    setState(() {});
    _startImageStream();
  }

  void _startImageStream() {
    if (_controller == null || !_controller!.value.isInitialized || _isStreamStarted) return;
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
    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    }
    if (rotation == null) return null;
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) return null;
    if (Platform.isAndroid && format != InputImageFormat.nv21) return null;
    if (Platform.isIOS && format != InputImageFormat.bgra8888) return null;
    if (image.planes.isEmpty) return null;
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
    for (final Plane plane in planes) totalSize += plane.bytes.length;
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
    _glowController.dispose();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    if (_isStreamStarted && _controller != null) {
      try { _controller!.stopImageStream(); } catch (_) {}
    }
    _controller?.dispose();
    super.dispose();
  }

  // ============================================================
  //  BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final botPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF1D1E36), // UI Arka planı koyu mor
      body: BlocListener<PoseBloc, PoseState>(
          listener: (context, state) {
            if (state is PoseAnalysisSuccess) {
              // Loading ekranı zaten PoseAnalysisSuccess'i dinliyor
              // Ama kamera hâlâ açıksa (edge case) buradan da yönlendir
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => AnalysisReportScreen(
                    exerciseName: widget.selectedExercise.keyword,
                    date: "Az Önce",
                    analysisData: state.analysisResult,
                  ),
                ),
              );
            } else if (state is PoseError) {
              // SnackBar yerine tam ekran dialog — kullanıcı hatayı kesinlikle görsün
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => AlertDialog(
                  backgroundColor: const Color(0xFF1D1E36),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  title: const Row(
                    children: [
                      Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 28),
                      SizedBox(width: 10),
                      Text("Analiz Hatası", style: TextStyle(color: Colors.white, fontSize: 18)),
                    ],
                  ),
                  content: Text(
                    state.message,
                    style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("Tamam", style: TextStyle(color: Color(0xFF7C6FCD))),
                    ),
                  ],
                ),
              );
            }
          },
        child: BlocBuilder<PoseBloc, PoseState>(
          builder: (context, state) {
            if (state is PoseProcessingData) {
              return AnalysisLoadingScreen(exerciseName: widget.selectedExercise.keyword);
            }
            return Column(
              children: [
                // ── ÜST SİYAH BANT ──
            _buildTopBand(topPad),

            // ── KAMERA ALANI ──
            AspectRatio(
              aspectRatio: 3 / 4,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildCameraPreview(),
                  _buildSkeletonOverlay(),
                  _buildCountdownOverlay(),
                  Positioned(
                    top: 10,
                    left: 0,
                    right: 0,
                    child: Center(child: _buildStatusBadge()),
                  ),
                ],
              ),
            ),

            // ── ALT SİYAH BANT ──
            Expanded(child: _buildBottomBand(botPad)),
          ],
        );
      }),
      ),
    );
  }

  // ============================================================
  //  ÜST BANT — ince, iOS tarzı
  // ============================================================

  Widget _buildTopBand(double topPad) {
    return Container(
      color: const Color(0xFF1D1E36), // İstenen renk
      padding: EdgeInsets.fromLTRB(20, topPad + 8, 20, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 22),
          ),
          const Spacer(),
          const Text(
            "Hareket Analizi",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 22),
        ],
      ),
    );
  }

  // ============================================================
  //  KAMERA PREVİEW — 3:4 oranında
  // ============================================================

  Widget _buildCameraPreview() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white54),
      );
    }
    
    // Kameranın yatay/dikey oranını hesaplıyoruz (cihaz dik olduğu için 1/aspectRatio)
    final cameraAspectRatio = 1 / controller.value.aspectRatio; 
    const viewAspectRatio = 3 / 4; // Bizim UI kutumuzun oranı

    double scale = 1.0;
    if (cameraAspectRatio < viewAspectRatio) {
      scale = viewAspectRatio / cameraAspectRatio;
    } else {
      scale = cameraAspectRatio / viewAspectRatio;
    }

    return ClipRect(
      child: Transform.scale(
        scale: scale,
        child: Center(
          child: AspectRatio(
            aspectRatio: cameraAspectRatio,
            child: CameraPreview(controller),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonOverlay() {
    return Positioned.fill(
      child: BlocBuilder<PoseBloc, PoseState>(
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
      ),
    );
  }

  // ============================================================
  //  GERİ SAYIM
  // ============================================================

  Widget _buildCountdownOverlay() {
    return Positioned.fill(
      child: BlocBuilder<PoseBloc, PoseState>(
        buildWhen: (prev, curr) => curr is PosePreparing || prev is PosePreparing,
        builder: (context, state) {
          if (state is! PosePreparing) return const SizedBox.shrink();
          return Container(
            color: Colors.black.withValues(alpha: 0.35),
            child: Center(
              child: Text(
                "${state.countdown}",
                style: const TextStyle(
                  fontSize: 140,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  shadows: [
                    Shadow(blurRadius: 30, color: Color(0xFF2A2647)),
                    Shadow(blurRadius: 60, color: Color(0xFF1E104E)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  //  DURUM ROZETİ
  // ============================================================

  Widget _buildStatusBadge() {
    return BlocBuilder<PoseBloc, PoseState>(
      builder: (context, state) {
        if (state is PoseRecording) {
          return _badge(
            color: const Color(0xFF7C6FCD),  // açık indigo
            text: "${state.framesCollected} / 120 kare",
            showDot: true,
          );
        } else if (state is PosePreparing) {
          return _badge(color: Colors.orange, text: "Hazırlan!", showDot: false);
        } else if (state is PoseProcessingData) {
          return _badge(
            color: Colors.blueAccent,
            text: "Analiz ediliyor...",
            showDot: false,
            showSpinner: true,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _badge({
    required Color color,
    required String text,
    bool showDot = false,
    bool showSpinner = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withValues(alpha: 0.65), width: 1.2),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.25), blurRadius: 10, spreadRadius: 1),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot)
            Container(
              width: 9, height: 9,
              margin: const EdgeInsets.only(right: 7),
              decoration: BoxDecoration(
                color: color, shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: color, blurRadius: 5, spreadRadius: 1)],
              ),
            ),
          if (showSpinner)
            Padding(
              padding: const EdgeInsets.only(right: 7),
              child: SizedBox(
                width: 12, height: 12,
                child: CircularProgressIndicator(color: color, strokeWidth: 2),
              ),
            ),
          Text(
            text,
            style: TextStyle(
              color: color, fontWeight: FontWeight.w600, fontSize: 13.5,
              shadows: [Shadow(color: color, blurRadius: 6)],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  //  ALT BANT — kompakt, iOS tarzı
  // ============================================================

  Widget _buildBottomBand(double botPad) {
    return Container(
      color: const Color(0xFF1D1E36),
      padding: EdgeInsets.fromLTRB(24, 20, 24, botPad + 16),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          _buildGuidanceBar(),
          Expanded(
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 86), // Sol tarafı dengelemek için boşluk (54 + 32)
                  _buildShutterButton(),
                  const SizedBox(width: 32),
                  _buildExerciseSelectionButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseSelectionButton() {
    return GestureDetector(
      onTap: () => Navigator.of(context).maybePop(),
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.list_alt_rounded,
          color: Colors.white,
          size: 26,
        ),
      ),
    );
  }

  Widget _buildGuidanceBar() {
    return BlocBuilder<PoseBloc, PoseState>(
      builder: (context, state) {
        String message;
        Color color;

        if (state is PosePreparing) {
          message = "Hazır ol! Hareketini başlat";
          color = Colors.orange;
        } else if (state is PoseRecording) {
          message = "Kayıt sürüyor — kamerayı sabit tut";
          color = const Color(0xFF7C6FCD); // açık indigo
        } else if (state is PoseProcessingData) {
          message = "Yapay zeka değerlendiriyor...";
          color = Colors.blueAccent;
        } else {
          message = "Kadraja gir, butona bas";
          color = Colors.white38;
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            child: Row(
              key: ValueKey(message),
              children: [
                Icon(
                  state is PoseRecording
                      ? Icons.fiber_manual_record
                      : state is PoseProcessingData
                          ? Icons.auto_awesome
                          : Icons.info_outline_rounded,
                  color: color, size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                      color: color, fontSize: 16, fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  //  SHUTTER BUTONU — beyaz, iOS tarzı
  // ============================================================

  Widget _buildShutterButton() {
    return BlocBuilder<PoseBloc, PoseState>(
      builder: (context, state) {
        final bool isRecording = state is PoseRecording;
        final bool isActive = isRecording || state is PosePreparing || state is PoseProcessingData;

        return GestureDetector(
          onTap: isActive
              ? null
              : () => context.read<PoseBloc>().add(StartRecordingEvent(widget.selectedExercise)),
          child: AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, _) {
              return Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  // Dış beyaz halka (iOS tarzı)
                  border: Border.all(
                    color: Colors.white.withValues(alpha: isActive ? 0.25 : 0.9),
                    width: 4.5,
                  ),
                  boxShadow: isActive
                      ? []
                      : [
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.15),
                            blurRadius: _glowAnimation.value,
                            spreadRadius: 1,
                          ),
                        ],
                ),
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    // Kayıt başlayınca küçülüp kare olur, durunca dolar
                    width: isRecording ? 32 : 68,
                    height: isRecording ? 32 : 68,
                    decoration: BoxDecoration(
                      color: state is PoseProcessingData
                          ? Colors.blueAccent
                          : Colors.white.withValues(alpha: isActive && !isRecording ? 0.4 : 1.0),
                      borderRadius: BorderRadius.circular(isRecording ? 9 : 34),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}