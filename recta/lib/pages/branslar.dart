import 'package:flutter/material.dart';
import 'egzersiz_detay.dart'; // Bilgilendirme sayfasını açmak için gerekli

class BranslarScreen extends StatelessWidget {
  const BranslarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color neonIndigo = Color(0xFF536DFE);
    const Color bgLight = Color(0xFFF8F9FB);

    return ScrollConfiguration(
      // Ekranın lastik gibi uzamasını (overscroll) tamamen kapatır
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
            style: TextStyle(
              color: Colors.black, 
              fontWeight: FontWeight.w900, 
              fontSize: 18, 
              letterSpacing: 1.2
            )
          ),
        ),
        body: ListView(
          // Listenin kaydırırken esnemesini engeller
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: [
            _buildCategoryTitle("VÜCUT AĞIRLIĞI"),
            _buildExerciseCard(context, "SQUAT", "Alt vücut ve denge", Icons.fitness_center),
            _buildExerciseCard(context, "LUNGE", "Bacak ve kalça aktivasyonu", Icons.accessibility_new),
            _buildExerciseCard(context, "PLANK", "Core bölgesi stabilitesi", Icons.timer_outlined),
            
            const SizedBox(height: 24),
            _buildCategoryTitle("ESNEKLİK & MOBİLİTE"),
            _buildExerciseCard(context, "OMUZ FLEKSİYONU", "Fizik tedavi odaklı", Icons.rebase_edit),
            _buildExerciseCard(context, "KEDİ-İNEK", "Omurga mobilizasyonu", Icons.self_improvement),
            
            const SizedBox(height: 100), // Alt menüye çarpmaması için boşluk
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title, 
        style: const TextStyle(
          color: Colors.black26, 
          fontSize: 12, 
          fontWeight: FontWeight.w900, 
          letterSpacing: 1.2
        )
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
          BoxShadow(
            color: Colors.black.withOpacity(0.03), 
            blurRadius: 10, 
            offset: const Offset(0, 4)
          )
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
        title: Text(
          title, 
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)
        ),
        subtitle: Text(
          subtitle, 
          style: const TextStyle(fontSize: 12, color: Colors.black38)
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.black12),
        onTap: () {
          // DOĞRU YÖNLENDİRME: Direkt kamera yerine bilgilendirme (detay) sayfasına gidiyoruz
          Navigator.push(
            context, 
            MaterialPageRoute(
              builder: (context) => ExerciseDetailScreen(exerciseName: title)
            )
          );
        },
      ),
    );
  }
}