import 'package:flutter/material.dart';

enum AppThemeType { base, dark, pink, blue }

class ThemeManager {
  // Uygulama genelinde dinlenebilir tema durumu
  static final ValueNotifier<AppThemeType> themeNotifier = ValueNotifier(AppThemeType.base);

  static AppThemeType get currentTheme => themeNotifier.value;

  static bool get isOriginalTheme => currentTheme == AppThemeType.base;

  /// Temayı değiştirir ve dinleyen tüm widget'ları tetikler
  static void setTheme(AppThemeType type) {
    themeNotifier.value = type;
  }

  /// Temaya göre ana renk döndürür
  static Color getColor() {
    switch (currentTheme) {
      case AppThemeType.blue:
        return Colors.blue.shade700;
      case AppThemeType.pink:
        return Colors.pink.shade400;
      case AppThemeType.dark:
        return Colors.blueGrey.shade900;
      case AppThemeType.base:
        return const Color(0xFF144544); // Image dark green
    }
  }

  /// Temaya göre açık/ikincil renk döndürür
  static Color getLightColor() {
    switch (currentTheme) {
      case AppThemeType.blue:
        return Colors.blue.shade200;
      case AppThemeType.pink:
        return Colors.pink.shade200;
      case AppThemeType.dark:
        return Colors.blueGrey.shade300;
      case AppThemeType.base:
        return const Color(0xFFC0D890); // Image light green
    }
  }

  /// Temaya göre premium gradyan döndürür
  static LinearGradient getGradient() {
    switch (currentTheme) {
      case AppThemeType.blue:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade900, Colors.cyan.shade700],
        );
      case AppThemeType.pink:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.purple.shade900, Colors.pink.shade400],
        );
      case AppThemeType.dark:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
        );
      case AppThemeType.base:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E5631), Color(0xFF8DC63F)],
        );
    }
  }
}