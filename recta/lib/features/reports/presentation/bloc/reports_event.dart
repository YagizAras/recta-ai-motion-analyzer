import 'package:equatable/equatable.dart';

abstract class ReportsEvent extends Equatable {
  const ReportsEvent();

  @override
  List<Object?> get props => [];
}

class LoadReportsEvent extends ReportsEvent {}

class ReportsUpdatedEvent extends ReportsEvent {
  final List<Map<String, dynamic>> history;

  const ReportsUpdatedEvent(this.history);

  @override
  List<Object?> get props => [history];
}

class ReportsErrorEvent extends ReportsEvent {
  final String message;

  const ReportsErrorEvent(this.message);

  @override
  List<Object?> get props => [message];
}

class ChangeTimeFilterEvent extends ReportsEvent {
  final bool isWeekly;

  const ChangeTimeFilterEvent(this.isWeekly);

  @override
  List<Object?> get props => [isWeekly];
}
