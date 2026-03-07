enum AppThemeType { green, dark, pink, blue }

class ThemeManager {
  // TODO: İleride burayı SharedPreferences (telefon hafızası) ile okuyacak şekilde güncelleyeceğiz.
  // Şimdilik default (varsayılan) olarak YEŞİL temayı ayarlıyoruz.
  static AppThemeType currentTheme = AppThemeType.green;

  static String getWelcomeImagePath() {
    switch (currentTheme) {
      case AppThemeType.blue:
        return 'assets/images/welcome_screen_blue.jpeg';
      case AppThemeType.dark:
        return 'assets/images/welcome_screen_dark.jpeg';
      case AppThemeType.pink:
        return 'assets/images/welcome_screen_pink.jpeg';
      case AppThemeType.green:
        return 'assets/images/welcome_screen_green.jpeg';
    }
  }
}