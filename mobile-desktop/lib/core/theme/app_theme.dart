import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // Dark Mode Colors (Material Design Guidance)
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkPrimary = Color(0xFF3A7BD5);
  static const Color darkOnBackground = Color(0xDEFFFFFF); // 87% white
  static const Color darkOnSurface = Color(0xDEFFFFFF);     // 87% white
  static const Color darkTextSecondary = Color(0x99FFFFFF); // 60% white

  // Light Mode Colors
  static const Color lightBackground = Color(0xFFF5F7FA);
  static const Color lightSurface = Colors.white;
  static const Color lightPrimary = Color(0xFF3A7BD5);
  static const Color lightOnBackground = Color(0xDE000000); // 87% black
  static const Color lightOnSurface = Color(0xDE000000);     // 87% black
  static const Color lightTextSecondary = Color(0x99000000); // 60% black

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: lightPrimary,
      scaffoldBackgroundColor: lightBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: lightBackground,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: lightOnBackground,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: 'Roboto',
        ),
        iconTheme: IconThemeData(color: lightOnBackground),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      colorScheme: const ColorScheme.light(
        primary: lightPrimary,
        secondary: lightPrimary,
        surface: lightSurface,
        background: lightBackground,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: lightOnSurface,
        onBackground: lightOnBackground,
      ),
      fontFamily: 'Roboto',
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: lightOnBackground),
        bodyMedium: TextStyle(color: lightOnBackground),
        titleLarge: TextStyle(color: lightOnBackground, fontWeight: FontWeight.bold),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.black.withOpacity(0.05),
        thickness: 1,
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
        visualDensity: VisualDensity(horizontal: 0, vertical: -2),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: darkPrimary,
      scaffoldBackgroundColor: darkBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: darkOnBackground,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: 'Roboto',
        ),
        iconTheme: IconThemeData(color: darkOnBackground),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      colorScheme: const ColorScheme.dark(
        primary: darkPrimary,
        secondary: darkPrimary,
        surface: darkSurface,
        background: darkBackground,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: darkOnSurface,
        onBackground: darkOnBackground,
      ),
      fontFamily: 'Roboto',
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: darkOnBackground),
        bodyMedium: TextStyle(color: darkOnBackground),
        titleLarge: TextStyle(color: darkOnBackground, fontWeight: FontWeight.bold),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.white.withOpacity(0.05),
        thickness: 1,
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
        visualDensity: VisualDensity(horizontal: 0, vertical: -2),
      ),
    );
  }
}
