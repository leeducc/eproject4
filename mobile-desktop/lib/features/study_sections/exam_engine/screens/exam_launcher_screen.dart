import 'package:flutter/material.dart';
import '../../../../core/models/exam_model.dart';
import 'exam_test_screen.dart';

class ExamLauncherScreen extends StatefulWidget {
  final ExamModel exam;

  const ExamLauncherScreen({Key? key, required this.exam}) : super(key: key);

  @override
  State<ExamLauncherScreen> createState() => _ExamLauncherScreenState();
}

class _ExamLauncherScreenState extends State<ExamLauncherScreen> {
  bool _isQuickMode = false;

  void _startExam(BuildContext context) {
    // Default config: 40m, 60m, 60m  |  Quick config: 5m, 10m, 10m
    final listenSecs = _isQuickMode ? 5 * 60 : 40 * 60;
    final readSecs = _isQuickMode ? 10 * 60 : 60 * 60;
    final writeSecs = _isQuickMode ? 10 * 60 : 60 * 60;

    print('[ExamLauncherScreen] Starting exam: ${widget.exam.title} listenSecs=$listenSecs');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ExamTestScreen(
          exam: widget.exam,
          listeningSecs: listenSecs,
          readingSecs: readSecs,
          writingSecs: writeSecs,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int listeningQs = 0;
    int readingQs = 0;
    int writingTasks = 0;
    
    // Calculate counts
    widget.exam.groups?.forEach((g) {
      if (g.skill.name == 'LISTENING') listeningQs += g.questions.length;
      if (g.skill.name == 'READING') readingQs += g.questions.length;
    });
    
    widget.exam.questions?.forEach((q) {
      if (q.skill.name == 'LISTENING') listeningQs++;
      if (q.skill.name == 'READING') readingQs++;
      if (q.skill.name == 'WRITING') writingTasks++;
    });

    return Scaffold(
      backgroundColor: const Color(0xFF161A23), // Dark background matching existing app style
      appBar: AppBar(
        title: const Text('Exam Preparation', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.exam.title,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              if (widget.exam.categories != null)
                 Wrap(
                    spacing: 8,
                    children: widget.exam.categories!.map((c) => Chip(
                      label: Text(c, style: const TextStyle(color: Colors.white, fontSize: 12)),
                      backgroundColor: Colors.blueAccent.withOpacity(0.2),
                      side: BorderSide.none,
                    )).toList(),
                 ),
              const SizedBox(height: 32),
              
              _buildSectionRow(Icons.headphones, 'Listening', '${listeningQs} Questions', _isQuickMode ? '5 mins' : '40 mins', Colors.purpleAccent),
              const SizedBox(height: 16),
              _buildSectionRow(Icons.menu_book, 'Reading', '${readingQs} Questions', _isQuickMode ? '10 mins' : '60 mins', Colors.blueAccent),
              const SizedBox(height: 16),
              _buildSectionRow(Icons.edit_document, 'Writing', '${writingTasks} Tasks', _isQuickMode ? '10 mins' : '60 mins', Colors.orangeAccent),
              
              const SizedBox(height: 48),
              
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2330),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                padding: const EdgeInsets.all(16),
                child: SwitchListTile(
                  title: const Text('Quick Test Mode', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: const Text('Reduces timers to minimum for fast testing.', style: TextStyle(color: Colors.white70)),
                  value: _isQuickMode,
                  activeColor: Colors.blueAccent,
                  onChanged: (val) {
                    setState(() {
                      _isQuickMode = val;
                    });
                  },
                ),
              ),
              
              const SizedBox(height: 48),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _startExam(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('START EXAM', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionRow(IconData icon, String title, String subtitle, String time, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2330),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 14)),
              ],
            ),
          ),
          Text(time, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
