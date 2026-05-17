import 'package:equatable/equatable.dart';

abstract class ReportsState extends Equatable {
  const ReportsState();
  
  @override
  List<Object?> get props => [];
}

class ReportsInitial extends ReportsState {}

class ReportsLoading extends ReportsState {}

class ReportsLoaded extends ReportsState {
  final List<Map<String, dynamic>> history;
  final Map<String, double> averageScores;
  final bool isWeekly;
  final List<double> weeklyAverages;
  final List<double> monthlyAverages;

  const ReportsLoaded({
    required this.history, 
    required this.averageScores,
    this.isWeekly = true,
    this.weeklyAverages = const [0, 0, 0, 0, 0, 0, 0],
    this.monthlyAverages = const [0, 0, 0, 0],
  });

  ReportsLoaded copyWith({
    List<Map<String, dynamic>>? history,
    Map<String, double>? averageScores,
    bool? isWeekly,
    List<double>? weeklyAverages,
    List<double>? monthlyAverages,
  }) {
    return ReportsLoaded(
      history: history ?? this.history,
      averageScores: averageScores ?? this.averageScores,
      isWeekly: isWeekly ?? this.isWeekly,
      weeklyAverages: weeklyAverages ?? this.weeklyAverages,
      monthlyAverages: monthlyAverages ?? this.monthlyAverages,
    );
  }

  @override
  List<Object?> get props => [history, averageScores, isWeekly, weeklyAverages, monthlyAverages];
}

class ReportsError extends ReportsState {
  final String message;

  const ReportsError(this.message);

  @override
  List<Object?> get props => [message];
}
