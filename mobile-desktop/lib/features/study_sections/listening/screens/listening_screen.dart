import 'package:flutter/material.dart';
import '../../widgets/unified_study_section_screen.dart';

class ListeningScreen extends StatelessWidget {
  const ListeningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const UnifiedStudySectionScreen(
      skill: 'LISTENING',
      title: 'Nghe hiểu',
    );
  }
}
