import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/providers/ielts_level_provider.dart';
import 'core/providers/locale_provider.dart';
import 'core/providers/font_size_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/localization/app_localizations.dart';
import 'core/providers/tutoring_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/study_sections/writing/services/writing_api_service.dart';
import 'features/study_sections/writing/services/real_writing_repository.dart';
import 'features/study_sections/writing/services/writing_provider.dart';
import 'features/study_sections/vocabulary/providers/vocabulary_provider.dart';
import 'features/study_sections/vocabulary/repositories/real_vocabulary_repository.dart';
import 'features/study_sections/vocabulary/services/vocabulary_api_service.dart';
import 'features/study_sections/vocabulary/screens/favorite_manager.dart';
import 'features/study_sections/vocabulary/providers/vocabulary_test_provider.dart';
import 'features/ranking/providers/ranking_provider.dart';

import 'data/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('[main] Loading .env');
  await dotenv.load(fileName: ".env");
  debugPrint('[main] Initializing notifications');
  await NotificationService.initialize();

  // Pre-load SharedPreferences and settings
  debugPrint('[main] Pre-loading settings from SharedPreferences');
  final prefs = await SharedPreferences.getInstance();
  
  debugPrint('[main] Resolving settings');
  final initialThemeMode = ThemeProvider.resolveThemeMode(prefs);
  final initialFontSizeLevel = FontSizeProvider.resolveFontSizeLevel(prefs);
  final initialLocale = LocaleProvider.resolveLocale(prefs);

  debugPrint('[main] Starting EnglishStudyApp');

  runApp(EnglishStudyApp(
    initialThemeMode: initialThemeMode,
    initialFontSizeLevel: initialFontSizeLevel,
    initialLocale: initialLocale,
  ));
}

class EnglishStudyApp extends StatelessWidget {
  final ThemeMode initialThemeMode;
  final FontSizeLevel initialFontSizeLevel;
  final Locale? initialLocale;

  const EnglishStudyApp({
    Key? key,
    required this.initialThemeMode,
    required this.initialFontSizeLevel,
    this.initialLocale,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint('[EnglishStudyApp] build – setting up MultiProvider');

    final writingApiService = WritingApiService();

    return MultiProvider(
      providers: [
        
        ChangeNotifierProvider<IeltsLevelProvider>(
          create: (_) {
            debugPrint('[main] IeltsLevelProvider created');
            return IeltsLevelProvider();
          },
        ),

        ChangeNotifierProvider<LocaleProvider>(
          create: (_) => LocaleProvider(initialLocale: initialLocale, preloaded: true),
        ),

        ChangeNotifierProvider<FavoriteManager>(
          create: (_) => FavoriteManager(),
        ),

        ChangeNotifierProvider<FontSizeProvider>(
          create: (_) {
            debugPrint('[main] FontSizeProvider created');
            return FontSizeProvider(initialLevel: initialFontSizeLevel);
          },
        ),
        
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(initialMode: initialThemeMode),
        ),

        ChangeNotifierProvider<VocabularyTestProvider>(
          create: (_) => VocabularyTestProvider(),
        ),

        ChangeNotifierProvider<RankingProvider>(
          create: (_) {
            debugPrint('[main] RankingProvider created');
            return RankingProvider();
          },
        ),

        
        ChangeNotifierProxyProvider<IeltsLevelProvider, VocabularyProvider>(
          create: (_) => VocabularyProvider(RealVocabularyRepository(VocabularyApiService())),
          update: (_, levelProvider, vocabProvider) {
            debugPrint(
                '[main] Level changed → ${levelProvider.selectedLevel.label} '
                '(${levelProvider.selectedLevel.band}) – reloading vocabulary');
            vocabProvider!.loadForBand(levelProvider.selectedLevel.band);
            return vocabProvider;
          },
        ),

        
        
        
        
        
        
        
        

        
        
        
        
        
        
        
        

        
        ChangeNotifierProxyProvider<IeltsLevelProvider, WritingProvider>(
          create: (_) => WritingProvider(RealWritingRepository(writingApiService)),
          update: (_, levelProvider, writingProvider) {
            writingProvider!.loadForBand(levelProvider.selectedLevel.band);
            return writingProvider;
          },
        ),

        ChangeNotifierProvider<TutoringProvider>(
          create: (_) => TutoringProvider(),
        ),
      ],
      child: Consumer3<LocaleProvider, FontSizeProvider, ThemeProvider>(
        builder: (context, localeProvider, fontSizeProvider, themeProvider, child) {
          debugPrint('[EnglishStudyApp] Consumer3 rebuild – Theme: ${themeProvider.themeMode}, Locale: ${localeProvider.locale}, FontScale: ${fontSizeProvider.fontScale}');
          return MaterialApp(
            title: 'IELTS PREP',
            debugShowCheckedModeBanner: false,
            
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(fontSizeProvider.fontScale),
                ),
                child: child!,
              );
            },
            locale: localeProvider.locale,
            supportedLocales: const [
              Locale('en', ''),
              Locale('vi', ''),
              Locale('zh', ''),
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            localeResolutionCallback: (locale, supportedLocales) {
              for (var supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale?.languageCode) {
                  return supportedLocale;
                }
              }
              return supportedLocales.first;
            },
            home: const LoginScreen(),
          );
        },
      ),
    );
  }
}