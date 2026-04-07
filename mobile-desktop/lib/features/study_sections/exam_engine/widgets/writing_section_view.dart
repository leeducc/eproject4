import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/quiz_bank_models.dart';
import '../providers/exam_provider.dart';
import '../screens/exam_result_screen.dart';

class WritingSectionView extends StatefulWidget {
  const WritingSectionView({Key? key}) : super(key: key);

  @override
  State<WritingSectionView> createState() => _WritingSectionViewState();
}

class _WritingSectionViewState extends State<WritingSectionView> {
  String _writingGradingType = 'AI';
  final Map<int, TextEditingController> _controllers = {};

  @override
  void dispose() {
    for (var c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit(BuildContext context) async {
    final provider = Provider.of<ExamProvider>(context, listen: false);

    String task1 = '';
    String task2 = '';

    final writingQuestions = provider.state?.exam.questions
            ?.where((q) => q.skill == SkillType.writing)
            .toList() ??
        [];
    if (writingQuestions.isNotEmpty && _controllers.containsKey(writingQuestions[0].id)) {
      task1 = _controllers[writingQuestions[0].id]!.text;
    }
    if (writingQuestions.length > 1 && _controllers.containsKey(writingQuestions[1].id)) {
      task2 = _controllers[writingQuestions[1].id]!.text;
    }

    print('[WritingSectionView] Submitting exam — gradingType=$_writingGradingType');
    final result = await provider.submitExam(
      gradingType: _writingGradingType,
      writingTask1: task1,
      writingTask2: task2,
    );

    if (result != null && mounted) {
      
      
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ExamResultScreen(result: result),
        ),
      );
      
      provider.clearSession();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to submit exam. Please try again.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ExamProvider>(context).state;
    if (state == null) return const SizedBox.shrink();

    final writingQuestions = state.exam.questions?.where((q) => q.skill == SkillType.writing).toList() ?? [];

    if (writingQuestions.isEmpty) {
       return const Center(child: Text('No writing tasks available.', style: TextStyle(color: Colors.white70)));
    }

    
    for (var q in writingQuestions) {
      if (!_controllers.containsKey(q.id)) {
        _controllers[q.id] = TextEditingController();
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Writing Section', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
           const SizedBox(height: 8),
           const Text('Write your essays in the provided text boxes. When finished, select your grading preference and submit the entire exam.', style: TextStyle(color: Colors.white54)),
           const SizedBox(height: 32),

           ...writingQuestions.asMap().entries.map((entry) {
              int idx = entry.key + 1;
              Question q = entry.value;

              return Container(
                margin: const EdgeInsets.only(bottom: 32),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2330),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Task $idx', style: const TextStyle(color: Colors.blueAccent, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Text(q.instruction, style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5)),
                    if (q.data['template'] != null) ...[
                       const SizedBox(height: 8),
                       Text(q.data['template'].toString(), style: const TextStyle(color: Colors.white70, fontSize: 14)),
                    ],
                    const SizedBox(height: 24),
                    TextField(
                      controller: _controllers[q.id],
                      maxLines: 15,
                      style: const TextStyle(color: Colors.white, height: 1.6),
                      decoration: InputDecoration(
                        hintText: 'Start writing your essay here...',
                        hintStyle: const TextStyle(color: Colors.white30),
                        filled: true,
                        fillColor: const Color(0xFF161A23),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white12)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white12)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.blueAccent)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _controllers[q.id]!,
                      builder: (context, value, child) {
                        int wordCount = value.text.trim().isEmpty ? 0 : value.text.trim().split(RegExp(r'\s+')).length;
                        return Align(
                          alignment: Alignment.centerRight,
                          child: Text('Word count: $wordCount', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                        );
                      },
                    ),
                  ],
                ),
              );
           }).toList(),

           const Divider(color: Colors.white12, thickness: 2),
           const SizedBox(height: 32),

           const Text('Grading Preference', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
           const SizedBox(height: 16),
           SegmentedButton<String>(
             segments: const <ButtonSegment<String>>[
               ButtonSegment<String>(
                 value: 'AI',
                 label: Text('Instant AI Grading'),
                 icon: Icon(Icons.auto_awesome),
               ),
               ButtonSegment<String>(
                 value: 'HUMAN',
                 label: Text('Teacher Grading'),
                 icon: Icon(Icons.person),
               ),
             ],
             selected: <String>{_writingGradingType},
             onSelectionChanged: (Set<String> newSelection) {
               setState(() {
                 _writingGradingType = newSelection.first;
               });
             },
             style: SegmentedButton.styleFrom(
               selectedBackgroundColor: _writingGradingType == 'AI' ? Colors.purpleAccent.withOpacity(0.2) : Colors.blueAccent.withOpacity(0.2),
               selectedForegroundColor: _writingGradingType == 'AI' ? Colors.purpleAccent : Colors.blueAccent,
               backgroundColor: const Color(0xFF1E2330),
               foregroundColor: Colors.white54,
             ),
           ),

           const SizedBox(height: 48),

           SizedBox(
             width: double.infinity,
             child: ElevatedButton(
               onPressed: () => _submit(context),
               style: ElevatedButton.styleFrom(
                 backgroundColor: Colors.green,
                 padding: const EdgeInsets.symmetric(vertical: 20),
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
               ),
               child: const Text('SUBMIT EXAM', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2)),
             ),
           ),
           const SizedBox(height: 32),
        ],
      ),
    );
  }
}