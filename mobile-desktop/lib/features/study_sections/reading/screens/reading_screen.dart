import 'package:flutter/material.dart';
import '../../widgets/unified_study_section_screen.dart';

class ReadingScreen extends StatelessWidget {
  const ReadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const UnifiedStudySectionScreen(
      skill: 'READING',
      title: 'Đọc hiểu',
    );
  }
}