import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale? _locale;
  static const String _localeKey = 'selected_locale';

  LocaleProvider({Locale? initialLocale, bool preloaded = false}) {
    if (preloaded) {
      debugPrint('[LocaleProvider] Initialized with pre-loaded locale: ${initialLocale?.languageCode ?? "system default"}');
      _locale = initialLocale;
    } else {
      debugPrint('[LocaleProvider] No pre-loaded locale, loading asynchronously');
      _loadLocale();
    }
  }

  static Locale? resolveLocale(SharedPreferences prefs) {
    final String? languageCode = prefs.getString(_localeKey);
    if (languageCode != null) {
      return Locale(languageCode);
    }
    return null;
  }

  Locale? get locale => _locale;

  Future<void> _loadLocale() async {
    debugPrint('[LocaleProvider] Loading locale from SharedPreferences');
    final prefs = await SharedPreferences.getInstance();
    final String? languageCode = prefs.getString(_localeKey);
    if (languageCode != null) {
      debugPrint('[LocaleProvider] Found saved locale: $languageCode');
      _locale = Locale(languageCode);
      notifyListeners();
    } else {
      debugPrint('[LocaleProvider] No saved locale found, using system default');
    }
  }

  Future<void> setLocale(Locale locale) async {
    debugPrint('[LocaleProvider] Setting locale to: ${locale.languageCode}');
    if (!['en', 'vi', 'zh'].contains(locale.languageCode)) return;

    _locale = locale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }

  void clearLocale() async {
    _locale = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_localeKey);
  }
}