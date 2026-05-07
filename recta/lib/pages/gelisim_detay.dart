import 'package:flutter/material.dart';

class ProgressDetailScreen extends StatefulWidget {
  const ProgressDetailScreen({super.key});

  @override
  State<ProgressDetailScreen> createState() => _ProgressDetailScreenState();
}

class _ProgressDetailScreenState extends State<ProgressDetailScreen> {
  // Haftalık mı Aylık mı seçimi için kontrol değişkeni
  bool isWeekly = true;

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
        body: ListView(
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
                  Expanded(child: _buildTimeTab("HAFTALIK", isWeekly, () => setState(() => isWeekly = true))),
                  Expanded(child: _buildTimeTab("AYLIK", !isWeekly, () => setState(() => isWeekly = false))),
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
                        ? [ // Haftalık Çubuklar
                            _buildBar(40, "Pzt"), _buildBar(60, "Sal"), _buildBar(45, "Çar"), 
                            _buildBar(90, "Per", isActive: true), _buildBar(65, "Cum"), 
                            _buildBar(30, "Cmt"), _buildBar(10, "Paz"),
                          ]
                        : [ // Aylık Çubuklar (Örn: Haftalık dilimler)
                            _buildBar(55, "1.Hafta"), _buildBar(75, "2.Hafta", isActive: true), 
                            _buildBar(60, "3.Hafta"), _buildBar(85, "4.Hafta"),
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

            // Branşların kümülatif (tüm zamanlar) ortalaması
            _buildProgressRow("Squat", 0.88, Colors.greenAccent),
            _buildProgressRow("Lunge", 0.65, Colors.orangeAccent),
            _buildProgressRow("Plank", 0.92, neonIndigo),
            _buildProgressRow("Omuz Fleksiyonu", 0.74, Colors.cyanAccent),

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
                        ? "Bu hafta formun geçen haftaya göre %12 daha stabil." 
                        : "Bu ay Squat derinliğinde gözle görülür bir artış var!",
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, height: 1.4),
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

  Widget _buildBar(double height, String label, {bool isActive = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 14,
          height: height,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF536DFE) : Colors.white.withOpacity(0.15),
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
              Container(
                height: 8, 
                width: MediaQuery.of(context).size.width * 0.7 * val, // Ekran genişliğine göre orantılı
                decoration: BoxDecoration(
                  color: color, 
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}