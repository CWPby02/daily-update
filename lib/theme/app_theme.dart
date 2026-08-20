import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF7F8FA),

      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF176B52),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      cardTheme: const CardThemeData(
        elevation: 0,
      ),
    );
  }
}
