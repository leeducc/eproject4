import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import 'package:mobile_desktop/core_quiz/models/quiz_question.dart';
import 'package:mobile_desktop/core_quiz/widgets/dynamic_question_builder.dart';
import 'package:mobile_desktop/features/ranking/providers/ranking_provider.dart';
import 'package:mobile_desktop/core/models/app_section_model.dart';
import '../../services/question_bank_api_service.dart';
import '../../services/app_config_api_service.dart';
import '../../widgets/unified_result_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_desktop/core/providers/font_size_provider.dart';
import 'package:mobile_desktop/core/providers/theme_provider.dart';
import '../../services/moderation_service.dart';
import 'package:mobile_desktop/core/models/wrong_answer.dart';
import 'package:mobile_desktop/core/providers/wrong_answer_provider.dart';
import 'package:mobile_desktop/features/study_sections/services/favorite_question_service.dart';
import '../../../../data/services/auth_api.dart';


class ListeningExamScreen extends StatefulWidget {
  final String title;
  final int groupId;
  final AppSectionModel section;

  const ListeningExamScreen({
    super.key,
    required this.title,
    required this.groupId,
    required this.section,
  });

  @override
  State<ListeningExamScreen> createState() => _ListeningExamScreenState();
}

class _ListeningExamScreenState extends State<ListeningExamScreen> {
  late int startTime;
  late PageController pageController;
  int currentIndex = 0;

  bool isLoading = true;
  List<QuizQuestion> questions = [];
  Map<int, String?> userAnswers = {}; // Persist state across swipes
  List<Map<String, dynamic>> userAttempts = [];

  @override
  void initState() {
    super.initState();
    currentIndex = 0;
    pageController = PageController(initialPage: currentIndex);
    startTime = DateTime.now().millisecondsSinceEpoch;
    _loadQuestions();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    try {
      final fetched = await QuestionBankApiService().fetchByTags(
        widget.section.tags ?? [],
        skill: 'LISTENING',
      );
      
      final solvedIds = await AppConfigApiService().getSolvedQuestionIds();
      
      if (!mounted) return;
      setState(() {
        questions = fetched.map((q) {
          final isSolved = solvedIds.contains(q.id);
          return QuizQuestion.from(q, isSolved: isSolved);
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> submitExam() async {
    int finalScore = 0;
    List<Map<String, dynamic>> finalAttempts = [];

    for (int i = 0; i < questions.length; i++) {
      final q = questions[i];
      final answerId = userAnswers[i];
      if (answerId != null) {
        bool isCorrect = q.isCorrectChoice(answerId);
        finalAttempts.add({
          'questionId': q.id,
          'userAnswer': answerId,
          'isCorrect': isCorrect,
        });
        if (isCorrect && !q.isAlreadySolved) {
          finalScore++;
        } else if (!isCorrect) {
          // Record wrong answer
          context.read<WrongAnswerProvider>().addWrongAnswer(WrongAnswer(
            questionId: q.id,
            skill: 'LISTENING',
            questionTitle: q.instruction,
            instruction: widget.title,
            userAnswer: answerId,
            correctAnswers: q.correctIds,
            explanation: q.explanation,
            originalJson: q.data,
            timestamp: DateTime.now(),
          ));
        }
      } else {
        // Unanswered
        finalAttempts.add({
          'questionId': q.id,
          'userAnswer': null,
          'isCorrect': false,
        });
      }
    }

    int totalTime = (DateTime.now().millisecondsSinceEpoch - startTime) ~/ 1000;
    debugPrint('[ListeningExamScreen] submitting exam — score=$finalScore, total=${questions.length}');
    context.read<RankingProvider>().recordAnswers(finalScore);

    await _reportStats(finalScore, questions.length, finalAttempts);

    final prefs = await SharedPreferences.getInstance();
    prefs.setInt("totalAnswers", (prefs.getInt("totalAnswers") ?? 0) + questions.length);
    prefs.setInt("correctAnswers", (prefs.getInt("correctAnswers") ?? 0) + finalScore);
    prefs.setInt("totalTime", (prefs.getInt("totalTime") ?? 0) + totalTime);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => UnifiedResultScreen(
          score: finalScore,
          total: questions.length,
          time: totalTime,
          skill: 'LISTENING',
        ),
      ),
    );
  }

  Future<void> _reportStats(int correct, int total, List<Map<String, dynamic>> attempts) async {
    try {
      final token = await AuthApi.getToken();
      final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8123/api';
      final url = '$baseUrl/v1/section-stats/${widget.section.id}/record';
      debugPrint('[ListeningExamScreen] _reportStats → POST $url');
      debugPrint('[ListeningExamScreen]   correct=$correct, total=$total, attempts=${attempts.length}');
      debugPrint('[ListeningExamScreen]   payload=${jsonEncode({'count': correct, 'attempts': attempts})}');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'count': correct,
          'attempts': attempts,
        }),
      );
      debugPrint('[ListeningExamScreen] _reportStats ← HTTP ${response.statusCode}: ${response.body}');
    } catch (e) {
      debugPrint('[ListeningExamScreen] _reportStats error: $e');
    }
  }

  void _showSectionGuide() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, controller) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Bí kíp: ${widget.section.sectionName}",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF42A5F5)),
                  ),
                ),
                const Divider(),
                Expanded(
                  child: SingleChildScrollView(
                    controller: controller,
                    padding: const EdgeInsets.all(16.0),
                    child: Html(
                      data: widget.section.guideContent ?? "<p>No guide provided yet.</p>",
                      style: {
                        "p": Style(fontSize: FontSize(15), color: Colors.black87),
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSettingsMenu() {
    final fontSizeProvider = context.read<FontSizeProvider>();
    final themeProvider = context.read<ThemeProvider>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).bottomSheetTheme.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _settingsItem(context, Icons.bookmark_border, "Lưu câu hỏi", () async {
                    Navigator.pop(context);
                    final q = questions[currentIndex];
                    try {
                      final bool isNowFavorite = await FavoriteQuestionService().toggleFavorite(q.id);
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
                  }),
                  _settingsItem(context, Icons.flag_outlined, "Báo cáo đề sai", () {
                    Navigator.pop(context);
                    _showReportDialog();
                  }),
                  const Divider(color: Colors.white10),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _fontSizeOption(FontSizeLevel.small, "Aa", 14),
                        _fontSizeOption(FontSizeLevel.medium, "Aa", 18),
                        _fontSizeOption(FontSizeLevel.large, "Aa", 22),
                      ],
                    ),
                  ),
                  const Divider(color: Colors.white10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _themeOption(
                        Icons.wb_sunny_outlined, 
                        "Ban ngày", 
                        themeProvider.themeMode == ThemeMode.light || (themeProvider.themeMode == ThemeMode.system && MediaQuery.of(context).platformBrightness == Brightness.light),
                        () => themeProvider.setThemeMode(ThemeMode.light),
                      ),
                      _themeOption(
                        Icons.nightlight_round, 
                        "Chế độ ban đêm", 
                        themeProvider.themeMode == ThemeMode.dark || (themeProvider.themeMode == ThemeMode.system && MediaQuery.of(context).platformBrightness == Brightness.dark),
                        () => themeProvider.setThemeMode(ThemeMode.dark),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          }
        );
      },
    );
  }

  Widget _fontSizeOption(FontSizeLevel level, String label, double size) {
    final provider = context.watch<FontSizeProvider>();
    final isSelected = provider.level == level;
    return GestureDetector(
      onTap: () => provider.setFontSizeLevel(level),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? const Color(0xFF42A5F5) : Colors.grey,
          fontSize: size,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  void _showReportDialog() {
    final question = questions[currentIndex];
    final TextEditingController reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Báo cáo đề sai'),
        content: TextField(
          controller: reasonController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: "Mô tả lỗi của câu hỏi này...",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              String reason = reasonController.text.trim();
              if (reason.isEmpty) return;
              try {
                await ModerationService().submitReport("QUESTION", question.id, reason);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cảm ơn bạn đã báo cáo!')));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))));
              }
            },
            child: const Text('Gửi'),
          )
        ],
      ),
    );
  }

  Widget _settingsItem(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.onSurface),
      title: Text(label, style: TextStyle(color: theme.colorScheme.onSurface)),
      onTap: onTap,
    );
  }

  Widget _themeOption(IconData icon, String label, bool isSelected, VoidCallback onTap) {
    final theme = Theme.of(context);
    final accentColor = const Color(0xFF42A5F5);
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: isSelected ? accentColor : theme.colorScheme.onSurface.withOpacity(0.6)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: isSelected ? accentColor : theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 12)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF1E212A),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (questions.isEmpty) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color), onPressed: () => Navigator.pop(context)),
        ),
        body: Center(child: Text("No questions available for this section.", style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color))),
      );
    }

    final question = questions[currentIndex];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildCustomHeader(),
            Expanded(
              child: PageView.builder(
                controller: pageController,
                onPageChanged: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  final q = questions[index];
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        DynamicQuestionBuilder(
                          question: q,
                          selectedId: userAnswers[index],
                          isAnswered: userAnswers[index] != null,
                          onAnswer: (id) {
                            debugPrint('[ListeningExamScreen] Page $index Selected: $id');
                            setState(() {
                              userAnswers[index] = id;
                            });
                          },
                        ),
                        const SizedBox(height: 80), // Space for bottom button
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              if (currentIndex < questions.length - 1) {
                pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              } else {
                submitExam();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF42A5F5),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 0,
            ),
            child: Text(
              currentIndex < questions.length - 1 ? "Tiếp tục" : "Hoàn thành",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              widget.title,
              style: TextStyle(color: Theme.of(context).textTheme.titleLarge?.color, fontSize: 16, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: Icon(Icons.help_outline, color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.7), size: 22),
            onPressed: _showSectionGuide,
          ),
          Text(
            "${currentIndex + 1}/${questions.length}",
            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7), fontSize: 14),
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.7)),
            onPressed: _showSettingsMenu,
          ),
        ],
      ),
    );
  }
}