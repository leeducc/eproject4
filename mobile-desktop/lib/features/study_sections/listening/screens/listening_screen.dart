import 'package:flutter/material.dart';
import 'package:mobile_desktop/features/study_sections/listening/models/dialogue_question.dart';
import 'package:mobile_desktop/features/study_sections/listening/models/dialogue_true_false_question.dart';
import 'package:mobile_desktop/features/study_sections/listening/models/true_false_question.dart';
import 'package:mobile_desktop/features/study_sections/listening/screens/dialogue_questions_screen.dart';
import 'package:mobile_desktop/features/study_sections/listening/screens/dialogue_true_false_screen.dart';
import 'true_false_screen.dart';

class ListeningScreen extends StatelessWidget {
  const ListeningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for dynamic loading
    final List<TrueFalseQuestion> trueFalseQuestions = [
      TrueFalseQuestion(word: "Apple", image: "https://picsum.photos/300?1", answer: true),
      TrueFalseQuestion(word: "Dog", image: "https://picsum.photos/300?2", answer: false),
      TrueFalseQuestion(word: "Car", image: "https://picsum.photos/300?3", answer: true),
      TrueFalseQuestion(word: "Cat", image: "https://picsum.photos/300?4", answer: false),
      TrueFalseQuestion(word: "Banana", image: "https://picsum.photos/300?5", answer: true),
    ];

    final List<DialogueQuestion> dialogueQuestions = [
      DialogueQuestion(
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
        question: "What is the main topic of the conversation?",
        options: ["Work", "Travel", "Food", "Hobby"],
        correctIndex: 1,
      ),
      DialogueQuestion(
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
        question: "Where are they planning to go?",
        options: ["Paris", "London", "Tokyo", "New York"],
        correctIndex: 0,
      ),
      DialogueQuestion(
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
        question: "Who is the speaker talking to?",
        options: ["Friend", "Doctor", "Teacher", "Boss"],
        correctIndex: 2,
      ),
      DialogueQuestion(
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3',
        question: "What time does the meeting start?",
        options: ["8:00 AM", "9:30 AM", "10:00 AM", "2:00 PM"],
        correctIndex: 1,
      ),
      DialogueQuestion(
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-9.mp3',
        question: "How much does the ticket cost?",
        options: ["\$10", "\$20", "\$50", "\$100"],
        correctIndex: 3,
      ),
    ];

    final List<DialogueTrueFalseQuestion> dialogueTrueFalseQuestions = [
      DialogueTrueFalseQuestion(
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
        question: "The speaker is talking about their new job.",
        answer: true,
      ),
      DialogueTrueFalseQuestion(
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
        question: "They are planning to travel to London next week.",
        answer: false,
      ),
      DialogueTrueFalseQuestion(
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
        question: "The teacher is explaining the math homework.",
        answer: true,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Listening")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _section("Section 1"),
              _menuCard(
                context,
                "True / False",
                2,
                trueFalseQuestions.length,
                2 / trueFalseQuestions.length,
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TrueFalseScreen(questions: trueFalseQuestions),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              _section("Section 2"),
              _menuCard(
                context,
                "Dialogue Questions",
                0,
                dialogueQuestions.length,
                0,
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DialogueQuestionsScreen(questions: dialogueQuestions),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              _section("Section 3"),
              _menuCard(
                context,
                "Dialogue True/False",
                0,
                dialogueTrueFalseQuestions.length,
                0,
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DialogueTrueFalseScreen(questions: dialogueTrueFalseQuestions),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(String text) => Align(
    alignment: Alignment.centerLeft,
    child: Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text,
          style: const TextStyle(color: Colors.grey, fontSize: 12)),
    ),
  );

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
