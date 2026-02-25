import 'package:flutter/material.dart';
import 'features/auth/screens/login_screen.dart';

void main() {
  runApp(const EnglishStudyApp());
}

class EnglishStudyApp extends StatelessWidget {
  const EnglishStudyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'English Study App Auth',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF161A23),
        fontFamily: 'Roboto',
      ),
      home: const LoginScreen(),
    );
  }
}