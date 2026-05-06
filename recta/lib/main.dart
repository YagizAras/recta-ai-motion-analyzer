import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  // Flutter altyapısını hazırlıyoruz
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase'i başlatıyoruz
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Kamerayı sildik, uygulamayı direkt başlatıyoruz
  runApp(const MyApp());
}

// Uygulamanın şimdilik boş kalıbı (Kızarıklık olmasın diye)
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Text('Firebase Başarıyla Bağlandı! '),
        ),
      ),
    );
  }
}