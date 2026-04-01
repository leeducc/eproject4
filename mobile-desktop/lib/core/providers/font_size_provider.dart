import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum FontSizeLevel { small, medium, large, extraLarge }

class FontSizeProvider extends ChangeNotifier {
  static const String _fontSizeKey = 'selected_font_size';
  
  FontSizeLevel _level = FontSizeLevel.medium;

  FontSizeProvider() {
    _loadFontSize();
  }

  FontSizeLevel get level => _level;

  double get fontScale {
    switch (_level) {
      case FontSizeLevel.small:
        return 0.85;
      case FontSizeLevel.medium:
        return 1.0;
      case FontSizeLevel.large:
        return 1.15;
      case FontSizeLevel.extraLarge:
        return 1.3;
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
