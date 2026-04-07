import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum FontSizeLevel { small, medium, large, extraLarge }

class FontSizeProvider extends ChangeNotifier {
  static const String _fontSizeKey = 'selected_font_size';
  
  FontSizeLevel _level = FontSizeLevel.medium;

  FontSizeProvider({FontSizeLevel? initialLevel}) {
    if (initialLevel != null) {
      debugPrint('[FontSizeProvider] Initialized with pre-loaded level: $initialLevel');
      _level = initialLevel;
    } else {
      debugPrint('[FontSizeProvider] No pre-loaded level, loading asynchronously');
      _loadFontSize();
    }
  }

  static FontSizeLevel resolveFontSizeLevel(SharedPreferences prefs) {
    final String? levelStr = prefs.getString(_fontSizeKey);
    if (levelStr == null) return FontSizeLevel.medium;
    return FontSizeLevel.values.firstWhere(
      (e) => e.toString() == levelStr,
      orElse: () => FontSizeLevel.medium,
    );
  }

  FontSizeLevel get level => _level;

  double get fontScale {
    switch (_level) {
      case FontSizeLevel.small:
        return 1.0;
      case FontSizeLevel.medium:
        return 1.15;
      case FontSizeLevel.large:
        return 1.3;
      case FontSizeLevel.extraLarge:
        return 1.45;
    }
  }

  Future<void> _loadFontSize() async {
    debugPrint('[FontSizeProvider] Loading font size from SharedPreferences');
    final prefs = await SharedPreferences.getInstance();
    final String? levelStr = prefs.getString(_fontSizeKey);
    if (levelStr != null) {
      debugPrint('[FontSizeProvider] Found saved level: $levelStr');
      _level = FontSizeLevel.values.firstWhere(
        (e) => e.toString() == levelStr,
        orElse: () => FontSizeLevel.medium,
      );
      notifyListeners();
    } else {
      debugPrint('[FontSizeProvider] No saved level found, using medium');
    }
  }

  Future<void> setFontSizeLevel(FontSizeLevel newLevel) async {
    debugPrint('[FontSizeProvider] Setting font size level to: $newLevel');
    _level = newLevel;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fontSizeKey, newLevel.toString());
  }
}