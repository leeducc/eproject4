import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  
  static const Color darkBackground = Color(0xFF0F1219);
  static const Color darkSurface = Color(0xFF161A23);
  static const Color darkPrimary = Color(0xFF3A7BD5);
  static const Color darkonSurface = Color(0xFFE0E0E0);
  static const Color darkOnSurface = Color(0xFFF5F5F5);
  static const Color darkTextSecondary = Color(0x99FFFFFF);

  
  static const Color lightBackground = Color(0xFFF0F4F8); 
  static const Color lightSurface = Colors.white;
  static const Color lightPrimary = Color(0xFF5A9BD5); 
  static const Color lightonSurface = Color(0xFF2D3E50); 
  static const Color lightOnSurface = Color(0xFF1E293B);
  static const Color lightTextSecondary = Color(0x992D3E50);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: lightPrimary,
      scaffoldBackgroundColor: lightBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: lightSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: lightonSurface,
          fontSize: 22,
          fontWeight: FontWeight.w900,
          fontFamily: 'Roboto',
        ),
        iconTheme: IconThemeData(color: lightonSurface, size: 28),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      colorScheme: ColorScheme.light(
        primary: lightPrimary,
        secondary: lightPrimary,
        surface: lightSurface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: lightOnSurface,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.black.withOpacity(0.05)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.black.withOpacity(0.05)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: lightPrimary, width: 1.5),
        ),
        hintStyle: TextStyle(color: lightonSurface.withOpacity(0.4), fontSize: 14),
      ),
      iconTheme: const IconThemeData(size: 28),
      fontFamily: 'Roboto',
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: lightonSurface, fontSize: 18),
        bodyMedium: TextStyle(color: lightonSurface, fontSize: 16),
        bodySmall: TextStyle(color: lightTextSecondary, fontSize: 14),
        titleLarge: TextStyle(color: lightonSurface, fontWeight: FontWeight.bold, fontSize: 24),
      ),
      dividerTheme: DividerThemeData(
        color: const Color(0xFF2D3E50).withOpacity(0.08),
        thickness: 1,
      ),
      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.black.withOpacity(0.05), width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightPrimary,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: lightPrimary.withOpacity(0.3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: lightSurface,
        selectedItemColor: lightPrimary,
        unselectedItemColor: lightTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
      ),
      extensions: [
        AppCustomColors(
          aiColor: Colors.purple,
          aisurface: Colors.purple.withOpacity(0.1),
          humanColor: lightPrimary,
          humansurface: lightPrimary.withOpacity(0.1),
          successColor: Colors.green,
          successsurface: Colors.green.withOpacity(0.1),
          errorColor: Colors.red,
          errorsurface: Colors.red.withOpacity(0.1),
          warningColor: Colors.orange,
          warningsurface: Colors.orange.withOpacity(0.1),
        ),
      ],
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
          color: darkonSurface,
          fontSize: 22,
          fontWeight: FontWeight.w900,
          fontFamily: 'Roboto',
        ),
        iconTheme: IconThemeData(color: darkonSurface, size: 28),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      colorScheme: const ColorScheme.dark(
        primary: darkPrimary,
        secondary: darkPrimary,
        surface: darkSurface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: darkOnSurface,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: darkPrimary, width: 1.5),
        ),
        hintStyle: TextStyle(color: darkonSurface.withOpacity(0.4), fontSize: 14),
      ),
      iconTheme: const IconThemeData(size: 28),
      fontFamily: 'Roboto',
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: darkonSurface, fontSize: 18),
        bodyMedium: TextStyle(color: darkonSurface, fontSize: 16),
        bodySmall: TextStyle(color: darkTextSecondary, fontSize: 14),
        titleLarge: TextStyle(color: darkonSurface, fontWeight: FontWeight.bold, fontSize: 24),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.white.withOpacity(0.1),
        thickness: 1,
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: darkSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkBackground,
        selectedItemColor: darkPrimary,
        unselectedItemColor: darkTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
      ),
      extensions: [
        AppCustomColors(
          aiColor: Colors.purpleAccent,
          aisurface: Colors.purpleAccent.withOpacity(0.1),
          humanColor: darkPrimary,
          humansurface: darkPrimary.withOpacity(0.1),
          successColor: Colors.greenAccent,
          successsurface: Colors.greenAccent.withOpacity(0.1),
          errorColor: Colors.redAccent,
          errorsurface: Colors.redAccent.withOpacity(0.1),
          warningColor: Colors.orangeAccent,
          warningsurface: Colors.orangeAccent.withOpacity(0.1),
        ),
      ],
    );
  }
}

extension AppThemeX on BuildContext {
  AppCustomColors get customColors => Theme.of(this).extension<AppCustomColors>()!;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
}

class AppCustomColors extends ThemeExtension<AppCustomColors> {
  final Color? aiColor;
  final Color? aisurface;
  final Color? humanColor;
  final Color? humansurface;
  final Color? successColor;
  final Color? successsurface;
  final Color? errorColor;
  final Color? errorsurface;
  final Color? warningColor;
  final Color? warningsurface;

  AppCustomColors({
    this.aiColor,
    this.aisurface,
    this.humanColor,
    this.humansurface,
    this.successColor,
    this.successsurface,
    this.errorColor,
    this.errorsurface,
    this.warningColor,
    this.warningsurface,
  });

  @override
  ThemeExtension<AppCustomColors> copyWith({
    Color? aiColor,
    Color? aisurface,
    Color? humanColor,
    Color? humansurface,
    Color? successColor,
    Color? successsurface,
    Color? errorColor,
    Color? errorsurface,
    Color? warningColor,
    Color? warningsurface,
  }) {
    return AppCustomColors(
      aiColor: aiColor ?? this.aiColor,
      aisurface: aisurface ?? this.aisurface,
      humanColor: humanColor ?? this.humanColor,
      humansurface: humansurface ?? this.humansurface,
      successColor: successColor ?? this.successColor,
      successsurface: successsurface ?? this.successsurface,
      errorColor: errorColor ?? this.errorColor,
      errorsurface: errorsurface ?? this.errorsurface,
      warningColor: warningColor ?? this.warningColor,
      warningsurface: warningsurface ?? this.warningsurface,
    );
  }

  @override
  ThemeExtension<AppCustomColors> lerp(ThemeExtension<AppCustomColors>? other, double t) {
    if (other is! AppCustomColors) return this;
    return AppCustomColors(
      aiColor: Color.lerp(aiColor, other.aiColor, t),
      aisurface: Color.lerp(aisurface, other.aisurface, t),
      humanColor: Color.lerp(humanColor, other.humanColor, t),
      humansurface: Color.lerp(humansurface, other.humansurface, t),
      successColor: Color.lerp(successColor, other.successColor, t),
      successsurface: Color.lerp(successsurface, other.successsurface, t),
      errorColor: Color.lerp(errorColor, other.errorColor, t),
      errorsurface: Color.lerp(errorsurface, other.errorsurface, t),
      warningColor: Color.lerp(warningColor, other.warningColor, t),
      warningsurface: Color.lerp(warningsurface, other.warningsurface, t),
    );
  }
}