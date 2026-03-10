import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'core/providers/ielts_level_provider.dart';
import 'features/auth/screens/login_screen.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const EnglishStudyApp());
}

class EnglishStudyApp extends StatelessWidget {
  const EnglishStudyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint('[EnglishStudyApp] build – wrapping with IeltsLevelProvider');
    return ChangeNotifierProvider(
      create: (_) => IeltsLevelProvider(),
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