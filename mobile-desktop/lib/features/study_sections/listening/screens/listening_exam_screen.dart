import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import 'package:mobile_desktop/core_quiz/models/quiz_question.dart';
import 'package:mobile_desktop/core_quiz/widgets/dynamic_question_builder.dart';
import '../../services/question_bank_api_service.dart';
import 'package:mobile_desktop/features/ranking/providers/ranking_provider.dart';
import 'package:mobile_desktop/core/models/app_section_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/unified_result_screen.dart';

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
  List<bool?> userResults = [];
  bool isLoading = true;
  List<QuizQuestion> questions = [];

  late int startTime;

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
      setState(() {
        questions = fetched;
        userResults = List.generate(questions.length, (_) => null);
        isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _onAnswer(String id) {
    if (userResults[currentIndex] != null) return;

    final question = questions[currentIndex];
    final isCorrect = id == question.correctIds.first;

    setState(() {
      selectedId = id;
      userResults[currentIndex] = isCorrect;
    });
  }

  void _nextQuestion() {
    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;
        selectedId = null;
      });
    } else {
      _showResults();
    }
  }

  void _showResults() {
    final correctCount = userResults.where((r) => r == true).length;
    final totalTime = (DateTime.now().millisecondsSinceEpoch - startTime) ~/ 1000;
    
    context.read<RankingProvider>().recordAnswers(correctCount);
    _reportStats(correctCount, questions.length);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => UnifiedResultScreen(
          score: correctCount,
          total: questions.length,
          time: totalTime,
          skill: 'LISTENING',
        ),
      ),
    );
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
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFE65100)),
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
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2C313D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _settingsItem(Icons.bookmark_border, "Lưu"),
              _settingsItem(Icons.flag_outlined, "Báo cáo đề sai"),
              const Divider(color: Colors.white10),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Text("Aa", style: TextStyle(color: Colors.blue, fontSize: 16)),
                    const Text("Aa", style: TextStyle(color: Colors.white, fontSize: 18)),
                    const Text("Aa", style: TextStyle(color: Colors.white, fontSize: 22)),
                  ],
                ),
              ),
              const Divider(color: Colors.white10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _themeOption(Icons.wb_sunny_outlined, "Ban ngày", false),
                  _themeOption(Icons.nightlight_round, "Chế độ ban đêm", true),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _settingsItem(IconData icon, String label) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      onTap: () => Navigator.pop(context),
    );
  }

  Widget _themeOption(IconData icon, String label, bool isSelected) {
    return Column(
      children: [
        Icon(icon, color: isSelected ? Colors.blue : Colors.white70),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: isSelected ? Colors.blue : Colors.white70, fontSize: 12)),
      ],
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
        backgroundColor: const Color(0xFF1E212A),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        ),
        body: const Center(child: Text("No questions available.", style: TextStyle(color: Colors.white))),
      );
    }

    final question = questions[currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF1E212A),
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
                      isAnswered: userResults[currentIndex] != null,
                      onAnswer: _onAnswer,
                    ),
                    const SizedBox(height: 32),
                    if (userResults[currentIndex] != null)
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF42A5F5),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            elevation: 0,
                          ),
                          onPressed: _nextQuestion,
                          child: Text(
                            currentIndex < questions.length - 1 ? "Tiếp tục" : "Hoàn thành",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
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
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              widget.title,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white70, size: 22),
            onPressed: _showSectionGuide,
          ),
          Text(
            "${currentIndex + 1}/${questions.length}",
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white70),
            onPressed: _showSettingsMenu,
          ),
        ],
      ),
    );
  }

  Future<void> _reportStats(int correct, int total) async {
    try {
      final prefs = await SharedPreferences.getInstance();
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
}
