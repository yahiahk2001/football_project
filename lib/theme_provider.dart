import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = true;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  ThemeData get themeData {
    return _isDarkMode ? _darkTheme : _lightTheme;
  }

  static final _lightTheme = ThemeData(
    fontFamily: 'NotoKufiArabic', // تعيين الخط الأساسي
    textSelectionTheme: const TextSelectionThemeData(
      selectionColor: Colors.grey, 
      selectionHandleColor: Colors.yellow,
    ),
    primaryColor: Colors.white,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      titleTextStyle: TextStyle(
        color: Colors.black87,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'NotoKufiArabic-Bold', // استخدام الخط العريض للعناوين
      ),
      iconTheme: IconThemeData(
        color: Colors.black26,
      ),
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        color: Colors.black87,
        fontWeight: FontWeight.bold,
        fontSize: 22,
        fontFamily: 'NotoKufiArabic-Bold',
      ),
      bodyLarge: TextStyle(
        color: Colors.black87,
        fontSize: 16,
        fontFamily: 'NotoKufiArabic-Regular',
      ),
      bodyMedium: TextStyle(
        color: Colors.black87,
        fontSize: 14,
        fontFamily: 'NotoKufiArabic-Regular',
      ),
    ),
    colorScheme: const ColorScheme.light(
      primary: Colors.white,
      secondary: Colors.white,
      surface: Colors.white,
    ),
  );

  static final _darkTheme = ThemeData(
    fontFamily: 'NotoKufiArabic', // تعيين الخط الأساسي
    textSelectionTheme: const TextSelectionThemeData(
      selectionColor: Colors.grey,
      selectionHandleColor: Colors.yellow,
    ),
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      titleTextStyle: TextStyle(
        color: AppColors.text,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'NotoKufiArabic-Bold', // استخدام الخط العريض للعناوين
      ),
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        color: AppColors.text,
        fontWeight: FontWeight.bold,
        fontSize: 22,
        fontFamily: 'NotoKufiArabic-Bold',
      ),
      bodyLarge: TextStyle(
        color: AppColors.text,
        fontSize: 16,
        fontFamily: 'NotoKufiArabic-Regular',
      ),
      bodyMedium: TextStyle(
        color: AppColors.text,
        fontSize: 14,
        fontFamily: 'NotoKufiArabic-Regular',
      ),
    ),
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surface,
      onPrimary: Colors.white,
      onSecondary: AppColors.text,
      onSurface: AppColors.text,
    ),
  );
}

class AppColors {
  static const Color primary = Color(0xFF0D1B2A);
  static const Color secondary = Color(0xFF1B263B);
  static const Color accent = Color(0xFFF4A261);
  static const Color background = Color(0xFF0A1128);
  static const Color surface = Color(0xFF415A77);
  static const Color button = Color.fromARGB(255, 4, 1, 85);
  static const Color text = Color(0xFFD9E2EC);
}
