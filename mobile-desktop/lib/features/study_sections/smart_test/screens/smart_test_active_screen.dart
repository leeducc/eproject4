import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/models/quiz_bank_models.dart';
import 'package:mobile_desktop/core_quiz/models/quiz_question.dart';
import 'package:mobile_desktop/core_quiz/widgets/dynamic_question_builder.dart';
import '../services/smart_test_api_service.dart';
import 'package:mobile_desktop/features/study_sections/services/moderation_service.dart';
import '../models/smart_test_models.dart';
import 'smart_test_summary_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final fetched = await SmartTestApiService().generateSmartTest(widget.skill, widget.level);
      setState(() {
        questions = fetched;
        isLoading = false;
      });
      _startTimer();
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
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
      final attempts = questions.map((q) {
        String ans = userAnswers[q.id] ?? "";
        bool isCorrect = _checkAnswerMock(q, ans);
        return QuestionAttemptDTO(questionId: q.id, userAnswer: ans, isCorrect: isCorrect);
      }).toList();
      
      final req = SmartTestSubmitRequest(skill: widget.skill, difficultyBand: widget.level, attempts: attempts);
      final res = await SmartTestApiService().submitSmartTest(req);
      
      Navigator.pop(context);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SmartTestSummaryScreen(response: res)));
    } catch (e) {
      Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Submit Error: $e')));
      }
    }
  }
  
  bool _checkAnswerMock(Question q, String answer) {
      // In a real scenario, this would evaluate data Map for correct options.
      final quizQ = QuizQuestion.from(q);
      if (quizQ.correctIds.isNotEmpty) {
        return answer == quizQ.correctIds.first;
      }
      return answer.isNotEmpty; 
  }

  void _showReportDialog(Question q) {
      final TextEditingController reasonController = TextEditingController();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Report Question'),
          content: TextField(
            controller: reasonController,
            maxLines: 3,
            decoration: const InputDecoration(hintText: "Describe the issue...", border: OutlineInputBorder()),
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
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report Submitted!')));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))));
                }
              },
              child: const Text('Submit'),
            )
          ],
        ),
      );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ignore: deprecated_member_use
  Future<bool> _onWillPop() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text('Your test is running. Do you want to exit without saving?'),
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
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
         appBar: AppBar(
           title: const Text("Smart Test"),
           actions: [
             Center(
               child: Padding(
                 padding: const EdgeInsets.only(right: 16),
                 child: Text(_formattedTime, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
               )
             )
           ],
         ),
         body: isLoading 
            ? const Center(child: CircularProgressIndicator())
            : questions.isEmpty 
               ? const Center(child: Text("No questions generated."))
               : ListView.builder(
                   padding: const EdgeInsets.all(16),
                   itemCount: questions.length + 1,
                   itemBuilder: (context, index) {
                     if (index == questions.length) {
                       return Padding(
                         padding: const EdgeInsets.only(top: 20, bottom: 40),
                         child: ElevatedButton(
                           style: ElevatedButton.styleFrom(
                             minimumSize: const Size(double.infinity, 50),
                             backgroundColor: Colors.blueAccent,
                             foregroundColor: Colors.white,
                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                           ),
                           onPressed: _submitTest,
                           child: const Text("Submit Test", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                         ),
                       );
                     }
                     
                     final q = questions[index];
                     return Card(
                       margin: const EdgeInsets.only(bottom: 24),
                       elevation: 2,
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                       child: Padding(
                         padding: const EdgeInsets.all(16),
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Row(
                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                               children: [
                                 Text("Question ${index + 1}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                                 IconButton(
                                   icon: const Icon(Icons.report_problem_outlined, color: Colors.orange, size: 20),
                                   onPressed: () => _showReportDialog(q),
                                 )
                               ],
                             ),
                             const Divider(),
                             const SizedBox(height: 8),
                             DynamicQuestionBuilder(
                               question: QuizQuestion.from(q),
                               selectedId: userAnswers[q.id],
                               isAnswered: false, // In smart test, user can change answer until submit
                               onAnswer: (val) {
                                 setState(() {
                                   userAnswers[q.id] = val;
                                 });
                               },
                             ),
                           ],
                         ),
                       ),
                     );
                   },
                 ),
      )
    );
  }
}

