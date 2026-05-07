import 'package:flutter/material.dart';
import 'kamera_ekrani.dart';

class ExerciseDetailScreen extends StatelessWidget {
  final String exerciseName;
  const ExerciseDetailScreen({super.key, required this.exerciseName});

  @override
  Widget build(BuildContext context) {
    const Color neonIndigo = Color(0xFF536DFE);
    const Color darkBlue = Color(0xFF1A1B2F);

    return ScrollConfiguration(
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
              child: ListView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.all(30),
                children: [
                  _buildSectionTitle("NASIL YAPILIR?"),
                  const SizedBox(height: 12),
                  _buildInstructionItem("1", "Ayaklarını omuz genişliğinde aç."),
                  _buildInstructionItem("2", "Sırtını düz tutarak kalçanı geriye it."),
                  _buildInstructionItem("3", "Dizlerin parmak uçlarını geçmeyecek şekilde alçal."),
                  
                  const SizedBox(height: 30),
                  _buildSectionTitle("DİKKAT EDİLMESİ GEREKENLER"),
                  const SizedBox(height: 12),
                  _buildAlertBox("Dizlerini içe doğru bükmekten kaçın, bu bağlarına zarar verebilir."),

                  const SizedBox(height: 40),
                  // ANALİZİ BAŞLAT BUTONU
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CameraScreen(exerciseName: exerciseName))),
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
              ),
            ),
          ],
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