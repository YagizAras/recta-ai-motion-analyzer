import 'package:flutter/material.dart';
import 'gelisim_detay.dart'; 
import 'geri_bildirimler.dart';
import 'profil.dart';
import 'branslar.dart';
import 'analiz_secim_ekrani.dart'; // Yeni hazırlık ekranımızı bağladık

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Renk Paleti - Mevcut Tasarımınla Tam Uyumlu
    const Color bgLight = Color(0xFFF8F9FB);
    const Color neonIndigo = Color(0xFF536DFE);
    const Color neonCoral = Color(0xFFFF5252);
    const Color deepTeal = Color(0xFF00897B); 
    const Color darkText = Color(0xFF1A1A1A);

    return ScrollConfiguration(
      behavior: const ScrollBehavior().copyWith(overscroll: false),
      child: Scaffold(
        backgroundColor: bgLight,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          automaticallyImplyLeading: false,
          title: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("MERHABA,", 
                  style: TextStyle(color: Colors.black38, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                Text("İLAYDA", 
                  style: TextStyle(color: darkText, fontSize: 24, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          actions: [
            _buildAppBarIcon(Icons.calendar_today_rounded),
            const SizedBox(width: 12),
            _buildAppBarIcon(Icons.notifications_none_rounded),
            const SizedBox(width: 20),
          ],
        ),
        body: Stack(
          children: [
            ListView(
              physics: const ClampingScrollPhysics(), 
              padding: const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 140),
              children: [
                _buildSectionTitle("SON AKTİVİTE"),
                const SizedBox(height: 12),
                _buildLastActivityCard(neonIndigo),
                
                const SizedBox(height: 30),

                _buildSectionTitle("ANALİZ"),
                const SizedBox(height: 12),
                
                // YENİ HAREKET ANALİZİ - Seçim Ekranına Yönlendirildi
                _buildWideActionCard(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const AnalysisSelectionScreen()));
                  },
                  title: "YENİ HAREKET ANALİZİ",
                  subtitle: "Analiz modunu seç ve formunu kontrol et",
                  color: Colors.white,
                  icon: Icons.camera_alt_outlined,
                  iconColor: neonIndigo,
                  hasBorder: true,
                ),

                const SizedBox(height: 15),

                _buildWideActionCard(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const BranslarScreen()));
                  },
                  title: "HAREKET KÜTÜPHANESİ",
                  subtitle: "Branş seç ve hemen analize başla",
                  color: deepTeal.withOpacity(0.12), 
                  icon: Icons.grid_view_rounded,
                  iconColor: deepTeal, 
                ),

                const SizedBox(height: 35),

                _buildSectionTitle("ANALİZ GEÇMİŞİ"),
                const SizedBox(height: 12),
                _buildWideActionCard(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ProgressDetailScreen()));
                  },
                  title: "PERFORMANS ANALİZİ",
                  subtitle: "Gelişim grafikleri ve skorlar",
                  color: neonIndigo.withOpacity(0.08),
                  icon: Icons.auto_graph_rounded,
                  iconColor: neonIndigo,
                ),
                const SizedBox(height: 15),
                _buildWideActionCard(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const FeedbackHistoryScreen()));
                  },
                  title: "GEÇMİŞ ANALİZLER",
                  subtitle: "Gemini AI analiz yorumları",
                  color: neonCoral.withOpacity(0.08),
                  icon: Icons.psychology_outlined,
                  iconColor: neonCoral,
                ),
              ],
            ),

            // ALT NAVİGASYON BARI
            Align(
              alignment: Alignment.bottomCenter,
              child: _buildBottomNavigationBar(context, neonIndigo),
            ),
          ],
        ),
      ),
    );
  }

  // --- YARDIMCI WIDGETLAR ---

  Widget _buildAppBarIcon(IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.black87, size: 20),
        onPressed: () {},
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.5),
    );
  }

  Widget _buildLastActivityCard(Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1B2F), Color(0xFF2D2E4A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("SQUAT", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
              Text("%88", style: TextStyle(color: accentColor, fontSize: 18, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            "Gemini: 'Formun harika! Dizlerini biraz daha dışarı açarak dengeyi artırabilirsin.'",
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildWideActionCard({
    required String title, 
    required String subtitle, 
    required Color color, 
    required IconData icon, 
    required Color iconColor, 
    required VoidCallback onTap,
    bool hasBorder = false
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(28),
          border: hasBorder ? Border.all(color: iconColor.withOpacity(0.1), width: 2) : null,
          boxShadow: [
            BoxShadow(color: iconColor.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8))
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: iconColor, fontWeight: FontWeight.w900, fontSize: 14)),
                  Text(subtitle, style: const TextStyle(color: Colors.black38, fontSize: 11, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: iconColor.withOpacity(0.3)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, Color activeColor) {
    return Container(
      margin: const EdgeInsets.only(left: 24, right: 24, bottom: 25),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1A1B2F), Color(0xFF2D2E4A)]),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.home_filled, "Anasayfa", true, activeColor, () {}),
          
          // ALT BAR ANALİZ BUTONU - Seçim Ekranına Yönlendirildi
          _buildNavItem(Icons.camera_alt_outlined, "Analiz", false, activeColor, () {
             Navigator.push(context, MaterialPageRoute(builder: (context) => const AnalysisSelectionScreen()));
          }),
          
          _buildNavItem(Icons.auto_graph_rounded, "Gelişim", false, activeColor, () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ProgressDetailScreen()));
          }),
          _buildNavItem(Icons.person_outline_rounded, "Profil", false, activeColor, () {
             Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
          }),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, Color activeColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? activeColor : Colors.white60, size: 24),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: isActive ? activeColor : Colors.white60, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}