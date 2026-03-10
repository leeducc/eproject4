import 'package:flutter/material.dart';
import '../models/question_model.dart';
import 'result_screen.dart';

class SmartExamScreen extends StatefulWidget {

  final List<Question> questions;

  const SmartExamScreen({super.key, required this.questions});

  @override
  State<SmartExamScreen> createState() => _SmartExamScreenState();
}

class _SmartExamScreenState extends State<SmartExamScreen> {

  int index = 0;
  int score = 0;

  void answer(int selected) {

    Question q = widget.questions[index];

    if(selected == q.answer){

      score++;
      q.status = 2;

    }else{

      q.status = 1;

    }

    if(index < widget.questions.length - 1){

      setState(() {
        index++;
      });

    }else{

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            score: score,
            total: widget.questions.length,
          ),
        ),
      );

    }
  }

  @override
  Widget build(BuildContext context) {

    Question q = widget.questions[index];

    return Scaffold(

      appBar: AppBar(
        title: Text("${index+1}/${widget.questions.length}"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            Text(
              q.question,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height:30),

            ...List.generate(q.options.length, (i){

              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom:10),
                child: ElevatedButton(
                  onPressed: ()=>answer(i),
                  child: Text(q.options[i]),
                ),
              );

            })

          ],
        ),
      ),
    );
  }
}