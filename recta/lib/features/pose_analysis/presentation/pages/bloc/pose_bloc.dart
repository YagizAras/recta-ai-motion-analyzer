import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/pose_repository.dart';
import '../../data/models/pose_frame_data.dart';
import 'pose_event.dart';
import 'pose_state.dart';

class PoseBloc extends Bloc<PoseEvent, PoseState> {
  final PoseRepository _repository;
  
  // Durum değişkenleri
  bool _isRecording = false;
  Stopwatch _stopwatch = Stopwatch();
  List<PoseFrameData> _collectedFrames = [];
  bool _isFrameProcessing = false; // Asenkron kilit

  PoseBloc({required PoseRepository repository}) 
      : _repository = repository, super(PoseInitial()) {
    
    on<StartRecordingEvent>(_onStartRecording);
    on<ProcessFrameEvent>(_onProcessFrame);
  }

  void _onStartRecording(StartRecordingEvent event, Emitter<PoseState> emit) {
    _collectedFrames.clear();
    _stopwatch.reset();
    _stopwatch.start();
    _isRecording = true;
    emit(PoseRecording(0));
  }

  Future<void> _onProcessFrame(ProcessFrameEvent event, Emitter<PoseState> emit) async {
    // Eğer kayıt edilmiyorsa veya önceki kare hala işleniyorsa atla
    if (!_isRecording || _isFrameProcessing) return;

    _isFrameProcessing = true;

    try {
      final elapsed = _stopwatch.elapsedMilliseconds;
      
      // 1. 3 Saniye kontrolü (3000 ms)
      if (elapsed >= 3000) {
        _isRecording = false;
        _stopwatch.stop();
        emit(PoseProcessingData()); // Yükleniyor UI'ına geç
        
        // Verileri API'ye gönder
        final result = await _repository.sendDataToBackend(_collectedFrames);
        emit(PoseAnalysisSuccess(result));
      } else {
        // 2. Kareyi işle ve buffer'a ekle
        final frameData = await _repository.processSingleFrame(event.inputImage, elapsed);
        if (frameData != null) {
          _collectedFrames.add(frameData);
        }
        // UI'ı her karede güncellemeyebilirsin (performans için), ancak sayıyı görmek iyi olabilir
        emit(PoseRecording(_collectedFrames.length)); 
      }
    } catch (e) {
      _isRecording = false;
      emit(PoseError("Analiz sırasında hata oluştu: ${e.toString()}"));
    } finally {
      _isFrameProcessing = false;
    }
  }
}