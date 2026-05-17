import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../pose_detector_service.dart';
import '../datasources/backend_api_service.dart';
import '../../domain/exercise_analyzer.dart';
import '../models/pose_frame_data.dart';


class PoseRepository {
  final PoseDetectorService _poseService;
  final BackendApiService _apiService;

  PoseRepository({
    required PoseDetectorService poseService,
    required BackendApiService apiService,
  })  : _poseService = poseService,
        _apiService = apiService;

  Future<(PoseFrameData?, List<Pose>)> processSingleFrame(
    InputImage inputImage,
    int timeElapsedMs,
    int frameIndex,
    ExerciseType exerciseType,
  ) async {
    final poses = await _poseService.processImage(inputImage);
    if (poses.isEmpty) return (null, <Pose>[]);

    final pose = poses.first;

    // ExerciseAnalyzer'a delege et — egzersiz tipine göre 3D açıları hesaplar
    final exerciseData = ExerciseAnalyzer.generateExerciseData(pose, exerciseType);
    final Map<String, double> detectedAngles =
        Map<String, double>.from(exerciseData['angles'] as Map);

    // Açı hesaplanamasa bile çizim için poses listesini her zaman döndürüyoruz
    if (detectedAngles.isEmpty) return (null, poses);

    final frameData = PoseFrameData(
      frameIndex: frameIndex,
      timestampMs: timeElapsedMs,
      angles: detectedAngles,
    );

    return (frameData, poses);
  }

  Future<AnalysisResult> sendDataToBackend(List<PoseFrameData> frames, ExerciseType exerciseType) async {
    String injuryHistory = "Yok";
    String userName = "Kullanıcı";
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Kayıt sırasında verilen ismi al
      if (user.displayName != null && user.displayName!.isNotEmpty) {
        userName = user.displayName!;
      }

      // UserProfiles koleksiyonundan sakatlik bilgisini çek
      final profileDoc = await FirebaseFirestore.instance.collection('UserProfiles').doc(user.uid).get();
      if (profileDoc.exists) {
        injuryHistory = profileDoc.data()?['InjuryHistory'] ?? "Yok";
        // Profilde ad varsa onu tercih et
        final profileFirstName = profileDoc.data()?['FirstName'] ?? '';
        if (profileFirstName.toString().isNotEmpty) {
          final profileLastName = profileDoc.data()?['LastName'] ?? '';
          userName = '$profileFirstName $profileLastName'.trim();
        }
      }

      // Eski 'users' koleksiyonunu da kontrol et (geriye uyumluluk)
      if (injuryHistory == "Yok") {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          injuryHistory = doc.data()?['injuryHistory'] ?? "Yok";
        }
      }
    }
    
    if (injuryHistory.trim().isEmpty) {
      injuryHistory = "Yok";
    }

    final payload = {
      'exercise_type': exerciseType.keyword,
      'injury_history': injuryHistory,
      'user_name': userName,
      'frames': frames.map((e) => e.toJson()).toList(),
    };
    final jsonString = jsonEncode(payload);
    return await _apiService.sendPoseData(jsonString);
  }

  Future<void> saveAnalysisToFirestore(Map<String, dynamic> analysisData, ExerciseType exerciseType, [List<PoseFrameData>? frames]) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return; // Misafir ya da giriş yapılmamışsa kaydetme

    try {
      final batch = FirebaseFirestore.instance.batch();

      // 1. Analyses Tablosu
      final analysisRef = FirebaseFirestore.instance.collection('Analyses').doc();
      batch.set(analysisRef, {
        'AnalysisId': analysisRef.id,
        'UserId': user.uid,
        'MovementTypeId': exerciseType.keyword,
        'OverallScore': analysisData['skor'] ?? 0,
        'VideoUrl': '',
        'AnalysisDate': DateTime.now().toUtc().toIso8601String(),
        // Yapılandırılmış AI alanları — FeedbackHistoryScreen & AnalysisReportScreen için
        'guclu_yonler': analysisData['guclu_yonler'] ?? [],
        'zayif_yonler': analysisData['zayif_yonler'] ?? [],
        'oneriler':     analysisData['oneriler'] ?? [],
      });

      // 2. AIFeedbacks Tablosu
      final feedbackRef = FirebaseFirestore.instance.collection('AIFeedbacks').doc();
      batch.set(feedbackRef, {
        'FeedbackId':       feedbackRef.id,
        'AnalysisId':       analysisRef.id,
        'KritikCumle':      analysisData['kritik_cumle'] ?? '',
        'FeedbackText':     analysisData['ozet'] ?? '',
        'DetailedFeedback': analysisData['geribildirimler'] ?? '',
        'GeneratedAt':      DateTime.now().toUtc().toIso8601String(),
      });

      // 3. FrameData Tablosu
      if (frames != null && frames.isNotEmpty) {
        for (var frame in frames) {
          final frameRef = FirebaseFirestore.instance.collection('FrameData').doc();
          batch.set(frameRef, {
            'FrameId': frameRef.id,
            'AnalysisId': analysisRef.id,
            'TimestampMs': frame.timestampMs,
            'Angles': frame.angles, // Sağ/Sol açılar vs json içindeki yapı ile esnek eşleşiyor
          });
        }
      }

      await batch.commit();

    } catch (e) {
      print("Firestore kaydetme hatası: $e");
    }
  }

  void dispose() {
    _poseService.dispose();
  }
}