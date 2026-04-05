import 'package:flutter/material.dart';
import 'smart_exam_setup_screen.dart';


class ReadingTipsScreen extends StatelessWidget {
  const ReadingTipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4f4f4),

      body: Column(
        children: [

          // ===== HEADER =====
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 50,
              left: 20,
              right: 20,
              bottom: 30,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xff2ecc71),
                  Color(0xff1abc9c),
                ],
              ),
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),

                const SizedBox(height: 10),

                const Text(
                  "HSK 1 - Reading Exam Guide",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                const Text(
                  "The HSK 1 reading section consists of four parts with a total of 20 questions. The test time is 17 minutes.",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // ===== CONTENT =====
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [

                partLabel(
                  "Part 1",
                  const [
                    Color(0xff63C5B8),
                    Color(0xffBFD7D4),
                  ],
                ),

                const SizedBox(height: 12),

                _partCard(
                  context,
                  title: "Đúng hay Sai",
                  vip: false,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const  SmartExamSetupScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 30),

                partLabel(
                  "Part 2",
                  const [
                    Color(0xff7DA7D9),
                    Color(0xffD2DAE6),
                  ],
                ),

                const SizedBox(height: 12),

                _partCard(
                  context,
                  title: "Chọn hình ảnh phù hợp",
                  vip: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SmartExamSetupScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 30),

                partLabel(
                  "Part 3",
                  const [
                    Color(0xffF4A24D),
                    Color(0xffE8D4BE),
                  ],
                ),

                const SizedBox(height: 12),

                _partCard(
                  context,
                  title: "Chọn câu phù hợp",
                  vip: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SmartExamSetupScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 30),

                partLabel(
                  "Part 4",
                  const [
                    Color(0xffE7A2A2),
                    Color(0xffDCD3D6),
                  ],
                ),

                const SizedBox(height: 12),

                _partCard(
                  context,
                  title: "Điền vào chỗ trống",
                  vip: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SmartExamSetupScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),

      bottomNavigationBar: const SizedBox(height: 20),
    );
  }

  // ===== PART LABEL =====
  Widget partLabel(String text, List<Color> colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ===== CARD =====
  Widget _partCard(
      BuildContext context, {
        required String title,
        bool vip = false,
        VoidCallback? onTap,
      }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),


      onTap: vip ? null : onTap,

      child: Opacity(

        opacity: vip ? 0.6 : 1,

        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),

          child: Row(
            children: [

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              if (vip)
                const Icon(
                  Icons.lock,
                  color: Colors.amber,
                ),
            ],
          ),
        ),
      ),
    );
  }
}