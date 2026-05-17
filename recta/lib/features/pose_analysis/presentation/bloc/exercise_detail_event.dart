import 'package:flutter/material.dart';

abstract class ExerciseDetailEvent {}

class LoadExerciseDetailEvent extends ExerciseDetailEvent {
  final String exerciseName;

  LoadExerciseDetailEvent(this.exerciseName);
}
