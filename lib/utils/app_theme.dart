import 'package:flutter/material.dart';

class AppTheme {
  // Renkler
  static const Color deepBg = Color(0xFF0D0A1A);
  static const Color deepBg2 = Color(0xFF160F2B);
  static const Color deepBg3 = Color(0xFF1E1540);
  static const Color gold = Color(0xFFC9A84C);
  static const Color gold2 = Color(0xFFE8D08A);
  static const Color purple = Color(0xFF7B5EA7);
  static const Color purple2 = Color(0xFFA07BC8);
  static const Color diamond = Color(0xFF4FC3F7);
  static const Color textPrimary = Color(0xFFF0EAD6);
  static const Color textSecondary = Color(0xFFB8A88A);
  static const Color cardBorder = Color(0x4DC9A84C);
  static const Color cardBg = Color(0x0DFFFFFF);

  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: deepBg,
        fontFamily: 'Nunito',
        colorScheme: const ColorScheme.dark(
          primary: gold,
          secondary: purple,
          surface: deepBg2,
          background: deepBg,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontFamily: 'Cinzel',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: gold,
          ),
          iconTheme: IconThemeData(color: gold),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'Cinzel', color: gold),
          displayMedium: TextStyle(fontFamily: 'Cinzel', color: gold),
          titleLarge: TextStyle(fontFamily: 'Cinzel', color: textPrimary, fontSize: 18),
          bodyLarge: TextStyle(color: textPrimary, fontSize: 16),
          bodyMedium: TextStyle(color: textSecondary, fontSize: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: gold,
            foregroundColor: const Color(0xFF1A1000),
            textStyle: const TextStyle(
              fontFamily: 'Cinzel',
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            minimumSize: const Size(double.infinity, 54),
          ),
        ),
      );
}

// Gradient constants
class AppGradients {
  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppTheme.gold, AppTheme.gold2, AppTheme.gold],
  );

  static const LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppTheme.deepBg, AppTheme.deepBg2],
  );

  static const LinearGradient purpleGold = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppTheme.purple, AppTheme.gold],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x0FFFFFFF), Color(0x05FFFFFF)],
  );
}
