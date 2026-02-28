import 'package:flutter/material.dart';

import 'vocabulary_detail_screen.dart';

class TopicVocabularyScreen extends StatefulWidget {
  final String topicName;

  const TopicVocabularyScreen({
    Key? key,
    required this.topicName,
  }) : super(key: key);

  @override
  State<TopicVocabularyScreen> createState() =>
      _TopicVocabularyScreenState();
}

class _TopicVocabularyScreenState extends State<TopicVocabularyScreen> {
  int selectedFilter = 0; // 0: All, 1: Unlearned, 2: Learned

  final List<Map<String, dynamic>> vocabularies = [
    {
      'word': 'Curriculum',
      'ipa': '/kəˈrɪkjʊləm/',
      'meaning': 'Chương trình học',
      'example': 'The school curriculum includes science and math.',
      'learned': true,
    },
    {
      'word': 'Assignment',
      'ipa': '/əˈsaɪnmənt/',
      'meaning': 'Bài tập',
      'example': 'The teacher gave us a difficult assignment.',
      'learned': false,
    },
    {
      'word': 'Lecture',
      'ipa': '/ˈlɛktʃər/',
      'meaning': 'Bài giảng',
      'example': 'The lecture lasted for two hours.',
      'learned': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final total = vocabularies.length;
    final learned =
        vocabularies.where((e) => e['learned'] == true).length;
    final progress = learned / total;

    final filteredList = vocabularies.where((item) {
      if (selectedFilter == 1) return item['learned'] == false;
      if (selectedFilter == 2) return item['learned'] == true;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF161A23),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.topicName,
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildHeader(total, learned, progress),
          _buildFilter(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                return _buildVocabularyItem(
                  filteredList[index],
                  index,
                  filteredList,
                );
              },
            ),
          ),
          _buildBottomAction(),
        ],
      ),
    );
  }

  // ===== HEADER =====
  Widget _buildHeader(int total, int learned, double progress) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2430),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$learned / $total từ đã học',
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white12,
            valueColor:
            const AlwaysStoppedAnimation(Color(0xFF4CAF50)),
          ),
        ],
      ),
    );
  }

  // ===== FILTER =====
  Widget _buildFilter() {
    final filters = ['Tất cả', 'Chưa học', 'Đã học'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(filters.length, (index) {
          final isSelected = selectedFilter == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => selectedFilter = index);
              },
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFF1F2430),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  filters[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color:
                    isSelected ? Colors.black : Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ===== VOCAB ITEM =====
  Widget _buildVocabularyItem(
      Map<String, dynamic> vocab,
      int index,
      List<Map<String, dynamic>> vocabularies,
      ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VocabularyDetailScreen(
              vocabularies: vocabularies,
              initialIndex: index,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1F2430),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vocab['word'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  vocab['meaning'],
                  style: const TextStyle(color: Colors.white54),
                ),
              ],
            ),
            Icon(
              vocab['learned']
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: vocab['learned']
                  ? const Color(0xFF4CAF50)
                  : Colors.white24,
            ),
          ],
        ),
      ),
    );
  }

  // ===== BOTTOM CTA =====
  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF161A23),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
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
                    builder: (_) => VocabularyDetailScreen(
                      vocabularies: vocabularies,
                      initialIndex: 0,
                    ),
                  ),
                );
              },
              child: const Text(
                'Học ngay',
                style:
                TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: () {
            },
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
    );
  }
}