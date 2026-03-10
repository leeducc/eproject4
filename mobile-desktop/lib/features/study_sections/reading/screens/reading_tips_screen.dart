import 'package:flutter/material.dart';
import 'smart_exam_setup_screen.dart';
import 'true_false_tip_screen.dart';

class ReadingTipsScreen extends StatelessWidget {
  const ReadingTipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4f4f4),

      body: Column(
        children: [

          // ===== HEADER WITH WAVE =====
          Stack(
            children: [

              Container(
                height: 200,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xff2ecc71), Color(0xff1abc9c)],
                  ),
                ),
              ),

              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: ClipPath(
                  clipper: WaveClipper(),
                  child: Container(
                    height: 60,
                    color: const Color(0xfff4f4f4),
                  ),
                ),
              ),

              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: Colors.white),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        "HSK 1 - Reading Exam Guide",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 15),

                      const Text(
                        "The HSK 1 reading section consists of four parts with a total of 20 questions. The test time is 17 minutes.",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),

          // ===== CONTENT =====
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [

                partLabel("Part 1"),

                const SizedBox(height: 10),

                _partCard(
                  context,
                  title: "True or False",
                  icon: Icons.check_circle_outline,
                  vip: false,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TrueFalseTipScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 30),

                partLabel("Part 2"),

                const SizedBox(height: 10),

                _partCard(
                  context,
                  title: "Choose the matching picture",
                  icon: Icons.image_outlined,
                  vip: true,
                ),

                const SizedBox(height: 30),

                partLabel("Part 3"),

                const SizedBox(height: 10),

                _partCard(
                  context,
                  title: "Choose the matching sentence",
                  icon: Icons.menu_book_outlined,
                  vip: true,
                ),

                const SizedBox(height: 30),

                partLabel("Part 4"),

                const SizedBox(height: 10),

                _partCard(
                  context,
                  title: "Fill in the blank",
                  icon: Icons.edit_outlined,
                  vip: true,
                ),
              ],
            ),
          )
        ],
      ),

      // ===== SMART EXAM BUTTON =====
      bottomNavigationBar: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const SmartExamSetupScreen(),
            ),
          );
        },
        child: Container(
          height: 60,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.lightBlueAccent],
            ),
          ),
          child: const Text(
            "Smart Exam Generator",
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  // ===== PART LABEL =====
  Widget partLabel(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff4facfe), Color(0xff00f2fe)],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ===== CARD =====
  Widget _partCard(BuildContext context,
      {required String title,
        required IconData icon,
        bool vip = false,
        VoidCallback? onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [

            // ICON
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xffEAF4FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.blue),
            ),

            const SizedBox(width: 15),

            // TITLE
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
            ),

            // VIP LOCK
            if (vip)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock,
                  size: 18,
                  color: Colors.orange,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    path.lineTo(0, size.height - 20);

    path.quadraticBezierTo(
        size.width / 2, size.height + 20, size.width, size.height - 20);

    path.lineTo(size.width, 0);

    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}