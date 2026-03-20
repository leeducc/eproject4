import '../models/question_model.dart';

class QuestionBank {

  static List<Question> questions = [

    // ========= LEVEL 0-4 =========
    Question(
      id: 1,
      skill: "reading",
      level: 2, // ✅ FIX
      question: "Hello",
      options: ["Hello", "Bye", "Thanks", "Sorry"],
      correctIndex: 0,
    ),

    Question(
      id: 2,
      skill: "listening",
      level: 3,
      question: "Thank you",
      options: ["Hello", "Thanks", "Sorry", "Please"],
      correctIndex: 1,
    ),

    // ========= LEVEL 5-6 =========
    Question(
      id: 3,
      skill: "reading",
      level: 5,
      question: "What are you doing?",
      options: [
        "What are you doing?",
        "Where are you?",
        "Who are you?",
        "What is this?"
      ],
      correctIndex: 0,
    ),

    Question(
      id: 4,
      skill: "listening",
      level: 6,
      question: "The weather is very nice today",
      options: [
        "The weather is good today",
        "It is raining",
        "It is cold",
        "It is windy"
      ],
      correctIndex: 0,
    ),

    // ========= LEVEL 7-8 =========
    Question(
      id: 5,
      skill: "reading",
      level: 7,
      question: "He is a teacher",
      options: [
        "He is a teacher",
        "He is a student",
        "He is a doctor",
        "He is a driver"
      ],
      correctIndex: 0,
    ),

    Question(
      id: 6,
      skill: "reading",
      level: 8,
      question: "She likes drinking coffee",
      options: [
        "She likes tea",
        "She likes coffee",
        "She likes milk",
        "She likes juice"
      ],
      correctIndex: 1,
    ),

    Question(
      id: 7,
      skill: "listening",
      level: 7,
      question: "What is your name?",
      options: [
        "What is your name",
        "Where are you from",
        "How old are you",
        "What are you doing"
      ],
      correctIndex: 0,
    ),

    Question(
      id: 8,
      skill: "listening",
      level: 8,
      question: "What time is it now?",
      options: [
        "What time is it",
        "What day is today",
        "Where are you",
        "Who are you"
      ],
      correctIndex: 0,
    ),

    // ========= LEVEL 9 =========
    Question(
      id: 9,
      skill: "reading",
      level: 9,
      question: "He has already completed all the tasks yesterday",
      options: [
        "He finished all tasks yesterday",
        "He will finish tasks",
        "He forgot tasks",
        "He is doing tasks"
      ],
      correctIndex: 0,
    ),

    Question(
      id: 10,
      skill: "listening",
      level: 9,
      question: "If you study hard, you will definitely succeed",
      options: [
        "If you study hard, you will succeed",
        "You will fail",
        "You are lazy",
        "You don't study"
      ],
      correctIndex: 0,
    ),
  ];
}