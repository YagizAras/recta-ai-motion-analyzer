import 'package:flutter/material.dart';

class AnalysisReportScreen extends StatelessWidget {
  final String exerciseName;
  final String date;
  final Map<String, dynamic> analysisData;

  const AnalysisReportScreen({super.key, required this.exerciseName, required this.date, required this.analysisData});

  @override
  Widget build(BuildContext context) {
    const Color neonIndigo = Color(0xFF536DFE);

    final int score = analysisData['skor'] ?? 0;
    final String summary = analysisData['ozet'] ?? "Analiz tamamlandı.";
    final String feedback = analysisData['geribildirimler'] as String? ?? '';
    final List<dynamic> strengths = analysisData['guclu_yonler'] ?? [];
    final List<dynamic> weaknesses = analysisData['zayif_yonler'] ?? [];
    final List<dynamic> recommendations = analysisData['oneriler'] ?? [];

    Color scoreColor = score >= 85 ? Colors.greenAccent : (score >= 65 ? Colors.orangeAccent : Colors.redAccent);
    String formStatus = score >= 85 ? "Mükemmel" : (score >= 65 ? "İyi" : "Geliştirilmeli");

    return ScrollConfiguration(
      behavior: const ScrollBehavior().copyWith(overscroll: false),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FB),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black), onPressed: () => Navigator.pop(context)),
          title: const Text("ANALİZ RAPORU", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.5)),
        ),
        body: ListView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: [
            // ÖZET KART
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF1A1B2F), Color(0xFF2D2E4A)]),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(exerciseName, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                      Text(date, style: const TextStyle(color: Colors.white60, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // DİNAMİK DOĞRULUK BARI
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        children: [
                          Container(height: 10, width: double.infinity, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10))),
                          Container(
                            height: 10, 
                            width: constraints.maxWidth * (score / 100),
                            decoration: BoxDecoration(
                              color: scoreColor, 
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [BoxShadow(color: scoreColor.withOpacity(0.5), blurRadius: 10)],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStat("Skor", "%$score", scoreColor),
                      _buildStat("Öneri", "${recommendations.isNotEmpty ? recommendations.length : (feedback.isNotEmpty ? '✓' : '0')}", Colors.white),
                      _buildStat("Durum", formStatus, neonIndigo),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
            const Text("GEMINI AI INSIGHTS", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2, color: Colors.black26, fontSize: 11)),
            const SizedBox(height: 15),
            
            // Genel Özet — her zaman göster
            _buildInsightCard("Genel Özet", summary, Icons.auto_awesome),
            
            // Güçlü Yönler
            if (strengths.isNotEmpty)
              _buildInsightCard("Güçlü Yönler", "• ${strengths.join('\n• ')}", Icons.thumb_up_alt_outlined),
            
            // Zayıf Yönler
            if (weaknesses.isNotEmpty)
              _buildInsightCard("Zayıf Yönler", "• ${weaknesses.join('\n• ')}", Icons.warning_amber_rounded),
            
            // Öneriler (structured list)
            if (recommendations.isNotEmpty)
              _buildInsightCard("Gelişim Önerisi", "• ${recommendations.join('\n\n• ')}", Icons.lightbulb_outline_rounded),
            
            // Geri bildirim (ham metin) — yalnızca structured listeler boşsa göster
            if (recommendations.isEmpty && feedback.isNotEmpty)
              _buildInsightCard("Geri Bildirimler", feedback, Icons.lightbulb_outline_rounded),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, Color valColor) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: valColor, fontSize: 20, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildInsightCard(String title, String content, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF536DFE), size: 18),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 12),
          Text(content, style: const TextStyle(color: Colors.black54, fontSize: 13, height: 1.5, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}