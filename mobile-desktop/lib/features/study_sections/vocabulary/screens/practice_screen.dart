import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'favorite_manager.dart';
import 'result_screen.dart';

class PracticeScreen extends StatefulWidget {
  final List<Map<String, dynamic>> vocabList;
  final String level;
  final String topic;

  const PracticeScreen({
    super.key,
    required this.vocabList,
    required this.level,
    required this.topic,
  });

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  final FlutterTts tts = FlutterTts();
  final Random random = Random();
  final FavoriteManager favoriteManager = FavoriteManager();
  int startTime = 0;

  List<Map<String, dynamic>> weakWords = [];
  Map<String, List<String>> sentenceTemplates = {
    "noun": [
      "I see a ____.",
      "She bought a ____.",
      "This is a ____.",
      "They need a ____.",
      "I have a ____.",
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

    "phrase": ["People say '____' when greeting."],

    "interjection": ["We say '____' to greet someone."],
  };
  String currentSentence = "";
  String? selectedLeftWord;
  String? selectedRightWord;
  int? selectedLeft;
  int? selectedRight;
  int? selectedOption;
  bool showResult = false;
  int questionIndex = 0;
  int correctCount = 0;
  int wrongCount = 0;
  String explanation = "";
  Map<int, int> selectedPairs = {};
  bool isCorrectAnswer = false;
  bool showMatchConfirm = false;

  Future<void> speakNormal(String text) async {
    await tts.setLanguage("en-US");
    await tts.setSpeechRate(0.5); 
    await tts.speak(text);
  }

  Future<void> speakSlow(String text) async {
    await tts.setLanguage("en-US");
    await tts.setSpeechRate(0.1); 
    await tts.speak(text);
  }

  
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
    startTime = DateTime.now().millisecondsSinceEpoch;
    loadQuestion();
  }

  void speak(String text) async {
    try {
      await tts.setLanguage("en-US");
      await tts.speak(text);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void loadQuestion() {
    selectedOption = null;
    selectedLeftWord = null;
    selectedRightWord = null;
    showResult = false;
    explanation = "";
    showMatchConfirm = false;

    selectedLeft = null;
    selectedPairs.clear();

    questionType = random.nextInt(4);

    if (widget.vocabList.isEmpty) return;

    currentWord = widget.vocabList[random.nextInt(widget.vocabList.length)];

    options = List<Map<String, dynamic>>.from(widget.vocabList)..shuffle();

    if (options.length > 4) {
      options = options.sublist(0, 4);
    }

    if (!options.contains(currentWord)) {
      options[0] = currentWord!;
    }

    String pos = currentWord!['pos'] ?? 'noun';

    List<String> templates =
        sentenceTemplates[pos] ?? sentenceTemplates['noun']!;

    templates.shuffle();
    currentSentence = templates.first;

    matchList = List<Map<String, dynamic>>.from(widget.vocabList)..shuffle();

    if (matchList.length > 4) {
      matchList = matchList.sublist(0, 4);
    }

    leftList = List.from(matchList);
    rightList = List.from(matchList)..shuffle();

    setState(() {});
  }

  void selectLeft(int index) {
    if (selectedPairs.containsKey(index)) return;

    setState(() {
      if (selectedRight != null) {
        selectedPairs[index] = selectedRight!;
        selectedLeft = null;
        selectedRight = null;
      } else {
        selectedLeft = index;
      }

      showMatchConfirm = selectedPairs.length == leftList.length;
    });
  }

  void selectRight(int index) {
    if (selectedPairs.containsValue(index)) return;

    setState(() {
      if (selectedLeft != null) {
        selectedPairs[selectedLeft!] = index;
        selectedLeft = null;
        selectedRight = null;
      } else {
        selectedRight = index;
      }

      showMatchConfirm = selectedPairs.length == leftList.length;
    });
  }

  void handleSwipe(DragEndDetails details) {
    if (details.primaryVelocity == null) return;

    
    if (details.primaryVelocity! < 0) {
      nextQuestion();
    }

    
    if (details.primaryVelocity! > 0) {
      if (questionIndex > 0) {
        questionIndex--;
        loadQuestion();
      }
    }
  }

  void nextQuestion() {
    if (!mounted) return;

    if (questionIndex >= totalQuestion - 1) {
      finishPractice();
      return;
    }

    setState(() {
      questionIndex++;
    });

    loadQuestion();
  }

  void finishPractice() {
    int endTime = DateTime.now().millisecondsSinceEpoch;
    int timeSpent = ((endTime - startTime) / 1000).round();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          correct: correctCount,
          wrong: wrongCount,
          total: totalQuestion,
          time: timeSpent,
          weakWords: weakWords,
          vocabList: widget.vocabList,
          level: widget.level,
          topic: widget.topic,
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

          weakWords.add({
            "word": currentWord!['word'],
            "meaning_vi": currentWord!['meaning_vi'],
            "pos": currentWord!['pos'],
            "phonetic": currentWord!['phonetic'],
          });
        }

        setState(() {
          selectedOption = index;
          showResult = true;
          isCorrectAnswer = isCorrect;

          explanation = isCorrect
              ? "Great! '${currentWord!['word']}' means '${currentWord!['meaning_vi']}'."
              : "Correct answer: '${currentWord!['word']}' means '${currentWord!['meaning_vi']}'.";
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

  Widget matchCard(String text, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2A38),
          borderRadius: BorderRadius.circular(10),
          border: selected
              ? Border.all(color: const Color(0xFF4F7CFE), width: 3)
              : null,
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }

  Widget explanationPanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isCorrectAnswer
            ? const Color(0xFF1B5E20)
            : const Color(0xFF7F1D1D),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrectAnswer ? Icons.check_circle : Icons.cancel,
                color: Colors.white,
              ),
              const SizedBox(width: 10),

              Text(
                isCorrectAnswer ? "Correct" : "Incorrect",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            explanation,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: nextQuestion,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Continue"),
            ),
          ),
        ],
      ),
    );
  }

  void confirmMatch() {
    bool allCorrect = true;
    List<String> correctPairs = [];

    for (int i = 0; i < leftList.length; i++) {
      int? rightIndex = selectedPairs[i];

      if (rightIndex == null) {
        allCorrect = false;
        continue;
      }

      var left = leftList[i];
      var right = rightList[rightIndex];

      bool correct = left['word'] == right['word'];

      if (!correct) {
        allCorrect = false;
      }

      correctPairs.add("${left['word']} → ${left['meaning_vi']}");
    }

    if (allCorrect) {
      correctCount++;
    } else {
      wrongCount++;

      weakWords.add({
        "word": currentWord!['word'],
        "meaning_vi": currentWord!['meaning_vi'],
        "pos": currentWord!['pos'],
        "phonetic": currentWord!['phonetic'],
      });
    }

    setState(() {
      isCorrectAnswer = allCorrect;
      showResult = true;

      explanation = allCorrect
          ? "Great! You matched all pairs correctly:\n\n${correctPairs.join("\n")}"
          : "Correct pairs:\n\n${correctPairs.join("\n")}";
    });
  }

  @override
  Widget build(BuildContext context) {
    if (currentWord == null || widget.vocabList.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text("No vocabulary data", style: TextStyle(fontSize: 20)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F1A24),
      bottomSheet: showResult ? explanationPanel() : null,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

        
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        
        actions: [
          IconButton(
            icon: Icon(
              favoriteManager.isFavorite(currentWord?['word'])
                  ? Icons.star
                  : Icons.star_border,
              color: Colors.amber,
            ),
            onPressed: () {
              if (currentWord == null) return;

              setState(() {
                favoriteManager.toggleFavorite(currentWord!);
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

              
              if (questionType == 1) ...[
                const Text(
                  "Listen and choose meaning",
                  style: TextStyle(color: Colors.white70),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    
                    IconButton(
                      iconSize: 70,
                      icon: const Icon(Icons.volume_up, color: Colors.blue),
                      onPressed: () {
                        speakNormal(currentWord!['word']);
                      },
                    ),

                    const SizedBox(width: 20),

                    
                    IconButton(
                      iconSize: 40,
                      icon: const Icon(
                        Icons.slow_motion_video,
                        color: Colors.blue,
                      ),
                      onPressed: () {
                        speakSlow(currentWord!['word']);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                ...List.generate(options.length, (i) {
                  var e = options[i];
                  return optionCard(e['meaning_vi'], e == currentWord, i);
                }),
              ],

              
              if (questionType == 2) ...[
                const Text(
                  "Listen and fill the blank",
                  style: TextStyle(color: Colors.white70),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    
                    IconButton(
                      iconSize: 70,
                      icon: const Icon(Icons.volume_up, color: Colors.blue),
                      onPressed: () {
                        speakNormal(currentWord!['word']);
                      },
                    ),

                    const SizedBox(width: 20),

                    
                    IconButton(
                      iconSize: 40,
                      icon: const Icon(
                        Icons.slow_motion_video,
                        color: Colors.blue,
                      ),
                      onPressed: () {
                        speakSlow(currentWord!['word']);
                      },
                    ),
                  ],
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

              
              if (questionType == 3) ...[
                const Text(
                  "Match word with meaning",
                  style: TextStyle(color: Colors.white70),
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: Row(
                    children: [
                      
                      Expanded(
                        child: ListView.builder(
                          itemCount: leftList.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: matchCard(
                                leftList[index]['word'],
                                selectedLeftWord == leftList[index]['word'] ||
                                    selectedPairs.containsKey(index),
                                () {
                                  setState(() {
                                    if (selectedPairs.containsKey(index)) {
                                      selectedPairs.remove(index);
                                    }

                                    selectedLeft = index;
                                    selectedLeftWord = leftList[index]['word'];

                                    if (selectedRight != null) {
                                      int rightIndex = selectedRight!;

                                      selectedPairs.remove(index);

                                      
                                      var temp = rightList[index];
                                      rightList[index] = rightList[rightIndex];
                                      rightList[rightIndex] = temp;

                                      
                                      selectedPairs[index] = index;

                                      selectedRight = null;
                                      selectedLeft = null;

                                      selectedLeftWord = null;
                                      selectedRightWord = null;
                                    }

                                    showMatchConfirm =
                                        selectedPairs.length == leftList.length;
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(width: 12),

                      
                      Expanded(
                        child: ListView.builder(
                          itemCount: rightList.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: matchCard(
                                rightList[index]['meaning_vi'],

                                selectedRightWord == rightList[index]['word'] ||
                                    selectedPairs.containsValue(index),

                                () {
                                  setState(() {
                                    selectedRight = index;
                                    selectedRightWord =
                                        rightList[index]['word'];

                                    if (selectedLeft != null) {
                                      int leftIndex = selectedLeft!;

                                      
                                      selectedPairs.remove(leftIndex);

                                      
                                      var temp = rightList[leftIndex];
                                      rightList[leftIndex] = rightList[index];
                                      rightList[index] = temp;

                                      
                                      selectedPairs[leftIndex] = leftIndex;

                                      selectedLeft = null;
                                      selectedRight = null;

                                      selectedLeftWord = null;
                                      selectedRightWord = null;
                                    }

                                    showMatchConfirm =
                                        selectedPairs.length == leftList.length;
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                if (showMatchConfirm)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: confirmMatch,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text(
                          "Confirm",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  @override
  void dispose() {
    tts.stop();
    super.dispose();
  }
}