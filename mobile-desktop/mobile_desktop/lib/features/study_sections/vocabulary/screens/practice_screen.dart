import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'result_screen.dart';

class PracticeScreen extends StatefulWidget {
  final List<Map<String, dynamic>> vocabList;

  const PracticeScreen({super.key, required this.vocabList});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  final FlutterTts tts = FlutterTts();
  final Random random = Random();
  Map<String, List<String>> sentenceTemplates = {
    "noun": [
      "I see a ____.",
      "She bought a ____.",
      "This is a ____.",
      "They need a ____.",
      "I have a ____."
    ],

    "verb": [
      "I like to ____.",
      "She will ____ tomorrow.",
      "They often ____ together.",
      "We ____ every day.",
    ],

    "adjective": [
      "The food is ____.",
      "This place is very ____.",
      "She feels ____ today.",
      "It looks ____.",
    ],

    "phrase": [
      "People say '____' when greeting.",
    ],

    "interjection": [
      "We say '____' to greet someone.",
    ]
  };
  String currentSentence = "";
  int? selectedLeft;
  int? selectedRight;
  int? selectedOption;
  bool showResult = false;
  Set<int> matchedLeft = {};
  Set<int> matchedRight = {};
  int questionIndex = 0;
  int correctCount = 0;
  int wrongCount = 0;
  /// ✔ tăng lên 20 câu
  int totalQuestion = 20;

  int questionType = 0;

  Map<String, dynamic>? currentWord;
  List<Map<String, dynamic>> options = [];
  List<Map<String, dynamic>> matchList = [];
  List<Map<String, dynamic>> leftList = [];
  List<Map<String, dynamic>> rightList = [];

  @override
  void initState() {
    super.initState();
    loadQuestion();
  }

  void speak(String text) async {
    await tts.setLanguage("en-US");
    await tts.speak(text);
  }

  void loadQuestion() {
    selectedOption = null;
    showResult = false;

    selectedLeft = null;
    selectedRight = null;

    matchedLeft.clear();
    matchedRight.clear();

    questionType = random.nextInt(4);

    currentWord = widget.vocabList[random.nextInt(widget.vocabList.length)];

    options = [...widget.vocabList]..shuffle();
    options = options.take(4).toList();

    if (!options.contains(currentWord)) {
      options[0] = currentWord!;
    }

    /// random câu hỏi cho fill blank
    String pos = currentWord!['pos'] ?? 'noun';

    List<String> templates =
        sentenceTemplates[pos] ?? sentenceTemplates['noun']!;

    templates.shuffle();
    currentSentence = templates.first;

    /// match game
    matchList = [...widget.vocabList]..shuffle();
    matchList = matchList.take(4).toList();

    leftList = [...matchList];
    rightList = [...matchList]..shuffle();

    setState(() {});
  }

  void handleSwipe(DragEndDetails details) {
    if (details.primaryVelocity == null) return;

    // vuốt sang trái -> câu tiếp
    if (details.primaryVelocity! < 0) {
      nextQuestion();
    }

    // vuốt sang phải -> câu trước
    if (details.primaryVelocity! > 0) {
      if (questionIndex > 0) {
        questionIndex--;
        loadQuestion();
      }
    }
  }

  void nextQuestion() {
    if (questionIndex >= totalQuestion - 1) {
      finishPractice();
      return;
    }

    questionIndex++;
    loadQuestion();
  }

  void finishPractice() {

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          correct: correctCount,
          wrong: wrongCount,
          total: totalQuestion,
        ),
      ),
    );

  }

  Widget optionCard(String text, bool correct, int index) {
    Color bgColor = const Color(0xFF1E2A38);

    if (showResult) {
      if (correct) {
        bgColor = Colors.green;
      } else if (selectedOption == index) {
        bgColor = Colors.red;
      }
    }

    return GestureDetector(
      onTap: () {

        if (showResult) return;

        bool isCorrect = correct;

        if (isCorrect) {
          correctCount++;
        } else {
          wrongCount++;
        }

        setState(() {
          selectedOption = index;
          showResult = true;
        });

        Future.delayed(const Duration(seconds: 1), () {
          nextQuestion();
        });

      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }

  /// ✔ progress giống VocabularyDetailScreen
  Widget progressBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: List.generate(
          totalQuestion,
          (index) => Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              height: 4,
              decoration: BoxDecoration(
                color: index <= questionIndex
                    ? const Color(0xFF4F7CFE)
                    : Colors.white12,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget matchCard(
      String text,
      bool selected,
      bool hidden,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: hidden ? null : onTap,
      child: Container(
        height: 70,
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: hidden
              ? Colors.transparent
              : (selected ? Colors.blue : const Color(0xFF1E2A38)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: hidden
            ? const SizedBox()
            : Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  void checkMatch() {
    if (selectedLeft == null || selectedRight == null) return;

    var left = leftList[selectedLeft!];
    var right = rightList[selectedRight!];

    if (left['word'] == right['word']) {
      matchedLeft.add(selectedLeft!);
      matchedRight.add(selectedRight!);

      if (matchedLeft.length == 4) {

        correctCount++;   // tính 1 câu đúng

        Future.delayed(const Duration(milliseconds: 400), () {
          nextQuestion();
        });
      }
    }

    selectedLeft = null;
    selectedRight = null;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (currentWord == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F1A24),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

        /// ❌ nút đóng
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        /// ⭐ favorite
        actions: [
          IconButton(
            icon: Icon(
              (currentWord?['favorite'] ?? false)
                  ? Icons.star
                  : Icons.star_border,
              color: Colors.amber,
            ),
            onPressed: () {
              setState(() {
                currentWord!['favorite'] = !(currentWord?['favorite'] ?? false);
              });
            },
          ),
        ],
      ),

      body: GestureDetector(
        onHorizontalDragEnd: handleSwipe,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              progressBar(),

              const SizedBox(height: 30),

              /// TYPE 0 — Chọn nghĩa của từ
              if (questionType == 0) ...[
                const Text(
                  "Choose meaning",
                  style: TextStyle(color: Colors.white70),
                ),

                const SizedBox(height: 20),

                Text(
                  currentWord!['word'],
                  style: const TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 30),

                ...List.generate(options.length, (i) {
                  var e = options[i];
                  return optionCard(e['meaning_vi'], e == currentWord, i);
                }),
              ],

              /// TYPE 1 — Nghe chọn nghĩa
              if (questionType == 1) ...[
                const Text(
                  "Listen and choose meaning",
                  style: TextStyle(color: Colors.white70),
                ),

                const SizedBox(height: 20),

                IconButton(
                  icon: const Icon(
                    Icons.volume_up,
                    size: 50,
                    color: Colors.blue,
                  ),
                  onPressed: () {
                    speak(currentWord!['word']);
                  },
                ),

                const SizedBox(height: 30),

                ...List.generate(options.length, (i) {
                  var e = options[i];
                  return optionCard(e['meaning_vi'], e == currentWord, i);
                }),
              ],

              /// TYPE 2 — Nghe điền từ
              if (questionType == 2) ...[
                const Text(
                  "Listen and fill the blank",
                  style: TextStyle(color: Colors.white70),
                ),

                const SizedBox(height: 20),

                IconButton(
                  icon: const Icon(
                    Icons.volume_up,
                    size: 50,
                    color: Colors.blue,
                  ),
                  onPressed: () {
                    speak(currentWord!['word']);
                  },
                ),

                const SizedBox(height: 30),

                Text(
                  currentSentence.replaceAll("____", "_____"),
                  style: const TextStyle(fontSize: 24, color: Colors.white),
                ),

                const SizedBox(height: 30),

                ...List.generate(options.length, (i) {
                  var e = options[i];
                  return optionCard(e['word'], e == currentWord, i);
                }),
              ],

              /// TYPE 3 — Ghép cặp từ
              if (questionType == 3) ...[
                const Text(
                  "Match word with meaning",
                  style: TextStyle(color: Colors.white70),
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: Row(
                    children: [
                      /// CỘT WORD
                      Expanded(
                        child: ListView.builder(
                          itemCount: leftList.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: matchCard(
                                leftList[index]['word'],
                                selectedLeft == index,
                                matchedLeft.contains(index),
                                () {
                                  setState(() {
                                    selectedLeft = index;
                                  });
                                  checkMatch();
                                },
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(width: 12),

                      /// CỘT MEANING
                      Expanded(
                        child: ListView.builder(
                          itemCount: rightList.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: matchCard(
                                rightList[index]['meaning_vi'],
                                selectedRight == index,
                                matchedRight.contains(index),
                                () {
                                  setState(() {
                                    selectedRight = index;
                                  });
                                  checkMatch();
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
