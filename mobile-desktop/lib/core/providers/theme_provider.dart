import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  static const String _themeKey = 'selected_theme';

  ThemeProvider({ThemeMode? initialMode}) {
    if (initialMode != null) {
      _themeMode = initialMode;
    } else {
      _loadTheme();
    }
  }

  static ThemeMode resolveThemeMode(SharedPreferences prefs) {
    final String? themeValue = prefs.getString(_themeKey);
    if (themeValue == null) return ThemeMode.system;
    if (themeValue == ThemeMode.light.toString()) return ThemeMode.light;
    if (themeValue == ThemeMode.dark.toString()) return ThemeMode.dark;
    return ThemeMode.system;
  }

  ThemeMode get themeMode => _themeMode;

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final String? themeValue = prefs.getString(_themeKey);
    
    if (themeValue != null) {
      _themeMode = _parseThemeMode(themeValue);
      notifyListeners();
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    debugPrint('[ThemeProvider] Setting theme mode to: $mode');
    _themeMode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode.toString());
  }

  ThemeMode _parseThemeMode(String value) {
    if (value == ThemeMode.light.toString()) return ThemeMode.light;
    if (value == ThemeMode.dark.toString()) return ThemeMode.dark;
    return ThemeMode.system;
  }
}