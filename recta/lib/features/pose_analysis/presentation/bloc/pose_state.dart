import 'dart:ui'; // Size sınıfı için gerekli
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

// Tek bir kareden gelen çizim verilerini paketleyelim
// Equatable KULLANILMIYOR: List<Pose> Equatable olmadığı için
// Bloc aynı state'i tekrar emit etmiyor sanıyordu ve UI güncellenemiyordu.
class PoseDrawingData {
  final List<Pose> poses;
  final Size imageSize;
  final InputImageRotation rotation;

  PoseDrawingData({required this.poses, required this.imageSize, required this.rotation});
}


// Equatable KULLANILMIYOR: PoseDrawingData içindeki List<Pose> nesneleri
// doğru şekilde karşılaştırılamadığı için Bloc state değişikliklerini
// "aynı state" olarak algılayıp emit'i yok sayıyordu.
abstract class PoseState {}

class PoseInitial extends PoseState {
  final PoseDrawingData? drawingData;
  PoseInitial({this.drawingData});
}

class PoseRecording extends PoseState {
  final int framesCollected;
  final PoseDrawingData? drawingData;

  PoseRecording(this.framesCollected, {this.drawingData});
}

class PoseProcessingData extends PoseState {}

class PoseAnalysisSuccess extends PoseState {
  final String analysisResult;
  PoseAnalysisSuccess(this.analysisResult);
}

class PoseError extends PoseState {
  final String message;
  PoseError(this.message);
}

class PosePreparing extends PoseState {
  final int countdown;
  final PoseDrawingData? drawingData; 
  PosePreparing(this.countdown, {this.drawingData});
}