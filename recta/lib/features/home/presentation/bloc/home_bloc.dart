import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<LoadExercisesEvent>((event, emit) async {
      emit(HomeLoading());
      
      try {
        await Future.delayed(const Duration(milliseconds: 500));
        
        final categories = [
          ExerciseCategory(
            title: "VÜCUT AĞIRLIĞI",
            exercises: [
              ExerciseItem(title: "SQUAT", subtitle: "Alt vücut ve denge", icon: Icons.fitness_center),
              ExerciseItem(title: "LUNGE", subtitle: "Bacak ve kalça aktivasyonu", icon: Icons.accessibility_new),
              ExerciseItem(title: "PLANK", subtitle: "Core bölgesi stabilitesi", icon: Icons.timer_outlined),
            ],
          ),
          ExerciseCategory(
            title: "SPOR BRANŞLARI",
            exercises: [
              ExerciseItem(title: "BASKETBOL ŞUT", subtitle: "Şut formu ve mekanik analizi", icon: Icons.sports_basketball),
            ],
          ),
          ExerciseCategory(
            title: "ESNEKLİK & MOBİLİTE",
            exercises: [
              ExerciseItem(title: "OMUZ FLEKSİYONU", subtitle: "Fizik tedavi odaklı", icon: Icons.rebase_edit),
              ExerciseItem(title: "KEDİ-İNEK", subtitle: "Omurga mobilizasyonu", icon: Icons.self_improvement),
            ],
          ),
        ];
        
        emit(HomeLoaded(categories));
      } catch (e) {
        emit(HomeError("Veriler yüklenirken bir hata oluştu: \$e"));
      }
    });
  }
}
