import 'package:flutter/material.dart';
import 'reading_question.dart';
import 'reading_result_screen.dart';

class ReadingExamScreen extends StatefulWidget {
  final String title;

  const ReadingExamScreen({super.key, required this.title});

  @override
  State<ReadingExamScreen> createState() => _ReadingExamScreenState();
}

class _ReadingExamScreenState extends State<ReadingExamScreen> {

  int currentIndex = 0;
  int? selectedIndex;
  int score = 0;

  late int startTime;

  @override
  void initState() {
    super.initState();
    startTime = DateTime.now().millisecondsSinceEpoch;
  }


  final List<ReadingQuestion> questions = [

    ReadingQuestion(
      image: "https://picsum.photos/400/200?random=1",
      question: "What does Xiaoming like to drink?",
      options: ["Milk", "Coffee", "Tea", "Water"],
      correctIndex: 1,
    ),

    ReadingQuestion(
      image: "https://picsum.photos/400/200?random=2",
      question: "What fruit is this?",
      options: ["Apple", "Banana", "Orange", "Grape"],
      correctIndex: 0,
    ),

    ReadingQuestion(
      image: "https://picsum.photos/400/200?random=3",
      question: "What animal is this?",
      options: ["Dog", "Cat", "Rabbit", "Tiger"],
      correctIndex: 1,
    ),

    ReadingQuestion(
      image: "https://picsum.photos/400/200?random=4",
      question: "What food is this?",
      options: ["Rice", "Pizza", "Noodle", "Bread"],
      correctIndex: 2,
    ),

    ReadingQuestion(
      image: "https://picsum.photos/400/200?random=5",
      question: "How is the weather?",
      options: ["Rainy", "Sunny", "Windy", "Cloudy"],
      correctIndex: 1,
    ),
  ];

  void nextQuestion() {

    if (selectedIndex == questions[currentIndex].correctIndex) {
      score++;
    }

    if (currentIndex < questions.length - 1) {

      setState(() {
        currentIndex++;
        selectedIndex = null;
      });

    } else {

      int totalTime =
          (DateTime.now().millisecondsSinceEpoch - startTime) ~/ 1000;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ReadingResultScreen(
            score: score,
            total: questions.length,
            time: totalTime, image: '',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    final question = questions[currentIndex];

    return Scaffold(

      appBar: AppBar(
        backgroundColor: const Color(0xffff9800),
        title: Text(widget.title),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            /// PROGRESS
            LinearProgressIndicator(
              value: (currentIndex + 1) / questions.length,
              color: Colors.orange,
            ),

            const SizedBox(height: 20),

            Text(
              "Question ${currentIndex + 1}/${questions.length}",
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 20),

            /// ✅ IMAGE KHÔNG BAO GIỜ LỖI
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                question.image,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,

                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  );
                },

                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: Icon(Icons.broken_image, size: 50),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            /// QUESTION
            Text(
              question.question,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            /// OPTIONS
            ...List.generate(question.options.length,(index){

              return GestureDetector(

                onTap: (){
                  setState(() {
                    selectedIndex = index;
                  });
                },

                child: Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.all(15),

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: selectedIndex == index
                          ? Colors.orange
                          : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),

                  child: Text(
                    question.options[index],
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              );

            }),

            const Spacer(),

            /// BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(

                onPressed: selectedIndex == null ? null : nextQuestion,

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),

                child: const Text("Tiếp tục"),
              ),
            )

          ],
        ),
      ),
    );
  }
}