import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

class ExerciseItem {
  final String title;
  final String subtitle;
  final IconData icon;

  ExerciseItem({required this.title, required this.subtitle, required this.icon});
}

class ExerciseCategory {
  final String title;
  final List<ExerciseItem> exercises;

  ExerciseCategory({required this.title, required this.exercises});
}

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<ExerciseCategory> categories;

  const HomeLoaded(this.categories);

  @override
  List<Object?> get props => [categories];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
