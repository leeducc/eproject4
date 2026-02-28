import 'package:flutter/material.dart';

import 'review_screen.dart';
import 'topic_vocabulary_screen.dart';

class VocabularyScreen extends StatelessWidget {
  const VocabularyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF161A23),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Vocabulary',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _buildProgressCard(),
            const SizedBox(height: 24),
            _buildSectionTitle('Chủ đề phổ biến'),
            const SizedBox(height: 12),
            _buildTopicGrid(context),
            const SizedBox(height: 24),
            _buildSectionTitle('Danh sách từ vựng'),
            const SizedBox(height: 12),
            _buildVocabularyItem(
              title: 'IELTS Academic Vocabulary',
              total: 120,
              learned: 45,
            ),
            _buildVocabularyItem(
              title: 'Daily Conversation',
              total: 80,
              learned: 80,
            ),
            _buildVocabularyItem(
              title: 'Work & Office',
              total: 60,
              learned: 20,
            ),
            const SizedBox(height: 24),
            _buildReviewButton(context),
          ],
        ),
      ),
    );
  }

  // ===== Widgets =====

  Widget _buildProgressCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2430),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Tiến độ học hôm nay',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          SizedBox(height: 8),
          LinearProgressIndicator(
            value: 0.6,
            backgroundColor: Colors.white12,
            valueColor: AlwaysStoppedAnimation(Color(0xFF4CAF50)),
          ),
          SizedBox(height: 8),
          Text(
            '30 / 50 từ đã học',
            style: TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTopicGrid(BuildContext context) {
    final topics = [
      {'title': 'Education', 'icon': Icons.school},
      {'title': 'Travel', 'icon': Icons.flight_takeoff},
      {'title': 'Technology', 'icon': Icons.memory},
      {'title': 'Health', 'icon': Icons.favorite},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: topics.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TopicVocabularyScreen(
                  topicName: topics[index]['title'] as String,
                ),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1F2430),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  topics[index]['icon'] as IconData,
                  color: const Color(0xFF4CAF50),
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  topics[index]['title'] as String,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVocabularyItem({
    required String title,
    required int total,
    required int learned,
  }) {
    final progress = learned / total;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2430),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white12,
            valueColor: const AlwaysStoppedAnimation(Color(0xFF4CAF50)),
          ),
          const SizedBox(height: 6),
          Text(
            '$learned / $total từ',
            style: const TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4CAF50),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ReviewScreen(dueWords: [],),
          ),
        );
      },
      child: const Text(
        'Ôn tập thông minh',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}