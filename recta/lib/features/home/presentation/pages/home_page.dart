import 'package:flutter/material.dart';
import '../../../../core/theme/theme_manager.dart';
import '../../../pose_analysis/presentation/pages/pose_camera_page.dart';
import '../../../reports/presentation/pages/history_page.dart';
import '../../../authentication/presentation/pages/profile_page.dart';

class HomePage extends StatefulWidget {
  final String userName;
  const HomePage({super.key, required this.userName});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: ThemeManager.themeNotifier,
      builder: (context, theme, _) {
        final darkColor = ThemeManager.getColor();
        final lightColor = ThemeManager.getLightColor();
        final bgColor = const Color(0xFFFCF8F5); // Off-white cream color

        return Scaffold(
          backgroundColor: bgColor,
          body: Stack(
            children: [
              _buildBody(_selectedIndex, bgColor, lightColor, darkColor),
              
              // Custom Bottom Navigation Bar
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: _buildBottomNavigationBar(darkColor),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(int index, Color bgColor, Color lightColor, Color darkColor) {
    switch (index) {
      case 0:
        return _buildDashboard(bgColor, lightColor, darkColor);
      case 1:
        return const PoseCameraPage();
      case 2:
        return const HistoryPage();
      case 3:
        return const ProfilePage();
      default:
        return _buildDashboard(bgColor, lightColor, darkColor);
    }
  }

  Widget _buildDashboard(Color bgColor, Color lightColor, Color darkColor) {
    return Stack(
      children: [
        // Top Background
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: MediaQuery.of(context).size.height * 0.28,
          child: Container(
            color: lightColor,
          ),
        ),
        // Content
        SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      // Top Bar
                      _buildTopBar(darkColor),
                      const SizedBox(height: 24),
                      // Search Bar
                      _buildSearchBar(darkColor),
                      const SizedBox(height: 24),
                      // Categories Grid
                      _buildCategoriesGrid(darkColor),
                      const SizedBox(height: 32),
                      // Son Aktiviten Section
                      _buildSectionTitle("SON AKTİVİTEN", darkColor),
                      const SizedBox(height: 12),
                      _buildLastActivityCard(lightColor, darkColor),
                      const SizedBox(height: 32),
                      // Gelişimin ve Geri Bildirimlerin
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionTitle("GELİŞİMİN", darkColor),
                                const SizedBox(height: 12),
                                _buildProgressCard(lightColor, darkColor),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionTitle("GERİ BİLDİRİMLERİN", darkColor),
                                const SizedBox(height: 12),
                                _buildFeedbackCard(lightColor, darkColor),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 120), // Space for bottom nav
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar(Color darkColor) {
    return Row(
      children: [
        // Profile Image
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.lightBlue.shade100,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: const Icon(Icons.landscape, color: Colors.green, size: 30),
        ),
        const SizedBox(width: 12),
        // Welcome Text
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "HOŞ GELDİN!",
                style: TextStyle(
                  color: darkColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                widget.userName,
                style: TextStyle(
                  color: darkColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        // Notification Icon
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: darkColor,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.notifications_none, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        // Logo
        Image.asset(
          'assets/images/recta_logo.png',
          height: 40,
        ),
      ],
    );
  }

  Widget _buildSearchBar(Color darkColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: darkColor, width: 1.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: darkColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Ara",
                hintStyle: TextStyle(color: Colors.grey.shade400),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesGrid(Color darkColor) {
    final categories = [
      {"icon": Icons.fitness_center, "label": "FİTNESS"},
      {"icon": Icons.accessibility_new, "label": "FİZİK TEDAVİ"},
      {"icon": Icons.sports_basketball, "label": "SPOR BRANŞLARI"},
      {"icon": Icons.monitor_weight_outlined, "label": "KİLO TAKİBİ"},
      {"icon": Icons.insert_chart_outlined, "label": "GELİŞİM"},
      {"icon": Icons.center_focus_strong_outlined, "label": "ANALİZ BAŞLAT"},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.9,
      ),
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: darkColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                categories[index]["icon"] as IconData,
                color: Colors.white,
                size: 26,
              ),
              const SizedBox(height: 6),
              Text(
                categories[index]["label"] as String,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, Color darkColor) {
    return Text(
      title,
      style: TextStyle(
        color: darkColor,
        fontSize: 18,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget _buildLastActivityCard(Color lightColor, Color darkColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: lightColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("SON HAREKET:", style: TextStyle(color: darkColor, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text("DOĞRULUK:", style: TextStyle(color: darkColor, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text("DEĞERLENDİRME:", style: TextStyle(color: darkColor, fontWeight: FontWeight.w600)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Detaylı Gör...",
                style: TextStyle(
                  color: darkColor.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                ),
                child: const Text("Tekrar Yap", style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(Color lightColor, Color darkColor) {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: lightColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Icon(Icons.stacked_bar_chart, size: 80, color: darkColor),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Text(
              "Detaylı Gör...",
              style: TextStyle(
                color: darkColor.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard(Color lightColor, Color darkColor) {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: lightColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            child: Text(
              "Detaylı Gör...",
              style: TextStyle(
                color: darkColor.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(Color darkColor) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: darkColor,
        borderRadius: BorderRadius.circular(35),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.home, "Anasayfa", 0),
          _buildNavItem(Icons.center_focus_strong_outlined, "Analiz", 1),
          _buildNavItem(Icons.search, "Gelişim", 2),
          _buildNavItem(Icons.landscape, "Profil", 3, isProfile: true),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, {bool isProfile = false}) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          isProfile 
            ? Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.lightBlue.shade100,
                ),
                child: const Icon(Icons.landscape, color: Colors.green, size: 16),
              )
            : Icon(
                icon,
                color: isSelected ? Colors.white : Colors.white70,
                size: 24,
              ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
