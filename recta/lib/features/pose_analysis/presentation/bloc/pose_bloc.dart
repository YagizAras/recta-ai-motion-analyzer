import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/pose_repository.dart';
import '../../data/datasources/backend_api_service.dart'; // AnalysisResult
import '../../data/models/pose_frame_data.dart';
import '../../domain/exercise_analyzer.dart';
import '../../../../core/services/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pose_event.dart';
import 'pose_state.dart';

class PoseBloc extends Bloc<PoseEvent, PoseState> {
  final PoseRepository _repository;
  
  // Durum değişkenleri
  bool _isRecording = false;
  bool _isPreparing = false;
  Stopwatch _stopwatch = Stopwatch();
  List<PoseFrameData> _collectedFrames = [];
  bool _isFrameProcessing = false;
  ExerciseType _currentExercise = ExerciseType.squat;

  PoseBloc({required PoseRepository repository}) 
      : _repository = repository, super(PoseInitial()) {
    
    on<StartRecordingEvent>(_onStartRecording);
    on<ProcessFrameEvent>(_onProcessFrame);
    on<StopRecordingEvent>(_onStopRecording);
  }

  // 1. HAZIRLIK VE GERİ SAYIM METODU
  Future<void> _onStartRecording(StartRecordingEvent event, Emitter<PoseState> emit) async {
    _currentExercise = event.exerciseType;
    _isPreparing = true; // Flag ile durumu takip ediyoruz
    
    for (int i = 3; i > 0; i--) {
      PoseDrawingData? currentDrawing;
      if (state is PosePreparing) {
        currentDrawing = (state as PosePreparing).drawingData;
      }

      emit(PosePreparing(i, drawingData: currentDrawing));
      await Future.delayed(const Duration(seconds: 1));
    }

    // Geri sayım bitti, gerçek kayıt başlıyor
    _isPreparing = false;
    _collectedFrames.clear();
    _stopwatch.reset();
    _stopwatch.start();
    _isRecording = true;
    developer.log("KAYIT BAŞLADI - Stopwatch çalışıyor", name: 'PoseBloc');
    emit(PoseRecording(0));
  }

  // 2. KAYDI DURDURMA VE BACKEND'E GÖNDERME METODU
  Future<void> _onStopRecording(StopRecordingEvent event, Emitter<PoseState> emit) async {
    if (!_isRecording) return;
    
    _isRecording = false;
    _stopwatch.stop();
    developer.log("KAYIT DURDU - Toplanan frame: ${_collectedFrames.length}", name: 'PoseBloc');

    emit(PoseProcessingData()); // "Analiz ediliyor..." durumu

    try {
      // Typed AnalysisResult — artık JSON parse etmeye gerek yok
      final AnalysisResult result = await _repository.sendDataToBackend(_collectedFrames, _currentExercise);

      final analysisData = <String, dynamic>{
        'skor':            result.skor,
        'ozet':            result.ozet,
        'geribildirimler': result.geribildirimler,
        'tam_metin':       result.tamMetin,
        'guclu_yonler':    result.gucluYonler,
        'zayif_yonler':    result.zayifYonler,
        'oneriler':        result.oneriler,
      };

      // Analiz sonucunu Firestore'a kaydet (UML şemasına uygun olarak frame'leri de yolluyoruz)
      await _repository.saveAnalysisToFirestore(analysisData, _currentExercise, _collectedFrames);

      emit(PoseAnalysisSuccess(analysisData));

      // Bildirim kontrolü ve gönderimi
      bool shouldNotify = true;
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('UserProfiles').doc(user.uid).get();
        if (doc.exists) {
          shouldNotify = doc.data()?['AiFeedback'] ?? true;
        }
      }

      if (shouldNotify) {
        await NotificationService().showNotification(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000, 
          title: "Analiziniz Hazır", 
          body: "Gemini analiziniz tamamlandı, detayları inceleyebilirsiniz."
        );
      }

    } catch (e) {
      developer.log("Analiz hatası: $e", name: 'PoseBloc');
      emit(PoseError("Analiz hatası: ${e.toString()}"));
    }
  }

  // 3. HER KAREYİ İŞLEME METODU
  Future<void> _onProcessFrame(ProcessFrameEvent event, Emitter<PoseState> emit) async {
    // Kilit kontrolü: Eğer bir kare hala işleniyorsa, yeni geleni pas geç
    if (_isFrameProcessing) return;

    // Not: Artık hazırlık veya kayıt aşamasında değilsek bile çizim için çerçeve işlemeye devam ediyoruz.
    // 4 saniye dolunca Stop event'ini tetikle
    if (_isRecording && _stopwatch.elapsedMilliseconds >= 4000) {
      add(StopRecordingEvent());
      return;
    }

    final imageSize = event.inputImage.metadata?.size;
    final imageRotation = event.inputImage.metadata?.rotation;
    if (imageSize == null || imageRotation == null) {
      developer.log("UYARI: imageSize veya imageRotation null!", name: 'PoseBloc');
      return;
    }

    // KİLİDİ KAPAT: İşlem başlıyor
    _isFrameProcessing = true;

    try {
      // Repository'den ikili paketi (Record) alıyoruz
      final (frameData, poses) = await _repository.processSingleFrame(
        event.inputImage,
        _isRecording ? _stopwatch.elapsedMilliseconds : 0,
        _collectedFrames.length + 1,
        _currentExercise,
      );
      
      developer.log("Frame işlendi - Pose sayısı: ${poses.length}, frameData: ${frameData != null}", name: 'PoseBloc');
      
      final drawingData = PoseDrawingData(
        poses: poses, 
        imageSize: imageSize, 
        rotation: imageRotation
      );

      // DURUM A: Geri Sayım Sırasındaysak
      if (_isPreparing && state is PosePreparing) {
        final currentCountdown = (state as PosePreparing).countdown;
        emit(PosePreparing(currentCountdown, drawingData: drawingData));
      } 
      // DURUM B: Gerçek Kayıt Sırasındaysak
      else if (_isRecording) {
        if (frameData != null && _collectedFrames.length < 120) {
          _collectedFrames.add(frameData);
        }
        // 120 frame dolduysa kaydı otomatik bitir
        if (_collectedFrames.length >= 120) {
          add(StopRecordingEvent());
          return;
        }
        // UI'ı her karede hem frame sayısı hem iskelet çizimi için güncelle
        emit(PoseRecording(_collectedFrames.length, drawingData: drawingData));
      }
      // DURUM C: Boştayken Sadece İskelet Çiz
      else if (!_isPreparing && !_isRecording && (state is PoseInitial || state is PoseAnalysisSuccess || state is PoseError)) {
        emit(PoseInitial(drawingData: drawingData));
      }
    } catch (e) {
      developer.log("Frame işleme hatası: $e", level: 900, name: 'PoseBloc');
    } finally {
      // KİLİDİ AÇ: İşlem bitti, yeni kare alabiliriz
      _isFrameProcessing = false;
    }
  }

  @override
  Future<void> close() {
    _repository.dispose();
    return super.close();
  }
}