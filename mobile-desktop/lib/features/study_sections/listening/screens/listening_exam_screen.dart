import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import 'package:mobile_desktop/core_quiz/models/quiz_question.dart';
import 'package:mobile_desktop/core_quiz/widgets/dynamic_question_builder.dart';
import 'package:mobile_desktop/features/ranking/providers/ranking_provider.dart';
import 'package:mobile_desktop/core/models/app_section_model.dart';
import '../../services/question_bank_api_service.dart';
import '../../widgets/unified_result_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_desktop/core/providers/font_size_provider.dart';
import 'package:mobile_desktop/core/providers/theme_provider.dart';
import '../../services/moderation_service.dart';


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
  int currentIndex = 0;
  String? selectedId;
  int score = 0;
  late int startTime;

  bool isLoading = true;
  List<QuizQuestion> questions = [];

  @override
  void initState() {
    super.initState();
    startTime = DateTime.now().millisecondsSinceEpoch;
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final fetched = await QuestionBankApiService().fetchByTags(
        widget.section.tags ?? [],
        skill: 'LISTENING',
      );
      if (!mounted) return;
      setState(() {
        questions = fetched;
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

  void nextQuestion(String answerId) {
    if (questions[currentIndex].isCorrectChoice(answerId)) {
      score++;
    }

    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;
        selectedId = null;
      });
    } else {
      int totalTime =
          (DateTime.now().millisecondsSinceEpoch - startTime) ~/ 1000;

      debugPrint('[ListeningExamScreen] session ended — score=$score');
      context.read<RankingProvider>().recordAnswers(score);
      _reportStats(score, questions.length);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => UnifiedResultScreen(
            score: score,
            total: questions.length,
            time: totalTime,
            skill: 'LISTENING',
          ),
        ),
      );
    }
  }

  Future<void> _reportStats(int correct, int total) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      final token = prefs.getString('access_token');
      final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8123/api';
      
      await http.post(
        Uri.parse('$baseUrl/v1/section-stats/${widget.section.id}/record'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'count': correct,
        }),
      );
    } catch (e) {
      debugPrint('Error reporting stats: $e');
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
      backgroundColor: Theme.of(context).cardColor,
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
                  _settingsItem(Icons.bookmark_border, "Lưu", () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Đã lưu câu hỏi!")),
                    );
                  }),
                  _settingsItem(Icons.flag_outlined, "Báo cáo đề sai", () {
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

  Widget _settingsItem(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }

  Widget _themeOption(IconData icon, String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: isSelected ? const Color(0xFF42A5F5) : Colors.white70),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: isSelected ? const Color(0xFF42A5F5) : Colors.white70, fontSize: 12)),
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    DynamicQuestionBuilder(
                      question: question,
                      selectedId: selectedId,
                      isAnswered: selectedId != null,
                      onAnswer: (id) {
                        debugPrint('[ListeningExamScreen] Selected: $id, Correct: ${question.correctIds}');
                        setState(() {
                          selectedId = id;
                        });
                      },
                    ),
                    const SizedBox(height: 40),
                    if (selectedId != null)
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () => nextQuestion(selectedId!),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF42A5F5),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            elevation: 0,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                currentIndex < questions.length - 1 ? "Tiếp tục" : "Hoàn thành",
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              if (selectedId != null && selectedId!.startsWith("__MATCHING"))
                                const Text(
                                  "Tất cả đã nối. Kiểm tra và nộp bài.",
                                  style: TextStyle(fontSize: 10, color: Colors.white70),
                                ),
                            ],
                          ),
                        ),
                      )
                  ],
                ),
              ),
            ),
          ],
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