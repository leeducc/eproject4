import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class ReadingResultScreen extends StatefulWidget {
  final int score;
  final int total;
  final int time;

  const ReadingResultScreen({
    super.key,
    required this.score,
    required this.total,
    required this.time,
  });

  @override
  State<ReadingResultScreen> createState() => _ReadingResultScreenState();
}

class _ReadingResultScreenState extends State<ReadingResultScreen> {

  late ConfettiController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ConfettiController(duration: const Duration(seconds: 5));
    _controller.play();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String formatTime(int seconds) {
    int m = seconds ~/ 60;
    int s = seconds % 60;
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {

    double percent = widget.total == 0
        ? 0
        : widget.score / widget.total * 100;

    bool pass = percent >= 60;

    String image = pass
        ? "https://cdn-icons-png.flaticon.com/512/2583/2583344.png"
        : "https://cdn-icons-png.flaticon.com/512/1828/1828843.png";

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff42a5f5), Color(0xff1e88e5)],
          ),
        ),

        child: Stack(
          alignment: Alignment.center,
          children: [

            ConfettiWidget(
              confettiController: _controller,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 20,
            ),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Image.network(image, width: 150),

                const SizedBox(height: 20),

                Text(
                  pass ? "Đạt yêu cầu" : "Chưa đạt",
                  style: const TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 30),

                Text(
                  "${widget.score} / ${widget.total}",
                  style: const TextStyle(
                    fontSize: 26,
                    color: Colors.yellow,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  "Thời gian: ${formatTime(widget.time)}",
                  style: const TextStyle(color: Colors.white),
                ),

                const SizedBox(height: 40),

                ElevatedButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: const Text("Quay lại"),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}