import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_desktop/core_quiz/models/quiz_question.dart';
import 'package:mobile_desktop/core_quiz/widgets/dynamic_question_builder.dart';
import 'package:mobile_desktop/features/ranking/providers/ranking_provider.dart';
import 'package:mobile_desktop/core/models/app_section_model.dart';
import '../../services/question_bank_api_service.dart';
import 'reading_result_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReadingExamScreen extends StatefulWidget {
  final String title;
  final int groupId;
  final AppSectionModel section;

  const ReadingExamScreen({
    super.key,
    required this.title,
    required this.groupId,
    required this.section,
  });

  @override
  State<ReadingExamScreen> createState() => _ReadingExamScreenState();
}

class _ReadingExamScreenState extends State<ReadingExamScreen> {
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
      final fetched = await QuestionBankApiService().fetchByTags(widget.section.tags ?? []);
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
    if (answerId == questions[currentIndex].correctIds.first) {
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

      debugPrint('[ReadingExamScreen] session ended — score=$score');
      context.read<RankingProvider>().recordAnswers(score);
      _reportStats(score, questions.length);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ReadingResultScreen(
            score: score,
            total: questions.length,
            time: totalTime,
            image: '',
          ),
        ),
      );
    }
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
          'count': correct, // Using 'count' field from DTO
        }),
      );
    } catch (e) {
      debugPrint('Error reporting stats: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title), backgroundColor: const Color(0xffff9800)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title), backgroundColor: const Color(0xffff9800)),
        body: const Center(child: Text("No questions available for this section.")),
      );
    }

    final question = questions[currentIndex];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffff9800),
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (currentIndex + 1) / questions.length,
              color: Colors.orange,
            ),
            const SizedBox(height: 20),
            Text(
              "Question ${currentIndex + 1}/${questions.length}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            DynamicQuestionBuilder(
              question: question,
              selectedId: selectedId,
              isAnswered: selectedId != null,
              onAnswer: (id) {
                setState(() {
                  selectedId = id;
                });
              },
            ),
            const SizedBox(height: 40),
            if (selectedId != null)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => nextQuestion(selectedId!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: Text(currentIndex < questions.length - 1 ? "Tiếp tục" : "Finish"),
                ),
              )
          ],
        ),
      ),
    );
  }
}
