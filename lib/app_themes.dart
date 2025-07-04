import 'package:flutter/material.dart';

class AppThemes {
  static ThemeData get light => ThemeData(
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF222831), // 深灰主色
          onPrimary: Colors.white,
          secondary: Color(0xFF4F8CFF), // 柔和蓝
          onSecondary: Colors.white,
          surface: Color(0xFFF7F7FA), // 暖白
          onSurface: Color(0xFF222831),
          error: Color(0xFFE57373), // 柔和红
          onError: Colors.white,
        ),
        scaffoldBackgroundColor: Color(0xFFF7F7FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFF222831),
          elevation: 0,
          iconTheme: IconThemeData(color: Color(0xFF222831)),
          titleTextStyle: TextStyle(
            color: Color(0xFF222831),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF222831)),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF222831)),
          bodyMedium: TextStyle(color: Color(0xFF44474F)),
          titleLarge:
              TextStyle(color: Color(0xFF222831), fontWeight: FontWeight.bold),
        ),
        dividerColor: Color(0xFFE0E0E6),
        cardColor: Colors.white,
        dialogBackgroundColor: Colors.white,
        useMaterial3: true,
      );

  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE0E0E6), // 浅灰主色
          onPrimary: Color(0xFF181A20),
          secondary: Color(0xFF4F8CFF), // 柔和蓝
          onSecondary: Colors.white,
          surface: Color(0xFF23242B), // 深灰
          onSurface: Color(0xFFE0E0E6),
          error: Color(0xFFEF9A9A), // 柔和红
          onError: Color(0xFF181A20),
        ),
        scaffoldBackgroundColor: Color(0xFF181A20),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFFE0E0E6),
          elevation: 0,
          iconTheme: IconThemeData(color: Color(0xFFE0E0E6)),
          titleTextStyle: TextStyle(
            color: Color(0xFFE0E0E6),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFE0E0E6)),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFFE0E0E6)),
          bodyMedium: TextStyle(color: Color(0xFFB0B3BC)),
          titleLarge:
              TextStyle(color: Color(0xFFE0E0E6), fontWeight: FontWeight.bold),
        ),
        dividerColor: Color(0xFF35363C),
        cardColor: Color(0xFF23242B),
        dialogBackgroundColor: Color(0xFF23242B),
        useMaterial3: true,
      );
}
