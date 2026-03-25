import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../providers/exam_provider.dart';

class BreakScreen extends StatefulWidget {
  const BreakScreen({Key? key}) : super(key: key);

  @override
  State<BreakScreen> createState() => _BreakScreenState();
}

class _BreakScreenState extends State<BreakScreen> {
  int _breakSeconds = 10 * 60; // 10 minutes default
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
         timer.cancel();
         return;
      }
      if (_breakSeconds > 0) {
        setState(() {
          _breakSeconds--;
        });
      } else {
        _skipBreak();
      }
    });
  }

  void _skipBreak() {
    if (!mounted) return;
    _timer?.cancel();
    Provider.of<ExamProvider>(context, listen: false).nextSection();
    Navigator.pop(context); // Pops the BreakScreen, bringing us back to ExamTestScreen
  }

  String _formatTime(int totalSeconds) {
    int m = totalSeconds ~/ 60;
    int s = totalSeconds % 60;
    return "\${m.toString().padLeft(2, '0')}:\${s.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF161A23),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               const Icon(Icons.coffee, size: 80, color: Colors.orangeAccent),
               const SizedBox(height: 32),
               const Text(
                 'Break Time', 
                 style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)
               ),
               const SizedBox(height: 16),
               const Text(
                 'Please take a few moments to rest before the next exam section begins.', 
                 style: TextStyle(color: Colors.white70, fontSize: 16),
                 textAlign: TextAlign.center,
               ),
               const SizedBox(height: 48),
               
               // Timer display
               Container(
                 padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
                 decoration: BoxDecoration(
                   color: const Color(0xFF1E2330),
                   borderRadius: BorderRadius.circular(24),
                   border: Border.all(color: Colors.blueAccent.withOpacity(0.5)),
                   boxShadow: [
                     BoxShadow(color: Colors.blueAccent.withOpacity(0.1), blurRadius: 20, spreadRadius: 5)
                   ]
                 ),
                 child: Text(
                    _formatTime(_breakSeconds),
                    style: const TextStyle(
                      color: Colors.white, 
                      fontSize: 48, 
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                      fontFamily: 'Courier'
                    ),
                 ),
               ),
               
               const SizedBox(height: 64),
               
               SizedBox(
                 width: double.infinity,
                 child: OutlinedButton.icon(
                   onPressed: _skipBreak,
                   icon: const Icon(Icons.fast_forward, color: Colors.blueAccent),
                   label: const Text('SKIP BREAK', style: TextStyle(color: Colors.blueAccent, fontSize: 16, letterSpacing: 1.2)),
                   style: OutlinedButton.styleFrom(
                     padding: const EdgeInsets.symmetric(vertical: 20),
                     side: const BorderSide(color: Colors.blueAccent, width: 2),
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                   ),
                 ),
               )
            ],
          ),
        ),
      ),
    );
  }
}
