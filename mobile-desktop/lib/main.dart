import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/providers/ielts_level_provider.dart';
import 'core/providers/locale_provider.dart';
import 'core/providers/font_size_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/localization/app_localizations.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/study_sections/listening/services/listening_provider.dart';
import 'features/study_sections/writing/services/writing_api_service.dart';
import 'features/study_sections/writing/services/real_writing_repository.dart';
import 'features/study_sections/writing/services/writing_provider.dart';
import 'features/study_sections/vocabulary/providers/vocabulary_provider.dart';
import 'features/study_sections/vocabulary/repositories/real_vocabulary_repository.dart';
import 'features/study_sections/vocabulary/services/vocabulary_api_service.dart';
import 'features/study_sections/vocabulary/screens/favorite_manager.dart';
import 'features/study_sections/vocabulary/providers/vocabulary_test_provider.dart';
import 'features/ranking/providers/ranking_provider.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const EnglishStudyApp());
}

class EnglishStudyApp extends StatelessWidget {
  const EnglishStudyApp({Key? key}) : super(key: key);

  Widget build(BuildContext context) {
    debugPrint('[EnglishStudyApp] build – setting up MultiProvider');

    final writingApiService = WritingApiService();

    return MultiProvider(
      providers: [
        // ── Global level state ───────────────────────────────────
        ChangeNotifierProvider<IeltsLevelProvider>(
          create: (_) {
            debugPrint('[main] IeltsLevelProvider created');
            return IeltsLevelProvider();
          },
        ),

        ChangeNotifierProvider<LocaleProvider>(
          create: (_) => LocaleProvider(),
        ),

        ChangeNotifierProvider<FavoriteManager>(
          create: (_) => FavoriteManager(),
        ),

        ChangeNotifierProvider<FontSizeProvider>(
          create: (_) {
            debugPrint('[main] FontSizeProvider created');
            return FontSizeProvider();
          },
        ),
        
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
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

        // ── Vocabulary section ───────────────────────────────────
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

        // // ── Reading section ───────────────────────────────────
        // ChangeNotifierProxyProvider<IeltsLevelProvider, ReadingProvider>(
        //   create: (_) => ReadingProvider(MockReadingRepository()),
        //   update: (_, levelProvider, readingProvider) {
        //     readingProvider!.loadForBand(levelProvider.selectedLevel.band);
        //     return readingProvider;
        //   },
        // ),

        // ── Listening section ───────────────────────────────────
        ChangeNotifierProxyProvider<IeltsLevelProvider, ListeningProvider>(
          create: (_) => ListeningProvider(MockListeningRepository()),
          update: (_, levelProvider, listeningProvider) {
            listeningProvider!.loadForBand(levelProvider.selectedLevel.band);
            return listeningProvider;
          },
        ),

        // ── Writing section ───────────────────────────────────
        ChangeNotifierProxyProvider<IeltsLevelProvider, WritingProvider>(
          create: (_) => WritingProvider(RealWritingRepository(writingApiService)),
          update: (_, levelProvider, writingProvider) {
            writingProvider!.loadForBand(levelProvider.selectedLevel.band);
            return writingProvider;
          },
        ),
      ],
      child: Consumer3<LocaleProvider, FontSizeProvider, ThemeProvider>(
        builder: (context, localeProvider, fontSizeProvider, themeProvider, child) {
          return MaterialApp(
            title: 'English Study App',
            debugShowCheckedModeBanner: false,
            // ── Dynamic Theme Setup ─────────────────────────────────
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaleFactor: fontSizeProvider.fontScale,
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