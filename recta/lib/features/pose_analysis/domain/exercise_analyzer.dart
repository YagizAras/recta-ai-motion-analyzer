import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'angle_calculator.dart';

/// Egzersiz tipleri için anahtar kelimeler
enum ExerciseType {
  squat('SQUAT'),
  lunge('LUNGE'),
  plank('PLANK'),
  pushUp('PUSH_UP'),
  shotForm('SHOT_FORM'),
  shoulderMobility('SHOULDER_MOBILITY'),
  catCow('CAT_COW');

  final String keyword;
  const ExerciseType(this.keyword);
}

/// Egzersiz verilerini JSON (Map) olarak paketleyen sınıf
class ExerciseAnalyzer {
  /// Verilen poz ve egzersiz türüne göre 3D açıları hesaplar ve
  /// Gemini API'sine gönderilmeye hazır bir Map döner.
  static Map<String, dynamic> generateExerciseData(Pose pose, ExerciseType type) {
    Map<String, dynamic> payload = {
      'exercise_keyword': type.keyword,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'angles': <String, double>{},
    };

    final landmarks = pose.landmarks;

    // Açı hesaplaması için yardımcı fonksiyon (null safety)
    double? getAngle(PoseLandmarkType first, PoseLandmarkType mid, PoseLandmarkType last) {
      if (landmarks.containsKey(first) && landmarks.containsKey(mid) && landmarks.containsKey(last)) {
        final f = landmarks[first];
        final m = landmarks[mid];
        final l = landmarks[last];
        if (f != null && m != null && l != null) {
          return double.parse(AngleCalculator.get3DAngle(f, m, l).toStringAsFixed(2));
        }
      }
      return null;
    }

    // Açıları payload içerisine eklemek için yardımcı fonksiyon
    void addAngle(String key, double? angle) {
      if (angle != null) {
        payload['angles'][key] = angle;
      }
    }

    switch (type) {
      // ──────────────────────────────────────
      // SQUAT — Diz açısı + Gövde eğilimi
      // İdeal: Diz 85°-100°, Gövde 140°-170°
      // ──────────────────────────────────────
      case ExerciseType.squat:
        addAngle('left_knee_angle', getAngle(PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle));
        addAngle('right_knee_angle', getAngle(PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle));
        addAngle('left_trunk_angle', getAngle(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee));
        addAngle('right_trunk_angle', getAngle(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee));
        break;

      // ──────────────────────────────────────
      // LUNGE — Ön diz açısı + Arka diz açısı + Gövde dikliği
      // İdeal: Ön diz ~90°, Arka diz ~90°, Gövde dik (160°-180°)
      // ──────────────────────────────────────
      case ExerciseType.lunge:
        // Ön ve arka bacak diz açıları
        addAngle('left_knee_angle', getAngle(PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle));
        addAngle('right_knee_angle', getAngle(PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle));
        // Kalça açısı (Shoulder-Hip-Knee) — gövde dikliği
        addAngle('left_hip_angle', getAngle(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee));
        addAngle('right_hip_angle', getAngle(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee));
        break;

      // ──────────────────────────────────────
      // PLANK — Gövde hizası + Kalça açısı + Omuz stabilitesi
      // İdeal: Gövde dümdüz (170°-180°), Omuz stabil
      // ──────────────────────────────────────
      case ExerciseType.plank:
        // Gövde hizası (Shoulder-Hip-Ankle) — tam düz hat = 180°
        addAngle('left_body_alignment', getAngle(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip, PoseLandmarkType.leftAnkle));
        addAngle('right_body_alignment', getAngle(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip, PoseLandmarkType.rightAnkle));
        // Omuz-Dirsek açısı (Shoulder-Elbow-Wrist) — dirsek stabilitesi
        addAngle('left_elbow_angle', getAngle(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist));
        addAngle('right_elbow_angle', getAngle(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist));
        break;

      // ──────────────────────────────────────
      // PUSH UP — Dirsek bükülmesi + Gövde hizalaması
      // İdeal: Dirsek 80°-100° (alt pozisyon), Gövde 160°-180°
      // ──────────────────────────────────────
      case ExerciseType.pushUp:
        addAngle('left_elbow_angle', getAngle(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist));
        addAngle('right_elbow_angle', getAngle(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist));
        addAngle('left_trunk_angle', getAngle(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee));
        addAngle('right_trunk_angle', getAngle(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee));
        break;

      // ──────────────────────────────────────
      // SHOT FORM (Basketbol Şut Pozisyonu) 
      // Atış mekaniği: Dirsek 85°-100°, Omuz 80°-100°, Diz 140°-170°
      // Guide kolu omuz açısı, atış kolu dirsek açısı, sıçrama diz açısı
      // ──────────────────────────────────────
      case ExerciseType.shotForm:
        // Atış kolu dirsek açısı (Shoulder-Elbow-Wrist)
        addAngle('right_elbow_angle', getAngle(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist));
        addAngle('left_elbow_angle', getAngle(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist));
        // Omuz açısı (Hip-Shoulder-Elbow) — kolun kaldırılma açısı
        addAngle('right_shoulder_angle', getAngle(PoseLandmarkType.rightHip, PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow));
        addAngle('left_shoulder_angle', getAngle(PoseLandmarkType.leftHip, PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow));
        // Sıçrama mekaniği — diz bükülmesi (Hip-Knee-Ankle)
        addAngle('right_knee_angle', getAngle(PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle));
        addAngle('left_knee_angle', getAngle(PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle));
        break;

      // ──────────────────────────────────────
      // SHOULDER MOBILITY — Omuz hareket açıklığı
      // İdeal: 150°-180° (kol yukarı tam uzatılmış)
      // ──────────────────────────────────────
      case ExerciseType.shoulderMobility:
        addAngle('left_shoulder_angle', getAngle(PoseLandmarkType.leftHip, PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow));
        addAngle('right_shoulder_angle', getAngle(PoseLandmarkType.rightHip, PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow));
        // Dirsek bükülme kontrolü — tam düzlük bekleniyor
        addAngle('left_elbow_angle', getAngle(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist));
        addAngle('right_elbow_angle', getAngle(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist));
        break;

      // ──────────────────────────────────────
      // CAT-COW — Omurga mobilizasyonu
      // İdeal: Kalça açısı değişken, Omuz stabilitesi
      // ──────────────────────────────────────
      case ExerciseType.catCow:
        // Omurga eğriliği (Shoulder-Hip-Knee)
        addAngle('left_spine_angle', getAngle(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee));
        addAngle('right_spine_angle', getAngle(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee));
        // Omuz açısı
        addAngle('left_shoulder_angle', getAngle(PoseLandmarkType.leftHip, PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow));
        addAngle('right_shoulder_angle', getAngle(PoseLandmarkType.rightHip, PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow));
        break;
    }

    return payload;
  }
}
