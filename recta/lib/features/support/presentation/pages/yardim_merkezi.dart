import 'package:flutter/material.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("YARDIM MERKEZİ", 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.2)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text("Sıkça Sorulan Sorular", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          const SizedBox(height: 20),
          _buildFaqItem("Analiz sonuçları ne kadar doğru?", "Gemini AI altyapımız hareketlerini %95 doğrulukla analiz eder."),
          _buildFaqItem("Hangi sakatlıklar için uygun?", "Diz, omuz ve bel rehabilitasyon süreçleri için özel programlar sunuyoruz."),
          _buildFaqItem("Verilerim güvende mi?", "Tüm sağlık verileriniz uçtan uca şifrelenmektedir."),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: ExpansionTile(
        title: Text(question, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
        children: [Padding(padding: const EdgeInsets.all(16.0), child: Text(answer, style: const TextStyle(color: Colors.black54)))],
      ),
    );
  }
}