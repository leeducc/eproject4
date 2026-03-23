import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class ReadingResultScreen extends StatefulWidget {
  final int score;
  final int total;
  final int time; // thời gian làm bài (giây)

  const ReadingResultScreen({
    super.key,
    required this.score,
    required this.total,
    required this.time, required String image,
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

    double percent = widget.score / widget.total * 100;
    bool pass = percent >= 60;

    return Scaffold(

      body: GestureDetector(

        onTap: (){
          Navigator.pop(context);
        },

        child: Container(

          width: double.infinity,
          height: double.infinity,

          decoration: const BoxDecoration(

            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xff42a5f5),
                Color(0xff1e88e5),
              ],
            ),

          ),

          child: Stack(

            alignment: Alignment.center,

            children: [

              /// CONFETTI
              ConfettiWidget(
                confettiController: _controller,
                blastDirectionality: BlastDirectionality.explosive,
                numberOfParticles: 20,
              ),

              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  const SizedBox(height: 60),

                  /// MEDAL
                  Image.network(
                    "https://cdn-icons-png.flaticon.com/512/2583/2583344.png",
                    width: 150,
                  ),

                  const SizedBox(height: 20),

                  Text(
                    pass ? "Đạt yêu cầu" : "Chưa đạt",
                    style: const TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 40),

                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 30),

                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [

                        Column(
                          children: [

                            Text(
                              "${percent.toStringAsFixed(0)}%",
                              style: const TextStyle(
                                fontSize: 28,
                                color: Colors.yellow,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 5),

                            const Text(
                              "Trả lời đúng",
                              style: TextStyle(color: Colors.white70),
                            ),

                          ],
                        ),

                        Container(
                          height: 40,
                          width: 1,
                          color: Colors.white30,
                        ),

                        Column(
                          children: [

                            Text(
                              formatTime(widget.time),
                              style: const TextStyle(
                                fontSize: 28,
                                color: Colors.yellow,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 5),

                            const Text(
                              "Thời gian trả lời",
                              style: TextStyle(color: Colors.white70),
                            ),

                          ],
                        ),

                      ],
                    ),
                  ),

                  const SizedBox(height: 150),

                  const Text(
                    "Bấm vào màn hình để tiếp tục",
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  )

                ],
              ),

              /// BACK BUTTON
              Positioned(
                top: 50,
                left: 10,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back,color: Colors.white),
                  onPressed: (){
                    Navigator.pop(context);
                  },
                ),
              ),

              const Positioned(
                top: 55,
                left: 60,
                child: Text(
                  "Bảng báo cáo bài thi",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}