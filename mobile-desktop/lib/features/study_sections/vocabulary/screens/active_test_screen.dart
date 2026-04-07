import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vocabulary_test_provider.dart';
import 'test_summary_screen.dart';

class ActiveTestScreen extends StatefulWidget {
  const ActiveTestScreen({Key? key}) : super(key: key);

  @override
  State<ActiveTestScreen> createState() => _ActiveTestScreenState();
}

class _ActiveTestScreenState extends State<ActiveTestScreen> {
  String? selectedOption;
  bool? isCorrect;
  bool hasAnswered = false;

  @override
  Widget build(BuildContext context) {
    final testProvider = context.watch<VocabularyTestProvider>();
    final currentTest = testProvider.currentTest;
    
    if (currentTest == null || currentTest['questions'] == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final questions = currentTest['questions'] as List<dynamic>;
    if (testProvider.currentIndex >= questions.length) {
      
      Future.microtask(() => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const TestSummaryScreen()),
      ));
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final questionData = questions[testProvider.currentIndex];
    final quizJson = jsonDecode(questionData['questionJson']);
    final type = questionData['quizType'];

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Text('Câu hỏi ${testProvider.currentIndex + 1}/${questions.length}', 
            style: const TextStyle(color: Colors.white70, fontSize: 16)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white70),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (testProvider.currentIndex) / questions.length,
            backgroundColor: Colors.white10,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    type == 'FILL_IN_THE_BLANK' ? 'Điền vào chỗ trống:' : 'Chọn đáp án đúng:',
                    style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    quizJson['question'] ?? quizJson['sentence'] ?? '',
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w500, height: 1.4),
                  ),
                  const SizedBox(height: 40),
                  ..._buildOptions(quizJson, testProvider, questionData['id']),
                ],
              ),
            ),
          ),
          if (hasAnswered)
            Padding(
              padding: const EdgeInsets.all(24),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    hasAnswered = false;
                    selectedOption = null;
                    isCorrect = null;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('TIẾP THEO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildOptions(Map<String, dynamic> quizJson, VocabularyTestProvider provider, int vocabId) {
    final options = quizJson['options'] as List<dynamic>? ?? [];
    final correctAnswer = quizJson['answer'];

    return options.map((option) {
      final isSelected = selectedOption == option;
      Color borderColor = Colors.white10;
      Color bgColor = Colors.transparent;
      Widget? trailing;

      if (hasAnswered) {
        if (option == correctAnswer) {
          borderColor = Colors.green;
          bgColor = Colors.green.withOpacity(0.1);
          trailing = const Icon(Icons.check_circle, color: Colors.green);
        } else if (isSelected) {
          borderColor = Colors.red;
          bgColor = Colors.red.withOpacity(0.1);
          trailing = const Icon(Icons.cancel, color: Colors.red);
        }
      } else if (isSelected) {
        borderColor = Colors.blue;
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: InkWell(
          onTap: hasAnswered ? null : () {
            setState(() {
              selectedOption = option;
              hasAnswered = true;
              isCorrect = (option == correctAnswer);
              provider.submitAnswer(vocabId, isCorrect!);
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: bgColor,
              border: Border.all(color: borderColor, width: 2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    option.toString(),
                    style: TextStyle(
                      color: isSelected || (hasAnswered && option == correctAnswer) ? Colors.white : Colors.white70,
                      fontSize: 18,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                if (trailing != null) trailing,
              ],
            ),
          ),
        ),
      );
    }).toList();
  }
}