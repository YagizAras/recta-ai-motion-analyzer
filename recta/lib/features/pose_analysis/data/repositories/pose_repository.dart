import 'dart:convert';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../pose_detector_service.dart';
import '../datasources/backend_api_service.dart';
import '../../domain/angle_calculator.dart';
import '../models/pose_frame_data.dart';


class PoseRepository {
  final PoseDetectorService _poseService;
  final BackendApiService _apiService;

  PoseRepository({
    required PoseDetectorService poseService,
    required BackendApiService apiService,
  })  : _poseService = poseService,
        _apiService = apiService;

  Future<(PoseFrameData?, List<Pose>)> processSingleFrame(InputImage inputImage, int timeElapsedMs, int frameIndex) async {
    final poses = await _poseService.processImage(inputImage);
    if (poses.isEmpty) return (null, <Pose>[]);

    final pose = poses.first;
    Map<String, double> detectedAngles = {};

    // 1. Landmarkları Çekiyoruz (Etiketleme Hazırlığı)
    final landmarks = pose.landmarks;
    
    // Sağ Taraf
    final rShoulder = landmarks[PoseLandmarkType.rightShoulder];
    final rElbow = landmarks[PoseLandmarkType.rightElbow];
    final rWrist = landmarks[PoseLandmarkType.rightWrist];
    final rHip = landmarks[PoseLandmarkType.rightHip];

    // Sol Taraf
    final lShoulder = landmarks[PoseLandmarkType.leftShoulder];
    final lElbow = landmarks[PoseLandmarkType.leftElbow];
    final lWrist = landmarks[PoseLandmarkType.leftWrist];
    final lHip = landmarks[PoseLandmarkType.leftHip];

    // Baş (Burun - Referans nokta)
    final nose = landmarks[PoseLandmarkType.nose];

    // 2. Açı Hesaplamaları ve Etiketleme
    
    // Sağ Dirsek (Omuz-Dirsek-Bilek)
    if (rShoulder != null && rElbow != null && rWrist != null) {
      detectedAngles['right_elbow'] = AngleCalculator.getAngle(rShoulder, rElbow, rWrist);
    }

    // Sol Dirsek (Omuz-Dirsek-Bilek)
    if (lShoulder != null && lElbow != null && lWrist != null) {
      detectedAngles['left_elbow'] = AngleCalculator.getAngle(lShoulder, lElbow, lWrist);
    }

    // Sağ Omuz (Kalça-Omuz-Dirsek) -> Kolun gövdeyle açısı
    if (rHip != null && rShoulder != null && rElbow != null) {
      detectedAngles['right_shoulder'] = AngleCalculator.getAngle(rHip, rShoulder, rElbow);
    }

    // Sol Omuz (Kalça-Omuz-Dirsek)
    if (lHip != null && lShoulder != null && lElbow != null) {
      detectedAngles['left_shoulder'] = AngleCalculator.getAngle(lHip, lShoulder, lElbow);
    }

    // Baş Pozisyonu Analizi (Basitçe burnun omuz hizasına göre durumu)
    // Not: Buraya daha karmaşık boyun açısı eklenebilir ama demo için etiket yeterli.
    // Başın omuz hizasına göre eğikliği (Dikey eksenden sapma)
// Baş Pozisyonu Analizi
if (nose != null && rShoulder != null && lShoulder != null) {
  // 1. Orta noktayı hesaplıyoruz
  final double shoulderMidX = (rShoulder.x + lShoulder.x) / 2;
  final double shoulderMidY = (rShoulder.y + lShoulder.y) / 2;
  
  // 2. DÜZELTME: Artık 'rShoulder' yerine, hesapladığımız orta noktaları veriyoruz!
  // Böylece hem sarı çizgiler gidecek hem de analizimiz tam merkeze odaklanacak.
  detectedAngles['head_tilt'] = AngleCalculator.getAngleFromVertical(
    nose.x, 
    nose.y, 
    shoulderMidX, 
    shoulderMidY
  );
}

// Açı hesaplanamasa bile çizim için poses listesini her zaman döndürüyoruz
    if (detectedAngles.isEmpty) return (null, poses);

    final frameData = PoseFrameData(
      frameIndex: frameIndex,
      timestampMs: timeElapsedMs,
      angles: detectedAngles,
    );

    return (frameData, poses);
  }

  Future<String> sendDataToBackend(List<PoseFrameData> frames) async {
    final jsonString = jsonEncode(frames.map((e) => e.toJson()).toList());
    return await _apiService.sendPoseData(jsonString);
  }

  void dispose() {
    _poseService.dispose();
  }
}