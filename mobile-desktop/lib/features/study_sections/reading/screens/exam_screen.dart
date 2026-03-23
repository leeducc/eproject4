import 'package:flutter/material.dart';
import '../models/question_model.dart';
import '../user/user_history.dart';

class ExamScreen extends StatefulWidget {

  final List<Question> questions;

  const ExamScreen({super.key, required this.questions});

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {

  int current = 0;

  int? selected;

  @override
  Widget build(BuildContext context) {

    Question q = widget.questions[current];

    return Scaffold(

      appBar: AppBar(
        title: Text("Question ${current+1}/${widget.questions.length}"),
        backgroundColor: const Color(0xff4facfe),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Text(
              q.question,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height:30),

            ...List.generate(q.options.length, (index){

              return GestureDetector(

                onTap: (){
                  setState(() {
                    selected = index;
                  });
                },

                child: Container(

                  margin: const EdgeInsets.only(bottom:10),

                  padding: const EdgeInsets.all(14),

                  decoration: BoxDecoration(

                    borderRadius: BorderRadius.circular(12),

                    border: Border.all(color: Colors.grey.shade300),

                    color: selected == index
                        ? Colors.blue.shade100
                        : Colors.white,
                  ),

                  child: Text(q.options[index]),
                ),
              );
            }),

            const Spacer(),

            SizedBox(

              width: double.infinity,

              height: 50,

              child: ElevatedButton(

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff4facfe),
                ),

                onPressed: nextQuestion,

                child: const Text("Next"),
              ),
            )
          ],
        ),
      ),
    );
  }

  void nextQuestion(){

    Question q = widget.questions[current];

    if(selected == q.correctIndex){

      UserHistory.markCorrect(q.id);

    }else{

      UserHistory.markWrong(q.id);

    }

    if(current < widget.questions.length - 1){

      setState(() {

        current++;
        selected = null;

      });

    }else{

      Navigator.pop(context);

    }
  }

}