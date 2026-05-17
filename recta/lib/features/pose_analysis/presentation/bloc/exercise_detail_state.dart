import 'package:flutter/material.dart';

class InstructionStep {
  final String stepNumber;
  final String text;

  InstructionStep({required this.stepNumber, required this.text});
}

abstract class ExerciseDetailState {}

class ExerciseDetailInitial extends ExerciseDetailState {}

class ExerciseDetailLoading extends ExerciseDetailState {}

class ExerciseDetailLoaded extends ExerciseDetailState {
  final List<InstructionStep> instructions;
  final String alertMessage;

  ExerciseDetailLoaded({required this.instructions, required this.alertMessage});
}

class ExerciseDetailError extends ExerciseDetailState {
  final String message;

  ExerciseDetailError(this.message);
}
