import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/pose_analysis/data/pose_detector_service.dart';
import 'features/pose_analysis/data/datasources/backend_api_service.dart';
import 'features/pose_analysis/data/repositories/pose_repository.dart';
import 'features/pose_analysis/presentation/bloc/pose_bloc.dart';
import 'features/pose_analysis/presentation/pages/pose_camera_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(MyApp(cameras: cameras));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  const MyApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Canlı Hareket Analizi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (context) => PoseBloc(
          // KÖK BAĞLANTI BURASI: Repository'e iki alt servisini veriyoruz
          repository: PoseRepository(
            poseService: PoseDetectorService(), 
            apiService: BackendApiService(), 
          ),
        ),
        child: PoseCameraPage(cameras: cameras),
      ),
    );
  }
}