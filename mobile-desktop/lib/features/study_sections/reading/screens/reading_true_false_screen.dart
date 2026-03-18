// import 'package:flutter/material.dart';
// import 'dart:async';
// import 'dart:math';
// import 'package:audioplayers/audioplayers.dart';
//
// class ReadingTrueFalseScreen extends StatefulWidget {
//   const ReadingTrueFalseScreen({super.key});
//
//   @override
//   State<ReadingTrueFalseScreen> createState() =>
//       _ReadingTrueFalseScreenState();
// }
//
// class _ReadingTrueFalseScreenState extends State<ReadingTrueFalseScreen>
//     with SingleTickerProviderStateMixin {
//
//   int index = 0;
//   int score = 0;
//
//   bool answered = false;
//   bool correct = false;
//
//   int seconds = 0;
//   Timer? timer;
//
//   int totalAnswered = 0;
//   int correctAnswered = 0;
//   int accuracy = 0;
//
//   late AnimationController animationController;
//
//   final player = AudioPlayer();
//
//   final List<Map<String, dynamic>> questions = [
//
//     {
//       "image":
//       "https://images.unsplash.com/photo-1606313564200-e75d5e30476c",
//       "word": "Fruit",
//       "answer": false
//     },
//     {
//       "image":
//       "https://images.unsplash.com/photo-1509042239860-f550ce710b93",
//       "word": "Coffee",
//       "answer": true
//     },
//     {
//       "image":
//       "https://images.unsplash.com/photo-1512621776951-a57141f2eefd",
//       "word": "Vegetable",
//       "answer": true
//     },
//     {
//       "image":
//       "https://images.unsplash.com/photo-1504674900247-0877df9cc836",
//       "word": "Food",
//       "answer": true
//     },
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//
//     startTimer();
//
//     animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 500),
//     );
//   }
//
//   void startTimer() {
//     seconds = 0;
//
//     timer?.cancel();
//
//     timer = Timer.periodic(const Duration(seconds: 1), (t) {
//       setState(() {
//         seconds++;
//       });
//     });
//   }
//
//   /// chọn đáp án
//   void answer(bool value) async {
//
//     if (answered) return;
//
//     bool rightAnswer = questions[index]["answer"] as bool;
//
//     timer?.cancel();
//
//     setState(() {
//
//       answered = true;
//       correct = value == rightAnswer;
//
//       if (correct) {
//         score++;
//       }
//
//       /// fake dữ liệu thống kê
//       totalAnswered = 100000 + Random().nextInt(200000);
//       correctAnswered = (totalAnswered * (0.6 + Random().nextDouble() * 0.3)).toInt();
//       accuracy = ((correctAnswered / totalAnswered) * 100).toInt();
//
//     });
//
//     animationController.forward();
//
//     /// phát âm thanh
//     if (correct) {
//       await player.play(AssetSource('sounds/correct.mp3'));
//     } else {
//       await player.play(AssetSource('sounds/wrong.mp3'));
//     }
//   }
//
//   void nextQuestion() {
//
//     if (index < questions.length - 1) {
//
//       setState(() {
//
//         index++;
//         answered = false;
//
//       });
//
//       animationController.reset();
//       startTimer();
//
//     } else {
//
//       showDialog(
//         context: context,
//         builder: (_) => AlertDialog(
//           title: const Text("Result"),
//           content: Text("$score / ${questions.length}"),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 Navigator.pop(context);
//               },
//               child: const Text("Back"),
//             )
//           ],
//         ),
//       );
//
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//     final q = questions[index];
//
//     String image = q["image"] as String;
//     String word = q["word"] as String;
//
//     return Scaffold(
//
//       appBar: AppBar(
//         title: const Text("Reading True / False"),
//         centerTitle: true,
//       ),
//
//       body: Column(
//         children: [
//
//           const SizedBox(height: 10),
//
//           /// TIMER
//           Text(
//             "Time: $seconds s",
//             style: const TextStyle(fontSize: 18),
//           ),
//
//           const SizedBox(height: 10),
//
//           /// progress
//           Text("${index + 1}/${questions.length}"),
//
//           const SizedBox(height: 20),
//
//           /// IMAGE
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(20),
//               child: Image.network(
//                 image,
//                 height: 220,
//                 width: double.infinity,
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),
//
//           const SizedBox(height: 20),
//
//           /// WORD
//           Text(
//             word,
//             style: const TextStyle(
//               fontSize: 28,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//
//           const Spacer(),
//
//           /// BUTTONS
//           Row(
//             children: [
//
//               Expanded(
//                 child: GestureDetector(
//                   onTap: () => answer(true),
//                   child: Container(
//                     height: 70,
//                     margin: const EdgeInsets.all(20),
//                     decoration: BoxDecoration(
//                       color: Colors.green,
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: const Icon(Icons.check,
//                         size: 40,
//                         color: Colors.white),
//                   ),
//                 ),
//               ),
//
//               Expanded(
//                 child: GestureDetector(
//                   onTap: () => answer(false),
//                   child: Container(
//                     height: 70,
//                     margin: const EdgeInsets.all(20),
//                     decoration: BoxDecoration(
//                       color: Colors.red,
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: const Icon(Icons.close,
//                         size: 40,
//                         color: Colors.white),
//                   ),
//                 ),
//               ),
//
//             ],
//           ),
//
//           /// RESULT + ANIMATION
//           if (answered)
//             FadeTransition(
//               opacity: animationController,
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 20),
//                 child: Column(
//                   children: [
//
//                     Text(
//                       correct ? "✔ Correct" : "✘ Wrong",
//                       style: TextStyle(
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                         color: correct ? Colors.green : Colors.red,
//                       ),
//                     ),
//
//                     const SizedBox(height: 10),
//
//                     Text(
//                       "Answer time $seconds seconds\n"
//                           "This question has been answered $totalAnswered times\n"
//                           "Accuracy rate $accuracy%",
//                       textAlign: TextAlign.center,
//                     ),
//
//                     const SizedBox(height: 20),
//
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         onPressed: nextQuestion,
//                         child: const Text(
//                           "Next Question",
//                           style: TextStyle(fontSize: 18),
//                         ),
//                       ),
//                     ),
//
//                     const SizedBox(height: 20),
//
//                   ],
//                 ),
//               ),
//             ),
//
//         ],
//       ),
//     );
//   }
// }