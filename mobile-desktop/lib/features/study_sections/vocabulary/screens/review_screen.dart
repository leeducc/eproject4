import 'package:flutter/material.dart';

import '../models/vocabulary.dart';
import '../services/srs_service.dart';

class ReviewScreen extends StatefulWidget {
  final List<Vocabulary> dueWords;

  const ReviewScreen({Key? key, required this.dueWords}) : super(key: key);

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.dueWords.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF161A23),
        body: const Center(
          child: Text(
            'Hôm nay không có từ cần ôn 🎉',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final vocab = widget.dueWords[index];

    return Scaffold(
      backgroundColor: const Color(0xFF161A23),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Ôn tập', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(),
            Text(
              vocab.word,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: _btn('Quên', Colors.redAccent, false),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _btn('Nhớ', Colors.green, true),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _btn(String text, Color color, bool remembered) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      onPressed: () {
        SrsService.markResult(widget.dueWords[index], remembered);
        if (index < widget.dueWords.length - 1) {
          setState(() => index++);
        } else {
          Navigator.pop(context);
        }
      },
      child: Text(text,
          style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}