import 'package:flutter/material.dart';
import 'analiz_raporu.dart';

class FeedbackHistoryScreen extends StatelessWidget {
  const FeedbackHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Performans sayfasındaki ana renkler
    const Color bgLight = Color(0xFFF8F9FB);
    const Color neonIndigo = Color(0xFF536DFE);
    const Color neonCoral = Color(0xFFFF5252);

    // Gemini'den geldiği varsayılan geçmiş veriler
    final List<Map<String, dynamic>> history = [
      {"name": "Squat", "score": 88, "date": "Bugün", "feedback": "Diz formun çok daha stabil, kalça açısını korumaya devam et."},
      {"name": "Omuz Fleksiyonu", "score": 72, "date": "Dün", "feedback": "Kolu biraz daha dik kaldırmalısın, açın daralıyor."},
      {"name": "Lunge", "score": 95, "date": "2 gün önce", "feedback": "Formun kusursuz! Denge kontrolün mükemmel seviyede."},
      {"name": "Squat", "score": 60, "date": "3 gün önce", "feedback": "Sırtını daha dik tutmaya odaklan, öne çok eğiliyorsun."},
    ];

    return ScrollConfiguration(
      behavior: const ScrollBehavior().copyWith(overscroll: false),
      child: Scaffold(
        backgroundColor: bgLight,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.black),
          title: const Text("Hareket Geçmişi", 
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 20)),
        ),
        body: ListView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: [
            // ÜST ÖZET KARTI
            _buildSummaryCard(neonIndigo, history.length),
            
            const SizedBox(height: 30),
            
            const Text(
              "GEÇMİŞ ANALİZLER",
              style: TextStyle(color: Colors.black38, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.5),
            ),
            
            const SizedBox(height: 15),

            // HAREKET LİSTESİ
            ...history.map((item) => _buildHistoryItem(item, neonIndigo)).toList(),
          ],
        ),
      ),
    );
  }

  // Üstteki Özet Kartı
  Widget _buildSummaryCard(Color color, int total) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1B2F), Color(0xFF2D2E4A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Toplam Analiz", style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
                SizedBox(height: 4),
                Text("Gemini AI", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(20)),
            child: Text(total.toString(), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
          )
        ],
      ),
    );
  }

  // Her Bir Geçmiş Elemanı
  Widget _buildHistoryItem(Map<String, dynamic> item, Color accentColor) {
    int score = item['score'];
    Color scoreColor = score >= 85 ? Colors.greenAccent.shade700 : (score >= 65 ? Colors.orangeAccent.shade700 : Colors.redAccent);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(item['name'].toUpperCase(), 
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF1A1A1A))),
              Text(item['date'], style: const TextStyle(color: Colors.black26, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              // Küçük Skor Halkası
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: scoreColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text("%$score", style: TextStyle(color: scoreColor, fontWeight: FontWeight.w900, fontSize: 14)),
                ),
              ),
              const SizedBox(width: 15),
              // Gemini Yorumu
              Expanded(
                child: Text(
                  item['feedback'],
                  style: const TextStyle(color: Colors.black54, fontSize: 13, height: 1.4, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}