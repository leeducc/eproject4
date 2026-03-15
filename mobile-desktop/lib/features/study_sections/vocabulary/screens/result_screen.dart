import 'package:flutter/material.dart';

import 'practice_screen.dart';

class ResultScreen extends StatefulWidget {
  final int correct;
  final int wrong;
  final int total;
  final int time;
  final List<Map<String, dynamic>> weakWords;
  final List<Map<String, dynamic>> vocabList;
  final String level;
  final String topic;

  const ResultScreen({
    super.key,
    required this.correct,
    required this.wrong,
    required this.total,
    required this.time,
    required this.weakWords,
    required this.vocabList,
    required this.level,
    required this.topic,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  bool showDetail = false;
  static const bgColor = Color(0xFF161A23);
  static const cardColor = Color(0xFF1F2430);
  static const primaryColor = Color(0xFF4F7CFE);
  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();
  }

  int starCount(double percent) {
    if (percent >= 80) return 3;
    if (percent >= 60) return 2;
    if (percent >= 40) return 1;
    return 0;
  }

  String formatTime(int seconds) {
    int m = seconds ~/ 60;
    int s = seconds % 60;
    return "${m.toString().padLeft(2, "0")}:${s.toString().padLeft(2, "0")}";
  }

  @override
  Widget build(BuildContext context) {
    final level = widget.level;
    final topic = widget.topic;
    double percent = (widget.correct / widget.total) * 100;
    int stars = starCount(percent);

    return Scaffold(
      backgroundColor: const Color(0xFF3C8DDC),

      body: GestureDetector(
        onTap: () {
          setState(() {
            showDetail = true;
          });
        },

        child: Stack(
          children: [
            /// RAY BACKGROUND
            Center(
              child: RotationTransition(
                turns: controller,
                child: Opacity(
                  opacity: 0.15,
                  child: const Icon(Icons.star, size: 900, color: Colors.white),
                ),
              ),
            ),

            /// FIRST SCREEN (ẢNH 1)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              top: showDetail ? 60 : 160,
              left: showDetail ? 20 : 0,
              right: showDetail ? null : 0,
              child: Column(
                crossAxisAlignment: showDetail
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.center,
                children: [
                  /// STAR + KEEP TRYING
                  Row(
                    mainAxisAlignment: showDetail
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      /// STARS
                      Row(
                        children: List.generate(3, (index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Icon(
                              index < stars ? Icons.star : Icons.star_border,
                              size: showDetail ? 40 : 70,
                              color: const Color(0xFFFFE27A),
                            ),
                          );
                        }),
                      ),

                      if (showDetail) const SizedBox(width: 12),

                      /// KEEP TRYING
                      if (showDetail)
                        const Text(
                          "Keep trying!",
                          style: TextStyle(
                            fontSize: 25,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  /// LEVEL + TOPIC (giữ nguyên dưới sao)
                  if (showDetail)
                    Text(
                      "$level • $topic",
                      style: const TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
            if (!showDetail)
              Column(
                children: [
                  const SizedBox(height: 240),

                  const Text(
                    "Keep trying!",
                    style: TextStyle(
                      fontSize: 26,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 35),

                  /// RESULT BOX
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    padding: const EdgeInsets.all(20),

                    decoration: BoxDecoration(
                      color: const Color(0xFF4A97DC),
                      borderRadius: BorderRadius.circular(14),
                    ),

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              "${percent.toStringAsFixed(0)}%",
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFFE27A),
                              ),
                            ),
                            const Text(
                              "Accuracy",
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),

                        Container(width: 1, height: 40, color: Colors.white54),

                        Column(
                          children: [
                            Text(
                              "${widget.correct}/${widget.total}",
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFFE27A),
                              ),
                            ),
                            const Text(
                              "Correct / Total",
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  const Padding(
                    padding: EdgeInsets.only(bottom: 40),
                    child: Text(
                      "Tap screen to continue",
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ),
                ],
              ),

            /// REPORT PANEL (ẢNH 2)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 450),

              bottom: showDetail ? 0 : -MediaQuery.of(context).size.height,

              left: 0,
              right: 0,

              child: Container(
                height: MediaQuery.of(context).size.height * 0.82,

                decoration: const BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),

                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    const SizedBox(height: 20),

                    /// STATS BOX
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.symmetric(vertical: 16),

                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),

                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          /// ACCURACY
                          Column(
                            children: [
                              const Text(
                                "Accuracy",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "${percent.toStringAsFixed(0)}%",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),

                          /// TIME
                          Column(
                            children: [
                              const Text(
                                "Time",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                formatTime(widget.time),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),

                          /// CORRECT
                          Column(
                            children: [
                              const Text(
                                "Correct / Total",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "${widget.correct}/${widget.total}",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// TITLE
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "Words to Review",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    /// WORD LIST
                    Expanded(
                      child: ListView.builder(
                        itemCount: widget.weakWords.length,
                        itemBuilder: (context, index) {
                          var w = widget.weakWords[index];

                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),

                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.white12),
                              ),
                            ),

                            child: Row(
                              children: [
                                /// WORD INFO
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ///WORD
                                      Row(
                                        children: [
                                          Text(
                                            w["word"],
                                            style: const TextStyle(
                                              fontSize: 20,
                                              color: Colors.white,
                                            ),
                                          ),

                                          const SizedBox(width: 8),

                                          /// TAG
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: primaryColor.withOpacity(
                                                0.2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              w["pos"] ?? "",
                                              style: const TextStyle(
                                                fontSize: 15,
                                                color: Colors.blue,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        w["phonetic"],
                                        style: const TextStyle(
                                          fontSize: 20,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 3),

                                      /// MEANING
                                      Text(
                                        w["meaning"],
                                        style: const TextStyle(
                                          fontSize: 20,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                /// STAR
                                const Icon(
                                  Icons.star_border,
                                  color: primaryColor,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    /// BUTTONS
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              alignment: Alignment.center,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PracticeScreen(
                                        vocabList: widget.vocabList,
                                        level: widget.level,
                                        topic: widget.topic,
                                      ),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Practice Again",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 16),

                          Expanded(
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              alignment: Alignment.center,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  "Next",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
