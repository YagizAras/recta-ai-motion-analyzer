import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import '../../domain/exercise_analyzer.dart';
import '../../data/repositories/pose_repository.dart';
import '../../data/pose_detector_service.dart';
import '../../data/datasources/backend_api_service.dart';
import 'pose_camera_page.dart';
import '../bloc/exercise_detail_bloc.dart';
import '../bloc/exercise_detail_event.dart';
import '../bloc/exercise_detail_state.dart';
import '../bloc/pose_bloc.dart';

class ExerciseDetailScreen extends StatelessWidget {
  final String exerciseName;
  final List<CameraDescription> cameras;
  const ExerciseDetailScreen({super.key, required this.exerciseName, required this.cameras});

  @override
  Widget build(BuildContext context) {
    const Color neonIndigo = Color(0xFF536DFE);
    const Color darkBlue = Color(0xFF1A1B2F);

    return BlocProvider(
      create: (context) => ExerciseDetailBloc()..add(LoadExerciseDetailEvent(exerciseName)),
      child: ScrollConfiguration(
        behavior: const ScrollBehavior().copyWith(overscroll: false),
        child: Scaffold(
          backgroundColor: const Color(0xFFF8F9FB),
          body: Column(
            children: [
              // ÜST GÖRSEL ALANI
              Stack(
                children: [
                  Container(
                    height: 300,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [darkBlue, Color(0xFF2D2E4A)]),
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(45)),
                    ),
                    child: Center(
                      child: Icon(Icons.fitness_center_rounded, color: Colors.white.withOpacity(0.1), size: 150),
                    ),
                  ),
                  Positioned(
                    top: 50,
                    left: 20,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Positioned(
                    bottom: 30,
                    left: 30,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(exerciseName.toUpperCase(), 
                          style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 2)),
                        const Text("Form ve Mobilite Rehberi", style: TextStyle(color: Colors.white60, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
              
              Expanded(
                child: BlocBuilder<ExerciseDetailBloc, ExerciseDetailState>(
                  builder: (context, state) {
                    if (state is ExerciseDetailLoading || state is ExerciseDetailInitial) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is ExerciseDetailError) {
                      return Center(child: Text(state.message));
                    } else if (state is ExerciseDetailLoaded) {
                      return ListView(
                        physics: const ClampingScrollPhysics(),
                        padding: const EdgeInsets.all(30),
                        children: [
                          _buildSectionTitle("NASIL YAPILIR?"),
                          const SizedBox(height: 12),
                          ...state.instructions.map((instruction) => 
                            _buildInstructionItem(instruction.stepNumber, instruction.text)
                          ),
                          
                          const SizedBox(height: 30),
                          _buildSectionTitle("DİKKAT EDİLMESİ GEREKENLER"),
                          const SizedBox(height: 12),
                          _buildAlertBox(state.alertMessage),

                          const SizedBox(height: 40),
                          // ANALİZİ BAŞLAT BUTONU
                          GestureDetector(
                            onTap: () {
                              ExerciseType type = ExerciseType.squat;
                              final name = exerciseName.toUpperCase();
                              if (name == "SQUAT" || name == "LUNGE" || name == "PLANK") {
                                type = ExerciseType.squat; 
                              } else if (name == "OMUZ FLEKSİYONU" || name == "KEDİ-İNEK") {
                                type = ExerciseType.shoulderMobility;
                              }
                              
                              if (cameras.isNotEmpty && context.mounted) {
                                final poseDetectorService = PoseDetectorService();
                                final backendApiService = BackendApiService();
                                final poseRepository = PoseRepository(
                                  poseService: poseDetectorService,
                                  apiService: backendApiService,
                                );
                                
                                Navigator.push(
                                  context, 
                                  MaterialPageRoute(
                                    builder: (_) => BlocProvider(
                                      create: (_) => PoseBloc(repository: poseRepository),
                                      child: PoseCameraPage(
                                        cameras: cameras, 
                                        selectedExercise: type,
                                      ),
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [Color(0xFF1A1B2F), Color(0xFF2D2E4A)]),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [BoxShadow(color: darkBlue.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
                              ),
                              child: const Center(
                                child: Text("ANALİZİ BAŞLAT", 
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Text(title, style: const TextStyle(color: Colors.black26, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.2));

  Widget _buildInstructionItem(String step, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(radius: 12, backgroundColor: const Color(0xFF536DFE).withOpacity(0.1), child: Text(step, style: const TextStyle(color: Color(0xFF536DFE), fontSize: 12, fontWeight: FontWeight.bold))),
          const SizedBox(width: 15),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildAlertBox(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.05), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.redAccent.withOpacity(0.1))),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}