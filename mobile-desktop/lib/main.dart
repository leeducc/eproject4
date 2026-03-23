import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'core/providers/ielts_level_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/study_sections/listening/services/mock_listening_repository.dart';
import 'features/study_sections/listening/services/listening_provider.dart';
import 'features/study_sections/writing/services/writing_api_service.dart';
import 'features/study_sections/writing/services/real_writing_repository.dart';
import 'features/study_sections/writing/services/writing_provider.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const EnglishStudyApp());
}

class EnglishStudyApp extends StatelessWidget {
  const EnglishStudyApp({Key? key}) : super(key: key);

  @override
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

        // ── Vocabulary section ───────────────────────────────────
        // ChangeNotifierProxyProvider automatically calls update()
        // every time IeltsLevelProvider.notifyListeners() fires,
        // which triggers VocabularyProvider.loadForBand(newBand).
        // ChangeNotifierProxyProvider<IeltsLevelProvider, VocabularyProvider>(
        //   create: (_) => VocabularyProvider(MockVocabularyRepository()),
        //   update: (_, levelProvider, vocabProvider) {
        //     debugPrint(
        //         '[main] Level changed → ${levelProvider.selectedLevel.label} '
        //         '(${levelProvider.selectedLevel.band}) – reloading vocabulary');
        //     // Fire-and-forget; VocabularyProvider manages its own state
        //     vocabProvider!.loadForBand(levelProvider.selectedLevel.band);
        //     return vocabProvider;
        //   },
        // ),

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
      child: MaterialApp(
        title: 'English Study App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF161A23),
          fontFamily: 'Roboto',
        ),
        home: const LoginScreen(),
      ),
    );
  }
}