import 'package:flutter/material.dart';
import 'kamera_ekrani.dart'; // Kamera sayfasına gitmek için

class AnalysisSelectionScreen extends StatelessWidget {
  const AnalysisSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color neonIndigo = Color(0xFF536DFE);
    const Color mainDark = Color(0xFF1A1B2F);
    const Color bgLight = Color(0xFFF8F9FB);

    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: mainDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text("BUGÜN NE YAPMAK\nİSTERSİN?", 
              style: TextStyle(color: mainDark, fontSize: 28, fontWeight: FontWeight.w900, height: 1.2)),
            const SizedBox(height: 12),
            const Text("Formunu en iyi şekilde analiz edebilmem için bir mod seç.", 
              style: TextStyle(color: Colors.black38, fontSize: 14, fontWeight: FontWeight.w700)),
            
            const SizedBox(height: 40),

            // SQUAT ANALİZİ KARTI
            _buildSelectionCard(
              context,
              title: "SQUAT ANALİZİ",
              subtitle: "Diz ve sırt açısını hassas ölçerim.",
              icon: Icons.fitness_center_rounded,
              color: neonIndigo,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CameraScreen(exerciseName: "Squat"))),
            ),

            const SizedBox(height: 15),

            // SERBEST MOD KARTI
            _buildSelectionCard(
              context,
              title: "SERBEST MOD",
              subtitle: "Sen hareket et, ben formu yakalayayım.",
              icon: Icons.auto_awesome_rounded,
              color: const Color(0xFF00897B), // O sevdiğin tok yeşil tonu
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CameraScreen(exerciseName: "Serbest Mod"))),
            ),

            const Spacer(),
            
            // GEMINI NOTU
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.black.withOpacity(0.05)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lightbulb_outline_rounded, color: Colors.orangeAccent),
                  SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      "Kamerayı sabit bir yere koymayı ve 2 metre uzaklaşmayı unutma!",
                      style: TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionCard(BuildContext context, {required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 15)),
                  Text(subtitle, style: const TextStyle(color: Colors.black38, fontSize: 11, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.black12),
          ],
        ),
      ),
    );
  }
}