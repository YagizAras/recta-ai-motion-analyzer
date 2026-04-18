import 'package:equatable/equatable.dart';

abstract class PoseState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PoseInitial extends PoseState {}
class PoseRecording extends PoseState {
  final int framesCollected; // Kullanıcıya kaç kare yakalandığını göstermek için
  PoseRecording(this.framesCollected);
  @override
  List<Object?> get props => [framesCollected];
}
class PoseProcessingData extends PoseState {} // API'ye gönderilirken
class PoseAnalysisSuccess extends PoseState {
  final String analysisResult;
  PoseAnalysisSuccess(this.analysisResult);
  @override
  List<Object?> get props => [analysisResult];
}
class PoseError extends PoseState {
  final String message;
  PoseError(this.message);
  @override
  List<Object?> get props => [message];
}