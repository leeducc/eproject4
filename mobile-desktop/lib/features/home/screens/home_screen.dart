import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/ielts_level_provider.dart';
import '../../study_sections/listening/screens/listening_screen.dart';
import '../../study_sections/reading/screens/reading_screen.dart';
import '../../study_sections/writing/screens/topic_list_screen.dart';
import '../../study_sections/speaking/screens/speaking_screen.dart';
import '../../study_sections/simulate_exam/screens/simulate_exam_screen.dart';
import '../../study_sections/real_exam/screens/real_exam_screen.dart';
import '../../study_sections/vocabulary/screens/vocabulary_screen.dart';
import '../../study_sections/wrong_answers/screens/wrong_answers_screen.dart';
import 'choose_level_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Watch the provider so the AppBar title re-renders on level change
    final levelProvider = context.watch<IeltsLevelProvider>();
    final currentLevel = levelProvider.selectedLevel;
    debugPrint('[HomeScreen] build – level: ${currentLevel.label}');

    return Scaffold(
      backgroundColor: const Color(0xFF161A23),
      appBar: _buildAppBar(context, currentLevel),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBanner(currentLevel),
            const SizedBox(height: 24),
            _buildSectionsGrid(context),
            const SizedBox(height: 24),
            _buildProgressCard(currentLevel),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, IeltsLevel currentLevel) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Row(
        children: [
          // ── Tappable level dropdown ──────────────────────────────
          GestureDetector(
            onTap: () {
              debugPrint('[HomeScreen] Level dropdown tapped');
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const ChooseLevelScreen(),
                  transitionsBuilder: (_, animation, __, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                              begin: const Offset(0, 1), end: Offset.zero)
                          .animate(CurvedAnimation(
                              parent: animation, curve: Curves.easeOutCubic)),
                      child: child,
                    );
                  },
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: currentLevel.primaryColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: currentLevel.primaryColor.withOpacity(0.4), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'IELTS ${currentLevel.range}',
                    style: TextStyle(
                      color: currentLevel.primaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_drop_down,
                      color: currentLevel.primaryColor, size: 20),
                ],
              ),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 16),
                SizedBox(width: 4),
                Text('PLUS',
                    style: TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          const Icon(Icons.notifications_none, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildBanner(IeltsLevel currentLevel) {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [currentLevel.accentColor, currentLevel.primaryColor],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'New Vocabulary',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 8),
                Text(
                  'IELTS ${currentLevel.range} – Start learning now!',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
          Positioned(
            right: -10,
            bottom: -20,
            child: Icon(Icons.menu_book,
                size: 110, color: Colors.white.withOpacity(0.2)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionsGrid(BuildContext context) {
    final List<Map<String, dynamic>> sections = [
      {
        'title': 'Listening',
        'icon': Icons.headphones,
        'color': Colors.orange,
        'screen': const ListeningScreen()
      },
      {
        'title': 'Speaking',
        'icon': Icons.mic_none,
        'color': Colors.purple,
        'screen': const SpeakingScreen()
      },
      {
        'title': 'Reading',
        'icon': Icons.menu_book,
        'color': Colors.yellow.shade700,
        'screen': const ReadingScreen()
      },
      {
        'title': 'Writing',
        'icon': Icons.edit_document,
        'color': Colors.green,
        'screen': const TopicListScreen()
      },
      {
        'title': 'Mock Exam',
        'icon': Icons.insert_drive_file,
        'color': Colors.lightBlue,
        'screen': const SimulateExamScreen()
      },
      {
        'title': 'Real Exam',
        'icon': Icons.assignment,
        'color': Colors.indigo,
        'screen': const RealExamScreen()
      },
      {
        'title': 'Vocabulary',
        'icon': Icons.abc,
        'color': Colors.blueAccent,
        'screen': const VocabularyScreen()
      },
      {
        'title': 'Wrong Answers',
        'icon': Icons.fact_check,
        'color': Colors.redAccent,
        'screen': const WrongAnswersScreen()
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: sections.length,
      itemBuilder: (context, index) {
        final item = sections[index];
        return GestureDetector(
          onTap: () {
            debugPrint('[HomeScreen] Section tapped: ${item['title']}');
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => item['screen']),
            );
          },
          child: Column(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: (item['color'] as Color).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(item['icon'] as IconData,
                    color: item['color'] as Color, size: 28),
              ),
              const SizedBox(height: 8),
              Text(
                item['title'],
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressCard(IeltsLevel currentLevel) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFFE94057), Color(0xFFF27121)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Guarantee IELTS Pass',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              Icon(Icons.info_outline, color: Colors.white54, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'A course designed by experienced teachers to help you reach your target band.',
            style: TextStyle(color: Colors.white, fontSize: 13),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: const LinearProgressIndicator(
                    value: 0.1,
                    backgroundColor: Colors.white24,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Target ${currentLevel.range}',
                  style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 10),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}