import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../reports/presentation/bloc/reports_bloc.dart';
import '../../../reports/presentation/bloc/reports_state.dart';
import '../../../reports/presentation/pages/analiz_raporu.dart';

class FeedbackHistoryScreen extends StatelessWidget {
  const FeedbackHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color bgLight = Color(0xFFF8F9FB);
    const Color neonIndigo = Color(0xFF536DFE);

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
        body: BlocBuilder<ReportsBloc, ReportsState>(
          builder: (context, state) {
            // Yükleniyor
            if (state is ReportsInitial || state is ReportsLoading) {
              return const Center(child: CircularProgressIndicator(color: neonIndigo));
            }

            // Hata
            if (state is ReportsError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
                      const SizedBox(height: 16),
                      Text(state.message, 
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              );
            }

            // Veri yüklendi
            if (state is ReportsLoaded) {
              final history = state.history;

              // Hiç analiz yoksa boş durum göster
              if (history.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.history_rounded, color: Colors.black12, size: 80),
                        const SizedBox(height: 20),
                        const Text("Henüz analiz yapılmadı", 
                          style: TextStyle(color: Colors.black38, fontSize: 18, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 8),
                        const Text("İlk analizini yaptığında sonuçların burada görünecek.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black26, fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                );
              }

              return ListView(
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

                  // HAREKET LİSTESİ — Firebase'den gelen dinamik veri
                  ...history.map((item) => _buildHistoryItem(context, item, neonIndigo)),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  // --- Tarih formatlama yardımcısı ---
  String _formatDate(dynamic dateValue) {
    if (dateValue == null) return '';
    
    DateTime? date;
    
    // Firestore Timestamp desteği
    if (dateValue is Map && dateValue.containsKey('_seconds')) {
      date = DateTime.fromMillisecondsSinceEpoch(
        (dateValue['_seconds'] as int) * 1000,
      );
    } else if (dateValue is String) {
      date = DateTime.tryParse(dateValue);
    } else {
      // cloud_firestore Timestamp objesi
      try {
        date = (dateValue).toDate();
      } catch (_) {
        return dateValue.toString();
      }
    }

    if (date == null) return '';

    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays == 0) return 'Bugün';
    if (diff.inDays == 1) return 'Dün';
    if (diff.inDays < 7) return '${diff.inDays} gün önce';
    
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  // --- Üstteki Özet Kartı ---
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

  // --- Her Bir Geçmiş Elemanı ---
  Widget _buildHistoryItem(BuildContext context, Map<String, dynamic> item, Color accentColor) {
    final String exerciseName = (item['exerciseName'] ?? item['name'] ?? 'Bilinmeyen').toString();
    final int score = item['score'] ?? 0;
    final String dateStr = _formatDate(item['date']);

    // Kritik cümle: yeni analizlerde gelir; eski kayıtlar için analitik cümle çıkar
    // Selamlama kelimelerini her iki kaynakta da filtrele
    const _greetings = ['merhaba', 'sayın', 'sevgili', 'dear', 'hello'];
    bool _isGreeting(String s) =>
        _greetings.any((g) => s.toLowerCase().trimLeft().startsWith(g));

    String teaser = (item['kritik_cumle'] ?? '').toString().trim();
    // kritik_cumle selamlama ile başlıyorsa geçersiz say
    if (_isGreeting(teaser)) teaser = '';

    if (teaser.isEmpty) {
      final fullText = (item['feedback'] ?? item['ozet'] ?? '').toString();
      // Selamlama cümlelerini atla, ilk analitik cümleyi bul
      final sentences = fullText.split(RegExp(r'[.!?]'));
      const greetings = ['merhaba', 'sayın', 'sevgili', '"omuz', 'recta uygulama'];
      final analyticalSentence = sentences.firstWhere(
        (s) {
          final trimmed = s.trim().toLowerCase();
          return trimmed.length > 20 &&
              !greetings.any((g) => trimmed.startsWith(g));
        },
        orElse: () => '',
      ).trim();
      if (analyticalSentence.isNotEmpty) {
        teaser = analyticalSentence.length > 80
            ? '${analyticalSentence.substring(0, 77)}...'
            : analyticalSentence;
      } else {
        // Son çare: tüm metni kırp
        teaser = fullText.length > 80 ? '${fullText.substring(0, 77)}...' : fullText;
      }
    }

    Color scoreColor = score >= 85
        ? Colors.greenAccent.shade700
        : (score >= 65 ? Colors.orangeAccent.shade700 : Colors.redAccent);

    final String displayName = _exerciseDisplayName(exerciseName);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnalysisReportScreen(
              exerciseName: displayName,
              date: dateStr,
              analysisData: item,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 6))
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Skor Halkası
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: scoreColor.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: scoreColor.withOpacity(0.4), width: 2),
              ),
              child: Center(
                child: Text(
                  '%$score',
                  style: TextStyle(
                    color: scoreColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // ── İçerik
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          displayName.toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        dateStr,
                        style: const TextStyle(color: Colors.black26, fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    teaser,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // ── Ok ikonu
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, color: accentColor.withOpacity(0.4), size: 22),
          ],
        ),
      ),
    );
  }

  String _exerciseDisplayName(String keyword) {
    switch (keyword.toUpperCase()) {
      case 'SQUAT':             return 'Squat';
      case 'PUSH_UP':           return 'Şınav';
      case 'SHOT_FORM':         return 'Basketbol Şut Formu';
      case 'SHOULDER_MOBILITY': return 'Omuz Mobilitesi';
      case 'LUNGE':             return 'Lunge';
      case 'PLANK':             return 'Plank';
      default:                  return keyword;
    }
  }
}