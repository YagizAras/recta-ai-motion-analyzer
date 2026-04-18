import 'package:equatable/equatable.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

abstract class PoseEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class StartRecordingEvent extends PoseEvent {}

class ProcessFrameEvent extends PoseEvent {
  final InputImage inputImage;
  ProcessFrameEvent(this.inputImage);
}