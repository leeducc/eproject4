import 'package:flutter/material.dart';

class TopicVocabularyScreen extends StatelessWidget {
  final String topicName;
  final List<Map<String, dynamic>> vocabularies;

  const TopicVocabularyScreen({
    Key? key,
    required this.topicName,
    required this.vocabularies,
  }) : super(key: key);

  static const bgColor = Color(0xFF161A23);
  static const cardColor = Color(0xFF1F2430);
  static const primaryColor = Color(0xFF4F7CFE);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,

      // ===== APP BAR =====
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          topicName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      // ===== BODY =====
      body: Column(
        children: [
          // ---- TOTAL WORDS ----
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.library_books_outlined,
                    size: 16,
                    color: Colors.white70,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Học ${vocabularies.length} từ mới',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ---- LIST ----
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: vocabularies.length,
              itemBuilder: (context, index) {
                final item = vocabularies[index];
                return _vocabItem(item);
              },
            ),
          ),

          // ---- BOTTOM BUTTONS ----
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Row(
              children: [
                Expanded(
                  child: _bottomButton(
                    text: 'Học từ vựng',
                    background: primaryColor,
                    textColor: Colors.white,
                    onTap: () {
                      // TODO: điều hướng sang màn học từ đầu tiên
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _bottomButton(
                    text: 'Luyện tập',
                    background: primaryColor,
                    textColor: Colors.white,
                    onTap: () {
                      // TODO: điều hướng sang màn test
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===== VOCAB ITEM =====
  Widget _vocabItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item['word'],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${item['phonetic']} • ${item['pos']}',
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item['meaning'],
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ===== BUTTON =====
  Widget _bottomButton({
    required String text,
    required Color background,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}