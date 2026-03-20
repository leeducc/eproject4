import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_desktop/core/providers/ielts_level_provider.dart';
import 'package:mobile_desktop/features/study_sections/listening/models/listening_section.dart';
import 'package:mobile_desktop/features/study_sections/listening/models/dialogue_question.dart';
import 'package:mobile_desktop/features/study_sections/listening/models/dialogue_true_false_question.dart';
import 'package:mobile_desktop/features/study_sections/listening/models/true_false_question.dart';
import 'package:mobile_desktop/features/study_sections/listening/screens/dialogue_questions_screen.dart';
import 'package:mobile_desktop/features/study_sections/listening/screens/dialogue_true_false_screen.dart';
import 'package:mobile_desktop/features/study_sections/listening/screens/smart_exam_screen.dart';
import 'true_false_screen.dart';

class ListeningScreen extends StatelessWidget {
  const ListeningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedBand =
        context.watch<IeltsLevelProvider>().selectedLevel.band;

    final List<ListeningSection> allSections = [
      ListeningSection(
        id: "1",
        title: "True False (0-4)",
        type: ListeningSectionType.trueFalse,
        ieltsLevel: IeltsBand.band0_4,
        questions: [
          TrueFalseQuestion(word: "Apple", image: "https://picsum.photos/300?1", answer: true),
          TrueFalseQuestion(word: "Dog", image: "https://picsum.photos/300?2", answer: false),
          TrueFalseQuestion(word: "Car", image: "https://picsum.photos/300?3", answer: true),
          TrueFalseQuestion(word: "Cat", image: "https://picsum.photos/300?4", answer: false),
          TrueFalseQuestion(word: "Banana", image: "https://picsum.photos/300?5", answer: true),
        ],
      ),
      ListeningSection(
        id: "5",
        title: "Basic Dialogue (0-4)",
        type: ListeningSectionType.dialogue,
        ieltsLevel: IeltsBand.band0_4,
        questions: [
          DialogueQuestion(
            audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
            question: "Is this a test dialogue for band 0-4?",
            options: ["Yes", "No", "Maybe", "I don't know"],
            correctIndex: 0,
          ),
          DialogueQuestion(
            audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
            question: "Which color is mentioned?",
            options: ["Red", "Blue", "Green", "None"],
            correctIndex: 3,
          ),
        ],
      ),
      ListeningSection(
        id: "6",
        title: "Simple Conversation (0-4)",
        type: ListeningSectionType.dialogue,
        ieltsLevel: IeltsBand.band0_4,
        questions: [
          DialogueQuestion(
            audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
            question: "Where are they meeting?",
            options: ["At the park", "At the library", "At the cafe", "At home"],
            correctIndex: 2,
          ),
          DialogueQuestion(
            audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
            question: "What drink did she order?",
            options: ["Coffee", "Tea", "Water", "Juice"],
            correctIndex: 1,
          ),
        ],
      ),
      ListeningSection(
        id: "2",
        title: "Dialogue Questions (5-6)",
        type: ListeningSectionType.dialogue,
        ieltsLevel: IeltsBand.band5_6,
        questions: [
          DialogueQuestion(
            audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
            question: "What is the main topic of the conversation?",
            options: ["Work", "Travel", "Food", "Hobby"],
            correctIndex: 1,
          ),
        ],
      ),
    ];

    final filteredSections = allSections
        .where((section) => section.ieltsLevel == selectedBand)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Listening")),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Practice Sections",
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: filteredSections.isEmpty
                  ? const Center(
                child: Text("No sections available for your current level."),
              )
                  : ListView.builder(
                itemCount: filteredSections.length,
                itemBuilder: (context, index) {
                  final section = filteredSections[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _menuCard(
                      context,
                      section.title,
                      0,
                      section.questions.length,
                      0,
                          () {
                        Widget targetScreen;

                        switch (section.type) {
                          case ListeningSectionType.trueFalse:
                            targetScreen = TrueFalseScreen(
                              title: section.title,
                              questions: List<TrueFalseQuestion>.from(section.questions),
                            );
                            break;

                          case ListeningSectionType.dialogue:
                            targetScreen = DialogueQuestionsScreen(
                              title: section.title,
                              questions: List<DialogueQuestion>.from(section.questions),
                            );
                            break;

                          case ListeningSectionType.dialogueTrueFalse:
                            targetScreen = DialogueTrueFalseScreen(
                              title: section.title,
                              questions: List<DialogueTrueFalseQuestion>.from(section.questions),
                            );
                            break;
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => targetScreen),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // ✅ SMART EXAM BUTTON
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          height: 60,
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
            onPressed: () {
              List<dynamic> pool = [];
              for (var s in filteredSections) {
                pool.addAll(s.questions);
              }

              if (pool.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("No questions available for an exam yet."),
                  ),
                );
                return;
              }

              pool.shuffle();
              final examQuestions = pool.take(5).toList();

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SmartExamScreen(questions: examQuestions),
                ),
              );
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.psychology),
                SizedBox(width: 10),
                Text("Smart Exam"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _menuCard(BuildContext context, String title, int done, int total,
      double progress, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18)),
                  Text("$done/$total"),
                ],
              ),
              const SizedBox(height: 10),
              LinearProgressIndicator(value: progress),
              const SizedBox(height: 6),
              Text("Progress ${(progress * 100).toInt()}%"),
            ],
          ),
        ),
      ),
    );
  }
}