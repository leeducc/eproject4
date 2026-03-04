import 'package:flutter/material.dart';

class ReadingScreen extends StatelessWidget {
  const ReadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4f4f4),

      // ====== BODY ======
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xfff4f4f4),
                borderRadius:
                BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: const [
                  SizedBox(height: 10),
                  SectionTitle(title: "Phần 1"),
                  ReadingPartCard(
                    title: "Phán đoán đúng sai",
                    isVip: false,
                  ),
                  SizedBox(height: 20),
                  SectionTitle(title: "Phần 2"),
                  ReadingPartCard(
                    title: "Chọn hình ảnh tương ứng",
                    isVip: true,
                  ),
                  SizedBox(height: 20),
                  SectionTitle(title: "Phần 3"),
                  ReadingPartCard(
                    title: "Chọn câu tương ứng",
                    isVip: true,
                  ),
                  SizedBox(height: 20),
                  SectionTitle(title: "Phần 4"),
                  ReadingPartCard(
                    title: "Sắp xếp câu",
                    isVip: false,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // ====== BOTTOM BUTTONS ======
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Center(
                  child: Text(
                    "Bí kíp làm bài",
                    style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.blue, Colors.lightBlueAccent],
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Center(
                  child: Text(
                    "Ra đề thông minh",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding:
      const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 30),
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xffffb74d), Color(0xffff9800)],
        ),
      ),
      child: Column(
        children: [
          const Text(
            "Đọc hiểu",
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
          const SizedBox(height: 25),
          _buildStatRow("Tổng số câu trả lời", "0 lần"),
          const SizedBox(height: 10),
          _buildStatRow("Trả lời đúng", "0 lần"),
          const SizedBox(height: 10),
          _buildStatRow("Thời gian trả lời", "00:00"),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("Nắm vững",
                  style: TextStyle(color: Colors.white)),
              Text("0%",
                  style: TextStyle(color: Colors.white)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: const LinearProgressIndicator(
              value: 0,
              minHeight: 8,
              backgroundColor: Colors.white30,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(color: Colors.white)),
        Text(value,
            style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.grey),
    );
  }
}

class ReadingPartCard extends StatelessWidget {
  final String title;
  final bool isVip;

  const ReadingPartCard({
    super.key,
    required this.title,
    required this.isVip,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration:
            const Duration(milliseconds: 400),
            pageBuilder: (_, animation, __) => FadeTransition(
              opacity: animation,
              child: ReadingExamScreen(title: title),
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                  if (isVip)
                    const Padding(
                      padding: EdgeInsets.only(left: 6),
                      child: Icon(
                        Icons.workspace_premium,
                        color: Colors.amber,
                        size: 18,
                      ),
                    )
                ],
              ),
            ),
            const Text(
              "0/5",
              style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w600),
            )
          ],
        ),
      ),
    );
  }
}

// ================= EXAM SCREEN =================

class ReadingExamScreen extends StatefulWidget {
  final String title;
  const ReadingExamScreen({super.key, required this.title});

  @override
  State<ReadingExamScreen> createState() =>
      _ReadingExamScreenState();
}

class _ReadingExamScreenState
    extends State<ReadingExamScreen> {
  int currentIndex = 0;
  int? selectedIndex;
  int score = 0;

  final questions = [
    {
      "question": "小明喜欢喝什么？",
      "options": ["牛奶", "咖啡", "茶", "水"],
      "answer": 2
    },
    {
      "question": "今天天气怎么样？",
      "options": ["热", "冷", "下雨", "晴天"],
      "answer": 3
    },
  ];

  void nextQuestion() {
    if (selectedIndex ==
        questions[currentIndex]["answer"]) {
      score++;
    }

    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;
        selectedIndex = null;
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ReadingResultScreen(
            score: score,
            total: questions.length,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = questions[currentIndex];

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            LinearProgressIndicator(
              value:
              (currentIndex + 1) / questions.length,
              color: Colors.orange,
            ),
            const SizedBox(height: 30),
            Text(
              question["question"].toString(),
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            ...(question["options"] as List<String>)
                .asMap()
                .entries
                .map((entry) {
              int index = entry.key;
              String option = entry.value;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedIndex = index;
                  });
                },
                child: Container(
                  margin:
                  const EdgeInsets.only(bottom: 15),
                  padding:
                  const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    borderRadius:
                    BorderRadius.circular(15),
                    border: Border.all(
                      color: selectedIndex == index
                          ? Colors.orange
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(option),
                ),
              );
            }).toList(),
            const Spacer(),
            ElevatedButton(
              onPressed:
              selectedIndex == null ? null : nextQuestion,
              child: const Text("Tiếp tục"),
            )
          ],
        ),
      ),
    );
  }
}

// ================= RESULT SCREEN =================

class ReadingResultScreen extends StatelessWidget {
  final int score;
  final int total;

  const ReadingResultScreen({
    super.key,
    required this.score,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    double percent = score / total * 100;

    return Scaffold(
      appBar: AppBar(title: const Text("Kết quả")),
      body: Center(
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Text(
              "$score / $total",
              style: const TextStyle(fontSize: 40),
            ),
            const SizedBox(height: 10),
            Text("${percent.toStringAsFixed(1)}%"),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Làm lại"),
            )
          ],
        ),
      ),
    );
  }
}