import 'package:flutter/material.dart';

class FillBlankWidget extends StatefulWidget {
  final String questionText;
  final bool isAnswered;
  final void Function(String? answer) onSubmit;

  const FillBlankWidget({
    super.key,
    required this.questionText,
    required this.isAnswered,
    required this.onSubmit,
  });

  @override
  State<FillBlankWidget> createState() => _FillBlankWidgetState();
}

class _FillBlankWidgetState extends State<FillBlankWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            widget.questionText,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _controller,
          enabled: !widget.isAnswered,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: "Your answer...",
          ),
        ),
        const SizedBox(height: 16),
        if (!widget.isAnswered)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              if (_controller.text.trim().isNotEmpty) {
                widget.onSubmit(_controller.text.trim());
              }
            },
            child: const Text("Submit Answer", style: TextStyle(fontSize: 18)),
          ),
        if (widget.isAnswered)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Answer submitted.",
              style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }
}