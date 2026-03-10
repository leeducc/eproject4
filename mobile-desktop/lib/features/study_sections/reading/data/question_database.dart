import '../models/question_model.dart';

class QuestionDatabase {

  static List<Question> questions = [

    Question(
      id: 1,
      question: "What does Xiao Ming like to drink?",
      options: ["Milk", "Coffee", "Tea", "Water"],
      answer: 2,
      level: 2,
      skill: "Reading",
    ),

    Question(
      id: 2,
      question: "How is the weather today?",
      options: ["Hot", "Cold", "Rainy", "Sunny"],
      answer: 3,
      level: 3,
      skill: "Reading",
    ),

    Question(
      id: 3,
      question: "What is she doing?",
      options: ["Reading", "Sleeping", "Running", "Eating"],
      answer: 0,
      level: 5,
      skill: "Listening",
    ),

    Question(
      id: 4,
      question: "Where is the book?",
      options: ["Table", "Chair", "Bag", "Floor"],
      answer: 0,
      level: 7,
      skill: "Reading",
    ),

    Question(
      id: 5,
      question: "What time is it?",
      options: ["6", "7", "8", "9"],
      answer: 1,
      level: 6,
      skill: "Listening",
    ),
    Question(
      id: 6,
      question: "Where is the cat?",
      options: ["Under table","On table","In box","Near door"],
      answer: 1,
      level: 4,
      skill: "Reading",
    ),

    Question(
      id: 7,
      question: "What is he eating?",
      options: ["Rice","Bread","Noodles","Apple"],
      answer: 2,
      level: 3,
      skill: "Listening",
    ),

    Question(
      id: 8,
      question: "What color is the car?",
      options: ["Red","Blue","Green","Black"],
      answer: 0,
      level: 5,
      skill: "Reading",
    ),

    Question(
      id: 9,
      question: "Where are they going?",
      options: ["School","Market","Home","Park"],
      answer: 3,
      level: 6,
      skill: "Listening",
    ),

    Question(
      id: 10,
      question: "What day is today?",
      options: ["Monday","Tuesday","Wednesday","Sunday"],
      answer: 0,
      level: 2,
      skill: "Reading",
    ),

  ];
}