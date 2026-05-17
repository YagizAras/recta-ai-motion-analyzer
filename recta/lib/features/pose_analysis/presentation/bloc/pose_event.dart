import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../../domain/exercise_analyzer.dart';

// Equatable kaldırıldı: InputImage ve Pose nesneleri Equatable olmadığı için
// Bloc ardışık aynı tip event'leri "eşit" kabul edip yok sayıyordu.
// Bu, kameradan gelen frame'lerin işlenmemesinin temel sebebiydi.
abstract class PoseEvent {}

class StartRecordingEvent extends PoseEvent {
  final ExerciseType exerciseType;
  StartRecordingEvent(this.exerciseType);
}

class StopRecordingEvent extends PoseEvent {}

class ProcessFrameEvent extends PoseEvent {
  final InputImage inputImage;
  ProcessFrameEvent(this.inputImage);
}