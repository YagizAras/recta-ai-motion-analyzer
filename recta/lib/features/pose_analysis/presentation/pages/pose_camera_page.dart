import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../../domain/angle_calculator.dart';

//Kamera başlatıldı ve saniyede 30 kare veri akışı 
//iceririsnde çekilen anlık veriler MLkit e gönderilmeye hazır.
// 1. Yazdığımız servisi sayfaya dahil ediyoruz (Klasör yolunu kendi projene göre kontrol et)

import '../../data/pose_detector_service.dart'; 

class PoseCameraPage extends StatefulWidget {
  final List<CameraDescription> cameras;

  const PoseCameraPage({Key? key, required this.cameras}) : super(key: key);

  @override
  State<PoseCameraPage> createState() => _PoseCameraPageState();
}

class _PoseCameraPageState extends State<PoseCameraPage> {
  late CameraController _controller;
  bool _isProcessing = false; 
  
  // 2. ML Kit Servisimizi başlatıyoruz (Beyin burada!)
  final PoseDetectorService _poseService = PoseDetectorService();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _controller = CameraController(widget.cameras[0], ResolutionPreset.medium);
    
    await _controller.initialize();
    if (!mounted) return;
    setState(() {});

    // DİKKAT: callback fonksiyonunun başına 'async' ekledik çünkü yapay zeka işlemi zaman alacak.
    _controller.startImageStream((CameraImage image) async {
      if (_isProcessing) return; 
      _isProcessing = true; // Kilidi kapat

      final inputImage = _convertCameraImageToInputImage(image);

      if (inputImage != null) {
        // 3. KÖPRÜYÜ KURDUK: Paketlenmiş görüntüyü yapay zekaya (Servise) veriyoruz.
        // 'await' komutu, model iskeleti bulana kadar kodun burada beklemesini sağlar.
        final List<Pose> poses = await _poseService.processImage(inputImage);

        // Eğer ekranda en az 1 insan (iskelet) bulunduysa:
        if (poses.isNotEmpty) {
          final Pose firstPerson = poses.first; 
          
          // Omuz, Dirsek ve Bilek noktalarını çekiyoruz
          final rightShoulder = firstPerson.landmarks[PoseLandmarkType.rightShoulder];
          final rightElbow = firstPerson.landmarks[PoseLandmarkType.rightElbow];
          final rightWrist = firstPerson.landmarks[PoseLandmarkType.rightWrist];
          
          // 3 nokta da kamera açısındaysa (null değilse)
          if (rightShoulder != null && rightElbow != null && rightWrist != null) {
            
            // Domain katmanındaki fonksiyonumuzu çağırıp açıyı hesaplıyoruz!
            double elbowAngle = AngleCalculator.getAngle(
              rightShoulder, 
              rightElbow, 
              rightWrist
            );

            // Sonucu terminale yazdırıyoruz
            debugPrint("⛹️ Sağ Dirsek Açısı: ${elbowAngle.toStringAsFixed(1)}°");
          }
        } else {
          debugPrint("Kamerada insan yok, iskelet aranıyor...");
        }
        
      }

      // Model işini bitirdi, kilidi aç! (Çok kritik)
      _isProcessing = false; 
    });
  }

  InputImage? _convertCameraImageToInputImage(CameraImage image) {
    // (Burası bir önceki mesajdaki ile tamamen aynı kalacak, değişikliğe gerek yok)
    final camera = widget.cameras[0];
    final sensorOrientation = camera.sensorOrientation;
    
    final InputImageRotation? rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21 && format != InputImageFormat.yuv_420_888) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) return null;

    if (image.planes.isEmpty) return null;
    final bytes = image.planes[0].bytes;

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

  @override
  void dispose() {
    _controller.stopImageStream();
    _controller.dispose(); 
    // 4. Sayfadan çıkıldığında modeli bellekten siliyoruz (Memory Leak Koruması)
    _poseService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Canlı Hareket Analizi')),
      body: CameraPreview(_controller),
    );
  }
}