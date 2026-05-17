<<<<<<< HEAD
<<<<<<< ours
=======
import 'package:flutter/material.dart';
<<<<<<< ours
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
=======
import 'pages/istatistik.dart';
import 'pages/analiz_secim_ekrani.dart'; // Yeni ekranımızı import ettik
import 'pages/profil.dart';
import 'pages/giris_ekrani.dart'; // İlk açılış için

void main() {
  runApp(const RectaApp());
}

class RectaApp extends StatelessWidget {
  const RectaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recta AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'SF Pro Display', // Varsa modern bir font
        useMaterial3: true,
      ),
      // Uygulama ilk açıldığında giriş ekranı gelsin
      home: const AuthScreen(), 
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  // Navigasyon sayfaları listesi
  final List<Widget> _pages = [
    const StatisticsScreen(), // Ana Sayfa (İndeks 0)
    const Center(child: Text("Egzersizler Yakında")), // Branşlar (İndeks 1)
    const ProfileScreen(), // Profil (İndeks 2)
  ];

  void _onItemTapped(int index) {
    // EĞER ORTADAKİ ANALİZ BUTONUNA BASILDIYSA (Özel durum)
    if (index == 1) { // İndeks tasarımına göre değişebilir
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AnalysisSelectionScreen()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color neonIndigo = Color(0xFF536DFE);
    const Color mainDark = Color(0xFF1A1B2F);

    return Scaffold(
      body: _pages[_selectedIndex],
      
      // ALT NAVİGASYON BARI (Recta Temalı)
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.white,
          selectedItemColor: neonIndigo,
          unselectedItemColor: Colors.black26,
          showSelectedLabels: true,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_rounded),
              label: 'Panel',
            ),
            BottomNavigationBarItem(
              icon: CircleAvatar(
                backgroundColor: mainDark,
                radius: 25,
                child: Icon(Icons.add_a_photo_rounded, color: Colors.white, size: 20),
              ),
              label: 'Analiz',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profil',
            ),
          ],
        ),
      ),
>>>>>>> theirs
    );
  }
}
>>>>>>> theirs
=======
>>>>>>> features/image-processing
