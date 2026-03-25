import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/quiz_bank_models.dart';
import '../providers/exam_provider.dart';
import 'question_renderer.dart';
import 'question_map_sheet.dart';
import 'exam_section_widgets.dart';

class ReadingSectionView extends StatefulWidget {
  const ReadingSectionView({Key? key}) : super(key: key);

  @override
  State<ReadingSectionView> createState() => _ReadingSectionViewState();
}

class _ReadingSectionViewState extends State<ReadingSectionView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _pageController = PageController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExamProvider>(
      builder: (context, provider, _) {
        final state = provider.state;
        if (state == null) return const SizedBox.shrink();

        // Flatten all READING questions maintaining group context
        final List<_ReadingQuestion> flatQuestions = [];
        for (var group in (state.exam.groups ?? []).where((g) => g.skill == SkillType.READING)) {
          for (var q in group.questions) {
            flatQuestions.add(_ReadingQuestion(q, group));
          }
        }
        for (var q in (state.exam.questions ?? []).where((q) => q.skill == SkillType.READING)) {
          flatQuestions.add(_ReadingQuestion(q, null));
        }

        if (flatQuestions.isEmpty) {
          return const Center(child: Text('No reading questions.', style: TextStyle(color: Colors.white70)));
        }

        final targetIndex = state.currentQuestionIndex.clamp(0, flatQuestions.length - 1);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_pageController.hasClients && _pageController.page?.round() != targetIndex) {
            _pageController.animateToPage(targetIndex,
                duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
          }
        });

        final current = flatQuestions[targetIndex];
        final isFlagged = provider.isFlagged(current.question.id);
        final passageText = current.group?.content ?? '';

        return Column(
          children: [
            // ── Tab Toggle: Passage | Questions ─────────────────────────────
            Container(
              margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.07),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(10),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white54,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                tabs: [
                  Tab(
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.article_outlined, size: 14),
                      const SizedBox(width: 6),
                      Text(current.group?.title.split(' ').take(3).join(' ') ?? 'Passage'),
                    ]),
                  ),
                  Tab(
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.quiz_outlined, size: 14),
                      const SizedBox(width: 6),
                      Text('Q${targetIndex + 1} of ${flatQuestions.length}'),
                    ]),
                  ),
                ],
              ),
            ),

            // ── Header bar (flag + map) ──────────────────────────────────────
            ExamSectionHeader(
              title: current.group?.title ?? 'Reading',
              current: targetIndex,
              total: flatQuestions.length,
              isFlagged: isFlagged,
              onFlag: () => provider.toggleFlag(current.question.id),
              onMap: () => QuestionMapSheet.show(
                context,
                flatQuestions.map((e) => e.question).toList(),
                targetIndex,
              ),
            ),

            // ── Tab Content ─────────────────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(), // swipe handled by PageView
                children: [
                  // Passage tab
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (current.group != null) ...[
                          Text(
                            current.group!.title,
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                        ],
                        if (passageText.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E2330),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: SelectableText(
                              passageText,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                height: 1.7,
                              ),
                            ),
                          )
                        else
                          const Text('No passage for this question.', style: TextStyle(color: Colors.white38)),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),

                  // Questions tab — swipeable PageView
                  Column(
                    children: [
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: flatQuestions.length,
                          onPageChanged: (index) {
                            print('[ReadingSectionView] Swiped to index $index');
                            provider.jumpToQuestion(index);
                          },
                          itemBuilder: (context, index) {
                            final item = flatQuestions[index];
                            return SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Quick passage reference chip
                                  if (item.group != null)
                                    GestureDetector(
                                      onTap: () => _tabController.animateTo(0),
                                      child: Container(
                                        margin: const EdgeInsets.only(bottom: 12),
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: Colors.blueAccent.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
                                        ),
                                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                                          const Icon(Icons.article_outlined, size: 12, color: Colors.blueAccent),
                                          const SizedBox(width: 6),
                                          Text('Tap to read passage', style: const TextStyle(color: Colors.blueAccent, fontSize: 11)),
                                        ]),
                                      ),
                                    ),
                                  QuestionRenderer(question: item.question, indexPrefix: index + 1),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Nav Controls ────────────────────────────────────────────────
            ExamPageNavBar(
              currentIndex: targetIndex,
              total: flatQuestions.length,
              onPrev: () {
                provider.prevQuestion();
                _tabController.animateTo(1); // switch to Questions tab
              },
              onNext: () {
                provider.nextQuestion(flatQuestions.length);
                _tabController.animateTo(1);
              },
            ),
          ],
        );
      },
    );
  }
}

class _ReadingQuestion {
  final Question question;
  final QuestionGroup? group;
  _ReadingQuestion(this.question, this.group);
}
