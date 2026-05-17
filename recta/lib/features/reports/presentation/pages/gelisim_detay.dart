import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/reports_bloc.dart';
import '../bloc/reports_event.dart';
import '../bloc/reports_state.dart';

class ProgressDetailScreen extends StatelessWidget {
  const ProgressDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color neonIndigo = Color(0xFF536DFE);
    const Color darkBlue = Color(0xFF1A1B2F);

    return ScrollConfiguration(
      behavior: const ScrollBehavior().copyWith(overscroll: false),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FB),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text("GELİŞİM ANALİZİ", 
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.2)),
        ),
        body: BlocBuilder<ReportsBloc, ReportsState>(
          builder: (context, state) {
            if (state is ReportsInitial || state is ReportsLoading) {
              return const Center(child: CircularProgressIndicator(color: neonIndigo));
            } else if (state is ReportsError) {
              return Center(child: Text(state.message));
            } else if (state is ReportsLoaded) {
              final averageScores = state.averageScores;
              final isWeekly = state.isWeekly;
              final weeklyAverages = state.weeklyAverages;
              final monthlyAverages = state.monthlyAverages;

              // Dinamik ortalama satırlarını oluştur
              List<Widget> progressRows = [];
              final colors = [Colors.greenAccent, Colors.orangeAccent, neonIndigo, Colors.cyanAccent, Colors.purpleAccent];
              int colorIndex = 0;

              if (averageScores.isEmpty) {
                progressRows.add(const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text("Henüz analiz veriniz bulunmuyor.", style: TextStyle(color: Colors.black54)),
                ));
              } else {
                averageScores.forEach((keyword, avg) {
                  String displayName = _getDisplayName(keyword);
                  progressRows.add(_buildProgressRow(displayName, avg / 100.0, colors[colorIndex % colors.length]));
                  colorIndex++;
                });
              }

                  return ListView(
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.all(24),
                    children: [
                      // 1. ZAMAN SEÇİCİ (Haftalık / Aylık Switch)
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            Expanded(child: _buildTimeTab("HAFTALIK", isWeekly, () => context.read<ReportsBloc>().add(const ChangeTimeFilterEvent(true)))),
                            Expanded(child: _buildTimeTab("AYLIK", !isWeekly, () => context.read<ReportsBloc>().add(const ChangeTimeFilterEvent(false)))),
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),

                      // 2. ANA GRAFİK KARTI (Tüm hareketlerin ortalaması)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [darkBlue, Color(0xFF2D2E4A)]),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(isWeekly ? "HAFTALIK TÜM HAREKETLER ORTALAMASI" : "AYLIK TÜM HAREKETLER ORTALAMASI", 
                              style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1)),
                            const SizedBox(height: 25),
                            SizedBox(
                              height: 180,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: isWeekly 
                                  ? [ // Haftalık Çubuklar — skor 0-100 → piksel 0-160
                                      _buildBar(weeklyAverages[0], "Pzt", isActive: DateTime.now().weekday == 1), 
                                      _buildBar(weeklyAverages[1], "Sal", isActive: DateTime.now().weekday == 2), 
                                      _buildBar(weeklyAverages[2], "Çar", isActive: DateTime.now().weekday == 3), 
                                      _buildBar(weeklyAverages[3], "Per", isActive: DateTime.now().weekday == 4), 
                                      _buildBar(weeklyAverages[4], "Cum", isActive: DateTime.now().weekday == 5), 
                                      _buildBar(weeklyAverages[5], "Cmt", isActive: DateTime.now().weekday == 6), 
                                      _buildBar(weeklyAverages[6], "Paz", isActive: DateTime.now().weekday == 7),
                                    ]
                                  : [ // Aylık Çubuklar
                                      _buildBar(monthlyAverages[0], "1.Hf"), 
                                      _buildBar(monthlyAverages[1], "2.Hf"), 
                                      _buildBar(monthlyAverages[2], "3.Hf"), 
                                      _buildBar(monthlyAverages[3], "4.Hf", isActive: true),
                                    ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 35),
                      _buildSectionTitle("BRANŞ BAZLI GENEL BAŞARI (TÜM ZAMANLAR)"),
                      const SizedBox(height: 8),
                      const Text("Her branş için bugüne kadar yapılan tüm analizlerin ortalamasıdır.", 
                        style: TextStyle(color: Colors.black26, fontSize: 11, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 20),

                      // DİNAMİK BRANŞ ORTALAMALARI
                      ...progressRows,

                      const SizedBox(height: 30),
                      
                      // ÖZET BİLGİ KARTI
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.black.withOpacity(0.05)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.auto_awesome_outlined, color: Colors.orangeAccent, size: 30),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Text(
                                isWeekly 
                                  ? "Düzenli analizlerle gelişimini artırıyorsun." 
                                  : "Aylık performansında genel bir denge var!",
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 50),
                    ],
                  );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  // Egzersiz keyword'ünü UI için Türkçe ve düzgün formata çeviren yardımcı fonksiyon
  String _getDisplayName(String keyword) {
    switch (keyword.toUpperCase()) {
      case 'SQUAT': return 'Squat';
      case 'PUSH_UP': return 'Şınav';
      case 'SHOT_FORM': return 'Basketbol Şut Formu';
      case 'SHOULDER_MOBILITY': return 'Omuz Mobilitesi';
      case 'LUNGE': return 'Lunge';
      case 'PLANK': return 'Plank';
      default: return keyword;
    }
  }

  Widget _buildTimeTab(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: selected ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)] : null,
        ),
        child: Center(
          child: Text(label, style: TextStyle(
            color: selected ? Colors.black : Colors.black38, 
            fontWeight: FontWeight.w900, 
            fontSize: 12,
            letterSpacing: 1
          )),
        ),
      ),
    );
  }

  Widget _buildBar(double score, String label, {bool isActive = false}) {
    const double maxHeight = 160.0;
    const double minHeight = 4.0;
    final double barHeight = score > 0
        ? (minHeight + (score / 100.0) * (maxHeight - minHeight))
        : minHeight;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (score > 0)
          Text(
            "${score.toInt()}",
            style: TextStyle(
              color: isActive ? const Color(0xFF536DFE) : Colors.white54,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        const SizedBox(height: 4),
        Container(
          width: 14,
          height: barHeight,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF536DFE) : Colors.white.withOpacity(score > 0 ? 0.4 : 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        const SizedBox(height: 12),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _buildSectionTitle(String title) => Text(title, style: const TextStyle(color: Color(0xFF1A1B2F), fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.2));

  Widget _buildProgressRow(String label, double val, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF1A1B2F))),
              Text("%${(val * 100).toInt()}", style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 10),
          Stack(
            children: [
              Container(height: 8, width: double.infinity, decoration: BoxDecoration(color: Colors.black.withOpacity(0.05), borderRadius: BorderRadius.circular(10))),
              LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    height: 8, 
                    width: constraints.maxWidth * val, // Container genişliğine göre orantılı
                    decoration: BoxDecoration(
                      color: color, 
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))],
                    ),
                  );
                }
              ),
            ],
          ),
        ],
      ),
    );
  }
}