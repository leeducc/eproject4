import 'package:flutter/material.dart';
import '../logic/smart_exam_logic.dart';
import 'smart_exam_screen.dart';

class SmartExamSetupScreen extends StatefulWidget {
  const SmartExamSetupScreen({super.key});

  @override
  State<SmartExamSetupScreen> createState() => _SmartExamSetupScreenState();
}

class _SmartExamSetupScreenState extends State<SmartExamSetupScreen> {

  String level = "0-4";
  String skill = "Both";
  String duration = "5";
  bool smartMode = true;

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Smart Exam Setup"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            DropdownButtonFormField(
              value: level,
              items: ["0-4","5-6","7-8","9"]
                  .map((e)=>DropdownMenuItem(
                value: e,
                child: Text(e),
              )).toList(),
              onChanged: (v){
                setState(() {
                  level = v!;
                });
              },
              decoration: const InputDecoration(labelText: "Level"),
            ),

            const SizedBox(height:20),

            DropdownButtonFormField(
              value: skill,
              items: ["Listening","Reading","Both"]
                  .map((e)=>DropdownMenuItem(
                value: e,
                child: Text(e),
              )).toList(),
              onChanged: (v){
                setState(() {
                  skill = v!;
                });
              },
              decoration: const InputDecoration(labelText: "Skill"),
            ),

            const SizedBox(height:20),

            DropdownButtonFormField(
              value: duration,
              items: ["10","20","40"]
                  .map((e)=>DropdownMenuItem(
                value: e,
                child: Text(e),
              )).toList(),
              onChanged: (v){
                setState(() {
                  duration = v!;
                });
              },
              decoration: const InputDecoration(labelText: "Number of Questions"),
            ),

            const SizedBox(height:20),

            SwitchListTile(
              title: const Text("Smart Mode"),
              value: smartMode,
              onChanged: (v){
                setState(() {
                  smartMode = v;
                });
              },
            ),

            const SizedBox(height:30),

            ElevatedButton(
              onPressed: () {

                var exam = SmartExamLogic.generateExam(
                  total: int.parse(duration),
                  levelRange: level,
                  skill: skill,
                  smartMode: smartMode,
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SmartExamScreen(questions: exam),
                  ),
                );

              },
              child: const Text("Start Exam"),
            )

          ],
        ),
      ),
    );
  }
}