import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/audio_service.dart';

class TrueFalseScreen extends StatefulWidget {
  const TrueFalseScreen({super.key});

  @override
  State<TrueFalseScreen> createState() => _TrueFalseScreenState();
}

class _TrueFalseScreenState extends State<TrueFalseScreen> {
  final audio = AudioService();
  final controller = PageController();
  int? getFirstUnansweredIndex() {
    for (int i = 0; i < userAnswers.length; i++) {
      if (userAnswers[i] == null) return i;
    }
    return null;
  }

  Widget buildResultList() {
    return SizedBox(
      width: double.maxFinite,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: questions.length,
        itemBuilder: (_, i) {
          final result = userAnswers[i];

          return ListTile(
            leading: Icon(
              result == true ? Icons.check_circle : Icons.cancel,
              color: result == true ? Colors.green : Colors.red,
            ),
            title: Text("Question ${i + 1}"),
            trailing: Icon(
              result == true ? Icons.check : Icons.close,
              color: result == true ? Colors.green : Colors.red,
            ),
          );
        },
      ),
    );
  }

  Widget buildProgress() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(questions.length, (i) {
        final result = userAnswers[i];
        final isCurrent = i == index;

        Color color;

        if (result == true) {
          color = Colors.green;
        } else if (result == false) {
          color = Colors.red;
        } else if (isCurrent) {
          color = Colors.blueAccent;
        } else {
          color = Colors.grey.shade400;
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        );
      }),
    );
  }

  Future<bool> _confirmExit() async {
    return await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Are you sure?"),
            content: const Text("All progress will be lost."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Exit"),
              ),
            ],
          ),
        ) ??
        false;
  }

  int index = 0;
  bool isSpeaking = false;

  List<bool?> userAnswers = [];

  final List<Question> questions = [
    Question(word: "Apple", image: "https://picsum.photos/300?1", answer: true),
    Question(word: "Dog", image: "https://picsum.photos/300?2", answer: false),
    Question(word: "Car", image: "https://picsum.photos/300?3", answer: true),
    Question(word: "Cat", image: "https://picsum.photos/300?4", answer: false),
    Question(
      word: "Banana",
      image: "https://picsum.photos/300?5",
      answer: true,
    ),
  ];

  @override
  void initState() {
    super.initState();

    audio.init();
    audio.stop();

    userAnswers = List.generate(questions.length, (_) => null);

    audio.onStart = () {
      setState(() => isSpeaking = true);
    };

    audio.onComplete = () {
      setState(() => isSpeaking = false);
    };
  }

  void answer(bool choice) {
    final correctAnswer = questions[index].answer;

    setState(() {
      userAnswers[index] = choice == correctAnswer;
    });
  }

  @override
  void dispose() {
    audio.stop();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        if (await _confirmExit()) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("True / False"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (await _confirmExit()) {
                Navigator.pop(context);
              }
            },
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                children: [
                  Text(
                    "Question ${index + 1}/${questions.length}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  buildProgress(),
                ],
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: controller,
                itemCount: questions.length,
                onPageChanged: (i) {
                  audio.stop();
                  setState(() {
                    index = i;
                  });
                },
                itemBuilder: (_, i) {
                  final q = questions[i];
                  final result = userAnswers[i];

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(q.image, height: 220),

                      const SizedBox(height: 30),

                      IconButton(
                        icon: Icon(
                          Icons.volume_up,
                          size: 60,
                          color: isSpeaking ? Colors.green : Colors.white,
                        ),
                        onPressed: () => audio.speak(questions[index].word),
                      ),
                      if (isSpeaking)
                        const Text(
                          "Listening...",
                          style: TextStyle(color: Colors.green),
                        ),

                      if (result != null) ...[
                        const SizedBox(height: 10),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              result ? Icons.check_circle : Icons.cancel,
                              color: result ? Colors.green : Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              result ? "Correct" : "Incorrect",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: result ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        Text(q.word, style: const TextStyle(fontSize: 20)),

                        const SizedBox(height: 20),

                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.7,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () async {
                              /// Next Question
                              if (index != questions.length - 1) {
                                controller.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.ease,
                                );
                                return;
                              }

                              /// Done
                              int? unanswered;

                              for (int i = 0; i < userAnswers.length; i++) {
                                if (userAnswers[i] == null) {
                                  unanswered = i;
                                  break;
                                }
                              }

                              /// Unfinished
                              if (unanswered != null) {
                                await showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text("Incomplete"),
                                    content: Text(
                                      "You still haven't answered question ${unanswered! + 1}.",
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text("OK"),
                                      ),
                                    ],
                                  ),
                                );

                                controller.animateToPage(
                                  unanswered,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.ease,
                                );

                                return;
                              }

                              /// Finished
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text("Your Results 🎯"),
                                  content: buildResultList(),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                      },
                                      child: const Text("CLOSE"),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: Text(
                              index == questions.length - 1
                                  ? "DONE"
                                  : "NEXT QUESTION",
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),

            SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: userAnswers[index] == null
                          ? () => answer(true)
                          : null,
                      child: Container(
                        height: 70,
                        color: Colors.green,
                        child: const Center(
                          child: Text(
                            "TRUE",
                            style: TextStyle(color: Colors.white, fontSize: 22),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: userAnswers[index] == null
                          ? () => answer(false)
                          : null,
                      child: Container(
                        height: 70,
                        color: Colors.red,
                        child: const Center(
                          child: Text(
                            "FALSE",
                            style: TextStyle(color: Colors.white, fontSize: 22),
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
    );
  }
}
