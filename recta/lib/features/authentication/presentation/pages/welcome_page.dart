import 'package:flutter/material.dart';
import '../../../../core/theme/theme_manager.dart';
import 'login_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return ValueListenableBuilder(
      valueListenable: ThemeManager.themeNotifier,
      builder: (context, theme, _) {
        return Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              // --- 1. KATMAN: Dinamik Gradyan Arka Plan ---
              Container(
                decoration: BoxDecoration(
                  gradient: ThemeManager.getGradient(),
                ),
              ),

              // --- 2. KATMAN: Hafif Arka Plan Görseli (Opsiyonel Overlay) ---
              Opacity(
                opacity: 0.1,
                child: Image.asset(
                  'assets/images/welcome_bg_clean.png', 
                  fit: BoxFit.cover,
                ),
              ),

              // --- 3. KATMAN: Arayüz Elemanları ---
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 36.0),
                  child: Column(
                    children: [
                      const Spacer(flex: 3),

                      // LOGO
                      Image.asset(
                        'assets/images/recta_logo.png',
                        height: screenHeight * 0.30,
                      ),

                      const Spacer(flex: 1),

                      // HOŞ GELDİNİZ YAZISI
                      const Text(
                        "HOŞ GELDİNİZ!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),

                      const Spacer(flex: 2),

                      // MİSAFİR GİRİŞİ BUTONU
                      _buildCustomButton(
                        text: "Misafir Girişi",
                        onPressed: () {
                          debugPrint("Misafir Girişine Tıklandı");
                        },
                      ),
                      
                      const SizedBox(height: 16),

                      // OTURUM AÇ BUTONU
                      _buildCustomButton(
                        text: "Oturum Aç",
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginPage()),
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // KAYDOL METNİ
                      TextButton(
                        onPressed: () {
                          debugPrint("Kaydolma Ekranına Git");
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          splashFactory: InkRipple.splashFactory,
                        ),
                        child: const Text(
                          "Hesabınız yok mu? Hemen kaydol!",
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                        ),
                      ),

                      const Spacer(flex: 1),
                    ],
                  ),
                ),
              ),

              // --- 4. KATMAN: Hızlı Tema Değiştirici (TEST İÇİN) ---
              Positioned(
                top: 10,
                right: 10,
                child: SafeArea(
                  child: IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white),
                    onPressed: () => _showThemeSwitcher(context),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- TEMA DEĞİŞTİRİCİ MODAL ---
  void _showThemeSwitcher(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Tema Seçin", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Wrap(
                spacing: 15,
                children: [
                  _themeOption(context, AppThemeType.base, "Varsayılan", Colors.green),
                  _themeOption(context, AppThemeType.blue, "Mavi", Colors.blue),
                  _themeOption(context, AppThemeType.dark, "Koyu", Colors.black),
                  _themeOption(context, AppThemeType.pink, "Pembe", Colors.pink),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _themeOption(BuildContext context, AppThemeType type, String label, Color color) {
    return GestureDetector(
      onTap: () {
        ThemeManager.setTheme(type);
        Navigator.pop(context);
      },
      child: Column(
        children: [
          CircleAvatar(backgroundColor: color, radius: 25),
          const SizedBox(height: 5),
          Text(label),
        ],
      ),
    );
  }

  // --- ÖZEL BUTON TASARIM FONKSİYONU ---
  Widget _buildCustomButton({required String text, required VoidCallback onPressed}) {
    return SizedBox(
      height: 55,
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          // Buton yazısı her zaman aktif temanın rengini alır
          foregroundColor: ThemeManager.getColor(), 
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.keyboard_double_arrow_right, size: 24),
          ],
        ),
      ),
    );
  }
}