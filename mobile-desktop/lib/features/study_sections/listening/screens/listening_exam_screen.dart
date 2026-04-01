import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final fetched = await QuestionBankApiService().fetchByTags(widget.section.tags ?? []);
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
    context.read<RankingProvider>().recordAnswers(correctCount);
    _reportStats(correctCount, questions.length);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Results 🎯"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("You got $correctCount out of ${questions.length} correct!"),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: questions.length,
                itemBuilder: (context, i) {
                  final res = userResults[i];
                  return ListTile(
                    leading: Icon(
                      res == true ? Icons.check_circle : Icons.cancel,
                      color: res == true ? Colors.green : Colors.red,
                    ),
                    title: Text("Question ${i + 1}"),
                  );
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Back to listening screen
            },
            child: const Text("CLOSE"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: const Center(child: Text("No questions available.")),
      );
    }

    final question = questions[currentIndex];

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Question ${currentIndex + 1}/${questions.length}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildProgressIndicator(),
            const SizedBox(height: 24),
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
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _nextQuestion,
                  child: Text(currentIndex < questions.length - 1 ? "Next Question" : "Finish"),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(questions.length, (i) {
        final result = userResults[i];
        final isCurrent = i == currentIndex;

        Color color;
        if (result == true) {
          color = Colors.green;
        } else if (result == false) {
          color = Colors.red;
        } else if (isCurrent) {
          color = Colors.blueAccent;
        } else {
          color = Colors.grey.shade400;
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        );
      }),
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
