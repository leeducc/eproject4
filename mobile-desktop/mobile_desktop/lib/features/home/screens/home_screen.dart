import 'package:flutter/material.dart';


import '../../study_sections/listening/screens/listening_screen.dart';
import '../../study_sections/reading/screens/reading_screen.dart';
import '../../study_sections/writing/screens/writing_screen.dart';
import '../../study_sections/speaking/screens/speaking_screen.dart';
import '../../study_sections/simulate_exam/screens/simulate_exam_screen.dart';
import '../../study_sections/real_exam/screens/real_exam_screen.dart';
import '../../study_sections/vocabulary/screens/vocabulary_screen.dart';
import '../../study_sections/wrong_answers/screens/wrong_answers_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF161A23), // Màu nền tối
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBanner(),
            const SizedBox(height: 24),
            _buildSectionsGrid(context),
            const SizedBox(height: 24),
            _buildProgressCard(),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Row(
        children: [
          const Text('IELTS 6.0', style: TextStyle(color: Colors.white, fontSize: 16)),
          const Icon(Icons.arrow_drop_down, color: Colors.white),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 16),
                SizedBox(width: 4),
                Text('PLUS', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          const Icon(Icons.notifications_none, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF3A7BD5), Color(0xFF00D2FF)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Stack(
        children: [
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Từ vựng mới', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                SizedBox(height: 8),
                Text('IELTS Band 7-9 đã lên sóng!', style: TextStyle(color: Colors.white, fontSize: 14)),
              ],
            ),
          ),
          Positioned(
            right: -10,
            bottom: -20,
            child: Icon(Icons.menu_book, size: 110, color: Colors.white.withOpacity(0.2)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionsGrid(BuildContext context) {
    // Danh sách 8 chức năng và màn hình đích tương ứng
    final List<Map<String, dynamic>> sections = [
      {'title': 'Nghe', 'icon': Icons.headphones, 'color': Colors.orange, 'screen': const ListeningScreen()},
      {'title': 'Nói', 'icon': Icons.mic_none, 'color': Colors.purple, 'screen': const SpeakingScreen()},
      {'title': 'Đọc hiểu', 'icon': Icons.menu_book, 'color': Colors.yellow.shade700, 'screen': const ReadingScreen()},
      {'title': 'Viết', 'icon': Icons.edit_document, 'color': Colors.green, 'screen': const WritingScreen()},
      {'title': 'Đề mô phỏng', 'icon': Icons.insert_drive_file, 'color': Colors.lightBlue, 'screen': const SimulateExamScreen()},
      {'title': 'Đề thi thật', 'icon': Icons.assignment, 'color': Colors.indigo, 'screen': const RealExamScreen()},
      {'title': 'Từ vựng', 'icon': Icons.abc, 'color': Colors.blueAccent, 'screen': const VocabularyScreen()},
      {'title': 'Các câu trả lời sai', 'icon': Icons.fact_check, 'color': Colors.redAccent, 'screen': const WrongAnswersScreen()},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: sections.length,
      itemBuilder: (context, index) {
        final item = sections[index];
        return GestureDetector(
          onTap: () {
            // Chuyển hướng tới màn hình tương ứng
            Navigator.push(context, MaterialPageRoute(builder: (context) => item['screen']));
          },
          child: Column(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: item['color'].withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(item['icon'], color: item['color'], size: 28),
              ),
              const SizedBox(height: 8),
              Text(
                item['title'],
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFFE94057), Color(0xFFF27121)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Bao đỗ IELTS', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              Icon(Icons.info_outline, color: Colors.white54, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Khoá học giúp bạn đạt Target IELTS được thiết kế bởi giáo viên giàu kinh nghiệm',
            style: TextStyle(color: Colors.white, fontSize: 13),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: const LinearProgressIndicator(
                    value: 0.1,
                    backgroundColor: Colors.white24,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('Target 6.0', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10)),
              )
            ],
          )
        ],
      ),
    );
  }
}