import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../core/models/quiz_bank_models.dart';
import 'package:mobile_desktop/core_quiz/models/quiz_question.dart';
import 'package:mobile_desktop/core_quiz/widgets/dynamic_question_builder.dart';
import '../services/smart_test_api_service.dart';
import 'package:mobile_desktop/features/study_sections/services/moderation_service.dart';
import '../models/smart_test_models.dart';
import 'smart_test_summary_screen.dart';
import 'package:mobile_desktop/core/models/wrong_answer.dart';
import 'package:mobile_desktop/core/providers/wrong_answer_provider.dart';
import 'package:mobile_desktop/core/providers/theme_provider.dart';
import 'package:mobile_desktop/core/providers/font_size_provider.dart';
import 'package:mobile_desktop/features/study_sections/services/favorite_question_service.dart';
import 'package:provider/provider.dart';

class SmartTestActiveScreen extends StatefulWidget {
  final String skill;
  final String level;

  const SmartTestActiveScreen({super.key, required this.skill, required this.level});

  @override
  State<SmartTestActiveScreen> createState() => _SmartTestActiveScreenState();
}

class _SmartTestActiveScreenState extends State<SmartTestActiveScreen> {
  bool isLoading = true;
  List<Question> questions = [];
  Map<int, String> userAnswers = {};
  
  Timer? _timer;
  int _secondsRemaining = 600;

  final PageController _pageController = PageController();
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final fetched = await SmartTestApiService().generateSmartTest(widget.skill, widget.level);
      if (!mounted) return;
      setState(() {
        questions = fetched;
        isLoading = false;
      });
      _startTimer();
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        if (mounted) {
          setState(() {
            _secondsRemaining--;
          });
        }
      } else {
        _timer?.cancel();
        _submitTest();
      }
    });
  }

  Future<void> _submitTest() async {
    _timer?.cancel();
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
    
    try {
      final wrongAnswerProvider = context.read<WrongAnswerProvider>();
      final attempts = questions.map((q) {
        String ans = userAnswers[q.id] ?? "";
        bool isCorrect = _checkAnswerMock(q, ans);
        
        if (!isCorrect) {
          final quizQ = QuizQuestion.from(q);
          wrongAnswerProvider.addWrongAnswer(WrongAnswer(
            questionId: q.id,
            skill: widget.skill,
            questionTitle: q.instruction,
            instruction: 'Smart Test - ${widget.skill}',
            userAnswer: ans,
            correctAnswers: quizQ.correctIds,
            explanation: q.explanation,
            originalJson: quizQ.data,
            timestamp: DateTime.now(),
          ));
        }
        
        return QuestionAttemptDTO(questionId: q.id, userAnswer: ans, isCorrect: isCorrect);
      }).toList();
      
      final req = SmartTestSubmitRequest(skill: widget.skill, difficultyBand: widget.level, attempts: attempts);
      debugPrint('[SmartTestActiveScreen] Submitting test payload: ${jsonEncode(req.toJson())}');
      
      final res = await SmartTestApiService().submitSmartTest(req);
      debugPrint('[SmartTestActiveScreen] Test submitted successfully. SessionId: ${res.sessionId}');
      
      if (!mounted) return;
      Navigator.pop(context); // pop loading dialog
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SmartTestSummaryScreen(response: res)));
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // pop loading dialog
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Submit Error: $e')));
      }
    }
  }
  
  bool _checkAnswerMock(Question q, String answer) {
      final quizQ = QuizQuestion.from(q);
      if (quizQ.correctIds.isNotEmpty) {
        return answer == quizQ.correctIds.first;
      }
      return answer.isNotEmpty; 
  }

  void _showSettingsMenu() {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.bookmark_border_rounded, color: theme.colorScheme.onSurface),
              title: Text('Lưu câu hỏi', style: TextStyle(color: theme.colorScheme.onSurface)),
              onTap: () async {
                Navigator.pop(context);
                final q = questions[_currentPageIndex];
                try {
                  final bool isNowFavorite = await FavoriteQuestionService().toggleFavorite(q.id);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isNowFavorite ? 'Đã lưu câu hỏi vào danh sách yêu thích!' : 'Đã xóa câu hỏi khỏi danh sách yêu thích!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lỗi: Không thể lưu câu hỏi. $e')),
                    );
                  }
                }
              },
            ),
            ListTile(
               leading: Icon(Icons.flag_outlined, color: theme.colorScheme.onSurface),
               title: Text('Báo cáo đề sai', style: TextStyle(color: theme.colorScheme.onSurface)),
               onTap: () {
                 Navigator.pop(context);
                 _showReportDialog(questions[_currentPageIndex]);
               },
             ),
             Divider(color: theme.dividerColor, height: 32),
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceAround,
               children: [
                 _buildFontOption("Aa", 14, FontSizeLevel.small, context.read<FontSizeProvider>().level == FontSizeLevel.small),
                 _buildFontOption("Aa", 18, FontSizeLevel.medium, context.read<FontSizeProvider>().level == FontSizeLevel.medium),
                 _buildFontOption("Aa", 22, FontSizeLevel.large, context.read<FontSizeProvider>().level == FontSizeLevel.large),
               ],
             ),
             const SizedBox(height: 24),
             Row(
               children: [
                 Expanded(
                   child: _buildModeOption(
                     Icons.wb_sunny_outlined, 
                     "Ban ngày", 
                     theme.brightness == Brightness.light,
                     onTap: () {
                       context.read<ThemeProvider>().setThemeMode(ThemeMode.light);
                       Navigator.pop(context);
                     },
                   ),
                 ),
                 const SizedBox(width: 16),
                 Expanded(
                   child: _buildModeOption(
                     Icons.nightlight_round, 
                     "Chế độ ban đêm", 
                     theme.brightness == Brightness.dark,
                     onTap: () {
                       context.read<ThemeProvider>().setThemeMode(ThemeMode.dark);
                       Navigator.pop(context);
                     },
                   ),
                 ),
               ],
             )
          ],
        ),
      ),
    );
  }

  Widget _buildFontOption(String label, double size, FontSizeLevel level, bool isSelected) {
    final theme = Theme.of(context);
    final accentColor = theme.colorScheme.primary;
    return GestureDetector(
      onTap: () {
        context.read<FontSizeProvider>().setFontSizeLevel(level);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
           color: isSelected ? accentColor.withValues(alpha: 0.1) : Colors.transparent,
           borderRadius: BorderRadius.circular(10),
           border: Border.all(color: isSelected ? accentColor : theme.dividerColor),
        ),
        child: Text(label, style: TextStyle(color: isSelected ? accentColor : theme.colorScheme.onSurface, fontSize: size)),
      ),
    );
  }

  Widget _buildModeOption(IconData icon, String label, bool isSelected, {VoidCallback? onTap}) {
    final theme = Theme.of(context);
    final accentColor = theme.colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? accentColor.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? accentColor : theme.dividerColor),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? accentColor : theme.colorScheme.onSurface),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: isSelected ? accentColor : theme.colorScheme.onSurface, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  void _showReportDialog(Question q) {
      final theme = Theme.of(context);
      final TextEditingController reasonController = TextEditingController();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: theme.cardColor,
          title: Text('Report Question', style: TextStyle(color: theme.colorScheme.onSurface)),
          content: TextField(
            controller: reasonController,
            maxLines: 3,
            style: TextStyle(color: theme.colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: "Describe the issue...", 
              hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.3)),
              border: const OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: theme.dividerColor)),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                String reason = reasonController.text.trim();
                if (reason.isEmpty) return;
                try {
                  await ModerationService().submitReport("QUESTION", q.id, reason);
                  Navigator.pop(context);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report Submitted!')));
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))));
                  }
                }
              },
              child: const Text('Submit'),
            )
          ],
        ),
      );
  }

  Future<bool> _onWillPop() async {
    final theme = Theme.of(context);
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardColor,
        title: Text('Are you sure?', style: TextStyle(color: theme.colorScheme.onSurface)),
        content: Text('Your test is running. Do you want to exit without saving?', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7))),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () {
            _timer?.cancel();
            Navigator.of(context).pop(true);
          }, child: const Text('Exit')),
        ],
      ),
    ) ?? false;
  }

  String get _formattedTime {
    int m = _secondsRemaining ~/ 60;
    int s = _secondsRemaining % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Hết giờ:", style: TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Text(_formattedTime, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 20)),
              const SizedBox(width: 12),
              if (questions.isNotEmpty)
                Text("${_currentPageIndex + 1}/${questions.length}", style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 16)),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.more_horiz, color: theme.colorScheme.onSurface),
              onPressed: _showSettingsMenu,
            )
          ],
        ),
        body: isLoading 
            ? Center(child: CircularProgressIndicator(color: theme.colorScheme.primary))
            : questions.isEmpty 
               ? Center(child: Text("No questions generated.", style: TextStyle(color: theme.colorScheme.onSurface)))
               : PageView.builder(
                   controller: _pageController,
                   onPageChanged: (idx) {
                     debugPrint('[SmartTestActiveScreen] Page changed to $idx');
                     setState(() => _currentPageIndex = idx);
                   },
                   itemCount: questions.length,
                   itemBuilder: (context, index) {
                      final q = questions[index];
                      final hasAnswer = userAnswers.containsKey(q.id);
                      return SmartQuestionCard(
                        question: q,
                        index: index,
                        total: questions.length,
                        selectedAnswerId: userAnswers[q.id],
                        isAnswered: hasAnswer,
                        onAnswer: (val) {
                          if (val == null || val.isEmpty) return;
                          debugPrint('[SmartTestActiveScreen] Storing answer for question ${q.id}: $val');
                          setState(() {
                            userAnswers[q.id] = val;
                          });
                        },
                        isLast: index == questions.length - 1,
                        onSubmit: _submitTest,
                      );
                    },
                  ),
        ),
      );
  }
}

class SmartQuestionCard extends StatelessWidget {
  final Question question;
  final int index;
  final int total;
  final String? selectedAnswerId;
  final bool isAnswered;
  final Function(String?) onAnswer;
  final bool isLast;
  final VoidCallback onSubmit;

  const SmartQuestionCard({
    super.key,
    required this.question,
    required this.index,
    required this.total,
    this.selectedAnswerId,
    required this.isAnswered,
    required this.onAnswer,
    required this.isLast,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint('[SmartQuestionCard] Building card for question id=${question.id}, type=${question.type}, isAnswered=$isAnswered');
    final quizQ = QuizQuestion.from(question);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Câu ${index + 1}",
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.more_horiz, color: theme.colorScheme.onSurface.withOpacity(0.8)),
                onPressed: () => _showQuestionActionMenu(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Use DynamicQuestionBuilder to handle ALL question types
          // (multipleChoice, fillBlank, matching) correctly
          DynamicQuestionBuilder(
            question: quizQ,
            selectedId: selectedAnswerId,
            isAnswered: isAnswered,
            onAnswer: (val) {
              debugPrint('[SmartQuestionCard] Answer selected: question=${question.id}, val=$val');
              onAnswer(val);
            },
          ),

          if (isLast)
            Padding(
               padding: const EdgeInsets.only(top: 40, bottom: 40),
               child: ElevatedButton(
                 style: ElevatedButton.styleFrom(
                   minimumSize: const Size(double.infinity, 55),
                   backgroundColor: Theme.of(context).colorScheme.primary,
                   foregroundColor: Theme.of(context).colorScheme.onPrimary,
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                   elevation: 4,
                 ),
                 onPressed: onSubmit,
                 child: const Text("HOÀN THÀNH", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
               ),
            ),
        ],
      ),
    );
  }

  void _showQuestionActionMenu(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.bookmark_border_rounded, color: theme.colorScheme.onSurface),
              title: Text('Lưu câu hỏi', style: TextStyle(color: theme.colorScheme.onSurface)),
              onTap: () async {
                Navigator.pop(context);
                try {
                  final bool isNowFavorite = await FavoriteQuestionService().toggleFavorite(question.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isNowFavorite ? 'Đã lưu câu hỏi vào danh sách yêu thích!' : 'Đã xóa câu hỏi khỏi danh sách yêu thích!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lỗi: Không thể lưu câu hỏi. $e')),
                    );
                  }
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.flag_outlined, color: theme.colorScheme.onSurface),
              title: Text('Báo cáo đề sai', style: TextStyle(color: theme.colorScheme.onSurface)),
              onTap: () {
                Navigator.pop(context);
                // We'll call the report dialog from the stateful parent
                // by finding the state in the context or passing a callback
                _triggerReport(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _triggerReport(BuildContext context) {
    // Find the state of SmartTestActiveScreen to call its internal _showReportDialog
    final state = context.findAncestorStateOfType<_SmartTestActiveScreenState>();
    if (state != null) {
      state._showReportDialog(question);
    }
  }
}
