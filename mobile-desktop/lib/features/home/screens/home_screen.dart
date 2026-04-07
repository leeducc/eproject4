import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/ielts_level_provider.dart';
import '../../../core/localization/app_localizations.dart';

import '../../study_sections/widgets/unified_study_section_screen.dart';
import '../../study_sections/writing/screens/topic_list_screen.dart';
import '../../study_sections/simulate_exam/screens/simulate_exam_screen.dart';
import '../../study_sections/real_exam/screens/real_exam_screen.dart';
import '../../study_sections/vocabulary/screens/vocabulary_screen.dart';
import '../../study_sections/wrong_answers/screens/wrong_answers_screen.dart';
import 'choose_level_screen.dart';
import '../widgets/notification_bell.dart';
import '../widgets/section_item.dart';
import '../../study_sections/speaking/screens/speaking_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint('[HomeScreen] build method entered');
    final levelProvider = context.watch<IeltsLevelProvider>();
    final currentLevel = levelProvider.selectedLevel;
    final theme = Theme.of(context);
    
    debugPrint('[HomeScreen] build – level: ${currentLevel.label}, theme: ${theme.brightness}');

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(context, currentLevel),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildActionBanner(context, currentLevel),
            const SizedBox(height: 24),
            _buildSectionsGrid(context),
            const SizedBox(height: 24),
            _buildProgressBanner(context, currentLevel),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, IeltsLevel currentLevel) {
    debugPrint('[HomeScreen] building AppBar');
    final l10n = AppLocalizations.of(context)!;
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Row(
        children: [
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: currentLevel.primaryColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                    color: currentLevel.primaryColor.withOpacity(0.4), width: 1.5),
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.withOpacity(0.3), width: 1),
            ),
            child: Row(
              children: [
                const Icon(Icons.stars_rounded, color: Colors.amber, size: 18),
                const SizedBox(width: 4),
                Text(l10n.translate('plus'),
                    style: const TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const NotificationBell(),
        ],
      ),
    );
  }

  Widget _buildActionBanner(BuildContext context, IeltsLevel currentLevel) {
    debugPrint('[HomeScreen] building Action Banner');
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [currentLevel.accentColor, currentLevel.primaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: currentLevel.primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l10n.translate('new_vocabulary'),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.translate('start_learning_now', params: {'range': currentLevel.range}),
                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13),
                ),
              ],
            ),
          ),
          Positioned(
            right: -10,
            bottom: -20,
            child: Icon(Icons.auto_stories, 
                size: 110, color: Colors.white.withOpacity(0.15)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionsGrid(BuildContext context) {
    debugPrint('[HomeScreen] building Sections Grid');
    final l10n = AppLocalizations.of(context)!;
    final List<Map<String, dynamic>> sections = [
      {
        'key': 'listening',
        'icon': Icons.headphones_rounded,
        'color': Colors.orangeAccent,
        'screen': UnifiedStudySectionScreen(
          skill: 'LISTENING',
          title: l10n.translate('listening'),
        )
      },
      {
        'key': 'reading',
        'icon': Icons.menu_book_rounded,
        'color': Colors.amber,
        'screen': UnifiedStudySectionScreen(
          skill: 'READING',
          title: l10n.translate('reading'),
        )
      },
      {
        'key': 'speaking',
        'icon': Icons.mic_none_rounded,
        'color': Colors.deepPurpleAccent,
        'screen': const SpeakingScreen()
      },
      {
        'key': 'writing',
        'icon': Icons.edit_note_rounded,
        'color': Colors.greenAccent.shade700,
        'screen': const TopicListScreen()
      },
      {
        'key': 'mock_exam',
        'icon': Icons.description_rounded,
        'color': Colors.lightBlueAccent,
        'screen': const SimulateExamScreen()
      },
      {
        'key': 'real_exam',
        'icon': Icons.assignment_rounded,
        'color': Colors.indigoAccent,
        'screen': const RealExamScreen()
      },
      {
        'key': 'vocabulary_section',
        'icon': Icons.abc_rounded,
        'color': Colors.blueAccent,
        'screen': const VocabularyScreen()
      },
      {
        'key': 'wrong_answers',
        'icon': Icons.report_gmailerrorred_rounded,
        'color': Colors.redAccent,
        'screen': const WrongAnswersScreen()
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 20,
        crossAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: sections.length,
      itemBuilder: (context, index) {
        final item = sections[index];
        final title = l10n.translate(item['key']);
        return SectionItem(
          icon: item['icon'] as IconData,
          title: title,
          color: item['color'] as Color,
          onTap: () {
            debugPrint('[HomeScreen] Navigating to: $title');
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => item['screen']),
            );
          },
        );
      },
    );
  }

  Widget _buildProgressBanner(BuildContext context, IeltsLevel currentLevel) {
    debugPrint('[HomeScreen] building Progress Banner');
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            currentLevel.primaryColor == kIeltsLevels[0].primaryColor 
                ? const Color(0xFFE94057) 
                : currentLevel.accentColor.withOpacity(0.8),
            currentLevel.primaryColor == kIeltsLevels[0].primaryColor
                ? const Color(0xFFF27121)
                : currentLevel.primaryColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.translate('guarantee_ielts_pass'),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              Icon(Icons.info_outline_rounded, color: Colors.white.withOpacity(0.6), size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.translate('course_description'),
            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: const LinearProgressIndicator(
                    value: 0.15, 
                    backgroundColor: Colors.white24,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 10,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white30, width: 1),
                ),
                child: Text(
                  l10n.translate('target_band', params: {'range': currentLevel.range}),
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}