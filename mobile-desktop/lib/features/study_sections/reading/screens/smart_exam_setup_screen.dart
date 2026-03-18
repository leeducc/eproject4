import 'package:flutter/material.dart';
import '../logic/smart_exam_engine.dart';
import 'smart_exam_screen.dart';

class SmartExamSetupScreen extends StatefulWidget {
  const SmartExamSetupScreen({super.key});

  @override
  State<SmartExamSetupScreen> createState() => _SmartExamSetupScreenState();
}

class _SmartExamSetupScreenState extends State<SmartExamSetupScreen> {

  String level = "7-8";
  String skill = "Both";
  String duration = "20";
  String mode = "smart";

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: Container(

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xff9fd3c7),
              Color(0xff89a6f5),
            ],
          ),
        ),

        child: SafeArea(

          child: SingleChildScrollView(

            child: Column(

              children: [

                const SizedBox(height:10),

                // 🔙 BACK BUTTON
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios,
                          color: Colors.black, size: 22),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),

                // HEADER
                const Text(
                  "Ra Đề Thông Minh",
                  style: TextStyle(
                    fontSize:34,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height:10),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal:40),
                  child: Text(
                    "Tạo đề thi tự động sử dụng thuật toán thông minh để tối ưu hóa kết quả học tập của bạn",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize:16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),

                const SizedBox(height:30),

                // MAIN CARD
                Container(

                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),

                  child: Column(

                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [

                      sectionTitle("Cấp độ"),
                      const SizedBox(height:10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          levelButton("0-4"),
                          levelButton("5-6"),
                          levelButton("7-8"),
                          levelButton("9"),
                        ],
                      ),

                      const SizedBox(height:25),

                      sectionTitle("Kỹ năng"),
                      const SizedBox(height:10),

                      Row(
                        children: [
                          skillButton("Listening", Icons.hearing),
                          const SizedBox(width:10),
                          skillButton("Reading", Icons.menu_book),
                          const SizedBox(width:10),
                          skillButton("Both", Icons.headphones),
                        ],
                      ),

                      const SizedBox(height:25),

                      sectionTitle("Thời lượng"),
                      const SizedBox(height:10),

                      Row(
                        children: [
                          durationButton("10", "Short 10 câu"),
                          const SizedBox(width:10),
                          durationButton("20", "Medium 20 câu"),
                          const SizedBox(width:10),
                          durationButton("40", "Full Test 40 câu"),
                        ],
                      ),

                      const SizedBox(height:25),

                      sectionTitle("Chế độ ưu tiên"),
                      const SizedBox(height:10),

                      Row(
                        children: [
                          Expanded(
                            child: modeButton(
                              "smart",
                              "Focus Mistakes",
                              Icons.gps_fixed,
                              Colors.red,
                            ),
                          ),
                          const SizedBox(width:10),
                          Expanded(
                            child: modeButton(
                              "random",
                              "Pure Random",
                              Icons.palette,
                              Colors.blue,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height:20),

                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            "Ưu tiên 50% câu sai + 40% câu mới + 10% câu đúng",
                            style: TextStyle(
                              fontSize:15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height:25),

                      // BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(

                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: EdgeInsets.zero,
                          ),

                          onPressed: generateExam,

                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xff5db6e8),
                                  Color(0xff5b8def),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Center(
                              child: Text(
                                "📋  Tạo Đề Thi",
                                style: TextStyle(
                                  fontSize:20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height:30),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          poolBox("50%", "Pool A"),
                          poolBox("40%", "Pool B"),
                          poolBox("10%", "Đúng"),
                        ],
                      ),

                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget sectionTitle(String text){
    return Text(
      text,
      style: const TextStyle(
        fontSize:20,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget levelButton(String text){
    bool selected = level == text;

    return GestureDetector(
      onTap: (){
        setState(() => level = text);
      },
      child: Container(
        width:70,
        height:40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: selected
              ? const LinearGradient(
              colors: [Color(0xff5db6e8), Color(0xff5b8def)])
              : null,
          color: selected ? null : Colors.grey.shade200,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: selected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget skillButton(String text, IconData icon){
    bool selected = skill == text;

    return Expanded(
      child: GestureDetector(
        onTap: (){
          setState(() => skill = text);
        },
        child: Container(
          height:55,
          decoration: BoxDecoration(
            color: selected ? Colors.green : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: selected ? Colors.white : Colors.black),
              const SizedBox(width:6),
              Text(
                text,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: selected ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget durationButton(String value, String text){
    bool selected = duration == value;

    return Expanded(
      child: GestureDetector(
        onTap: (){
          setState(() => duration = value);
        },
        child: Container(
          height:55,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? Colors.orange : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: selected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget modeButton(String value, String text, IconData icon, Color color){
    bool selected = mode == value;

    return GestureDetector(
      onTap: (){
        setState(() => mode = value);
      },
      child: Container(
        height:55,
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.2) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(width:6),
            Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget poolBox(String percent, String title){
    return Column(
      children: [
        Container(
          width:80,
          height:80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              percent,
              style: const TextStyle(
                fontSize:22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
        const SizedBox(height:6),
        Text(title, style: const TextStyle(color: Colors.black)),
      ],
    );
  }

  void generateExam(){
    int total = int.parse(duration);

    var exam = SmartExamEngine.generateExam(
      level: level,
      skill: skill,
      totalQuestions: total,
      smartMode: mode == "smart",
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SmartExamScreen(questions: exam),
      ),
    );
  }
}