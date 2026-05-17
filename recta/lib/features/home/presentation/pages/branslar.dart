import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import '../../../pose_analysis/presentation/pages/egzersiz_detay.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';

class BranslarScreen extends StatelessWidget {
  final List<CameraDescription> cameras;
  const BranslarScreen({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    const Color neonIndigo = Color(0xFF536DFE);
    const Color bgLight = Color(0xFFF8F9FB);

    return BlocProvider(
      create: (context) => HomeBloc()..add(LoadExercisesEvent()),
      child: ScrollConfiguration(
        behavior: const ScrollBehavior().copyWith(overscroll: false),
        child: Scaffold(
          backgroundColor: bgLight,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            iconTheme: const IconThemeData(color: Colors.black),
            title: const Text(
              "SPOR BRANŞLARI", 
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1.2)
            ),
          ),
          body: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              if (state is HomeInitial || state is HomeLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is HomeError) {
                return Center(child: Text(state.message));
              } else if (state is HomeLoaded) {
                return ListView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  children: [
                    ...state.categories.expand((category) {
                      return [
                        _buildCategoryTitle(category.title),
                        ...category.exercises.map((exercise) => 
                          _buildExerciseCard(context, exercise.title, exercise.subtitle, exercise.icon)
                        ),
                        const SizedBox(height: 24),
                      ];
                    }),
                    const SizedBox(height: 76),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(title, 
        style: const TextStyle(color: Colors.black26, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.2)
      ),
    );
  }

  Widget _buildExerciseCard(BuildContext context, String title, String subtitle, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF536DFE).withOpacity(0.1), 
            borderRadius: BorderRadius.circular(16)
          ),
          child: Icon(icon, color: const Color(0xFF536DFE)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Colors.black)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.black38)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.black12),
        onTap: () {
          Navigator.push(
            context, 
            MaterialPageRoute(
              builder: (context) => ExerciseDetailScreen(exerciseName: title, cameras: cameras)
            )
          );
        },
      ),
    );
  }
}