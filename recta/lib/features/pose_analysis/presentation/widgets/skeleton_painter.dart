import 'dart:math' show max;
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class SkeletonPainter extends CustomPainter {
  final List<Pose> poses;
  final Size imageSize;
  final InputImageRotation rotation;
 

  SkeletonPainter({
    required this.poses,
    required this.imageSize,
    required this.rotation,
  
  });

  @override
  void paint(Canvas canvas, Size screenSize) {
    if (poses.isEmpty) return;

    final paintLine = Paint()
      ..color = const Color(0xFFFF4952)
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final paintDot = Paint()
      ..color = const Color(0xFF1E104E)
      ..strokeWidth = 5.0
      ..style = PaintingStyle.fill;

    // ---------------------------------------------------------------
    // ADIM 1: Kameranın "doğal portrait" görüntü boyutunu belirle.
    // ML Kit koordinatları her zaman ham kamera görüntüsü (imageSize)
    // uzayındadır. 90°/270° dönüşümde eksen takas yaşanır.
    // ---------------------------------------------------------------
    final bool isRotated = rotation == InputImageRotation.rotation90deg ||
        rotation == InputImageRotation.rotation270deg;

    // Ekranda gösterilecek kamera görüntüsünün boyutu (portrait):
    //   Kamera portrait'ta 90° dönmüş olduğu için doğal width/height takası
    final double displayW = isRotated ? imageSize.height : imageSize.width;
    final double displayH = isRotated ? imageSize.width  : imageSize.height;

    // ---------------------------------------------------------------
    // ADIM 2: BoxFit.cover ölçek ve ofset hesabı.
    // Kamera önizleme katmanı aynı mantıkla ekranı doldurdu.
    // ---------------------------------------------------------------
    final double scaleX = screenSize.width  / displayW;
    final double scaleY = screenSize.height / displayH;
    final double scale  = max(scaleX, scaleY); // cover → büyük olanı seç

    final double offsetX = (screenSize.width  - displayW * scale) / 2;
    final double offsetY = (screenSize.height - displayH * scale) / 2;

    // ---------------------------------------------------------------
    // ADIM 3: ML Kit landmark koordinatını ekran koordinatına çevir.
    // isRotated durumunda x↔y ekseni yer değiştirir.
    // Ön kamerada x eksenini aynala (mirror).
    // ---------------------------------------------------------------
    Offset toScreen(double lmX, double lmY) {

      double x = lmX * scale + offsetX;
      double y = lmY * scale + offsetY;

      return Offset(x, y);
    }

    final pose = poses.first;

    // --- Bağlantı çizgilerini çiz ---
    void drawConnection(PoseLandmarkType t1, PoseLandmarkType t2) {
      final lm1 = pose.landmarks[t1];
      final lm2 = pose.landmarks[t2];
      if (lm1 != null && lm2 != null) {
        canvas.drawLine(
          toScreen(lm1.x, lm1.y),
          toScreen(lm2.x, lm2.y),
          paintLine,
        );
      }
    }

    // Gövde
    drawConnection(PoseLandmarkType.leftShoulder,  PoseLandmarkType.rightShoulder);
    drawConnection(PoseLandmarkType.leftShoulder,  PoseLandmarkType.leftHip);
    drawConnection(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip);
    drawConnection(PoseLandmarkType.leftHip,       PoseLandmarkType.rightHip);

    // Kollar
    drawConnection(PoseLandmarkType.leftShoulder,  PoseLandmarkType.leftElbow);
    drawConnection(PoseLandmarkType.leftElbow,     PoseLandmarkType.leftWrist);
    drawConnection(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow);
    drawConnection(PoseLandmarkType.rightElbow,    PoseLandmarkType.rightWrist);

    // Bacaklar
    drawConnection(PoseLandmarkType.leftHip,   PoseLandmarkType.leftKnee);
    drawConnection(PoseLandmarkType.leftKnee,  PoseLandmarkType.leftAnkle);
    drawConnection(PoseLandmarkType.rightHip,  PoseLandmarkType.rightKnee);
    drawConnection(PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle);

    // --- Eklem noktalarını çiz ---
    for (final landmark in pose.landmarks.values) {
      canvas.drawCircle(toScreen(landmark.x, landmark.y), 5.0, paintDot);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}