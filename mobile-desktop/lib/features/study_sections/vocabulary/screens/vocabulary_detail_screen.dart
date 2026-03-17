import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'favorite_manager.dart';

import 'practice_screen.dart';

class VocabularyDetailScreen extends StatefulWidget {
  final List<Map<String, dynamic>> vocabularies;
  final int initialIndex;
  final String level;
  final String topic;

  const VocabularyDetailScreen({
    Key? key,
    required this.vocabularies,
    required this.initialIndex,
    required this.level,
    required this.topic,
  }) : super(key: key);

  @override
  State<VocabularyDetailScreen> createState() => _VocabularyDetailScreenState();
}

class _VocabularyDetailScreenState extends State<VocabularyDetailScreen> {
  late PageController _controller;
  late int currentIndex;
  final FlutterTts tts = FlutterTts();
  final FavoriteManager favoriteManager = FavoriteManager();
  bool showMeaning = false;
  bool isSlowMode = false;

  bool get isLastWord => currentIndex == widget.vocabularies.length - 1;

  Icon _speakerIcon() {
    return Icon(
      isSlowMode ? Icons.slow_motion_video : Icons.volume_up_rounded,
      color: isSlowMode ? Colors.lightGreenAccent : const Color(0xFF4F7CFE),
    );
  }

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _controller = PageController(initialPage: currentIndex);
  }

  @override
  void dispose() {
    tts.stop();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF161A23),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          // 🐢 Slow mode
          IconButton(
            icon: Icon(
              Icons.slow_motion_video,
              color: isSlowMode ? Colors.lightGreenAccent : Colors.white54,
            ),
            tooltip: isSlowMode ? 'Đọc bình thường' : 'Đọc chậm',
            onPressed: () {
              setState(() {
                isSlowMode = !isSlowMode;
              });
            },
          ),
          // ⭐ Favorite
          IconButton(
            icon: Icon(
              favoriteManager.isFavorite(widget.vocabularies[currentIndex]['word'])
                  ? Icons.star
                  : Icons.star_border,
              color: Colors.amber,
            ),
            onPressed: () {
              setState(() {
                favoriteManager.toggleFavorite(
                  widget.vocabularies[currentIndex],
                );
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildProgress(),
          Expanded(
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (index) {
                setState(() {
                  currentIndex = index;
                  showMeaning = false;
                });
              },
              itemCount: widget.vocabularies.length,
              itemBuilder: (context, index) {
                return _buildWordCard(widget.vocabularies[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ===== PROGRESS DOTS =====
  Widget _buildProgress() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: List.generate(
          widget.vocabularies.length,
          (index) => Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              height: 4,
              decoration: BoxDecoration(
                color: index <= currentIndex
                    ? const Color(0xFF4F7CFE)
                    : Colors.white12,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===== WORD CARD =====
  Widget _buildWordCard(Map<String, dynamic> vocab) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ===== WORD (EN) =====
          Row(
            children: [
              Expanded(
                child: Text(
                  vocab['word'] ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                icon: _speakerIcon(),
                onPressed: () => _speak(vocab['word'], 'en-US'),
              ),
            ],
          ),

          /// ===== WORD (VI) – CHỈ HIỆN KHI BẤM =====
          if (showMeaning)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                vocab['vi'] ?? '',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

          const SizedBox(height: 8),

          /// ===== PHONETIC =====
          Text(
            vocab['phonetic'] ?? '',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          /// ===== POS =====
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF4F7CFE).withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              vocab['pos'] ?? '',
              style: const TextStyle(color: Color(0xFF4F7CFE), fontSize: 12),
            ),
          ),

          const SizedBox(height: 16),
          const Divider(color: Colors.white12),
          const SizedBox(height: 12),

          /// ===== MEANING (EN) – LUÔN HIỆN =====
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  vocab['meaning'] ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
              ),
              IconButton(
                icon: _speakerIcon(),
                onPressed: () => _speak(vocab['meaning'], 'en-US'),
              ),
            ],
          ),

          /// ===== MEANING (VI) – CHỈ HIỆN KHI BẤM =====
          if (showMeaning)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                vocab['meaning_vi'] ?? '',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),

          const Spacer(),

          /// ===== FOOTER =====
          GestureDetector(
            onTap: () {
              setState(() {
                if (!showMeaning) {
                  // Lần 1: hiện nghĩa
                  showMeaning = true;
                } else {
                  // Lần 2
                  if (isLastWord) {
                    // 👉 TODO: đi sang màn luyện tập
                    _goToPractice();
                  } else {
                    _next();
                    showMeaning = false;
                  }
                }
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: showMeaning
                    ? const Color(0xFF4F7CFE)
                    : Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  _footerText(),
                  style: TextStyle(
                    color: showMeaning ? Colors.white : Colors.white70,
                    fontSize: 15,
                    fontWeight: showMeaning ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _footerText() {
    if (!showMeaning) {
      return 'Nhấp vào để xem nghĩa tiếng Việt';
    }

    if (isLastWord) {
      return 'Luyện tập từ vựng';
    }

    return 'Từ tiếp theo';
  }

  Future<void> _speak(String text, String locale) async {
    await tts.stop();
    await tts.setLanguage(locale);

    await tts.setSpeechRate(isSlowMode ? 0.1 : 0.5);

    await tts.setPitch(1.0);
    await tts.speak(text);
  }

  void _goToPractice() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PracticeScreen(
          vocabList: widget.vocabularies,
          level: widget.level,
          topic: widget.topic,
        ),
      ),
    );
  }

  void _next() {
    if (currentIndex < widget.vocabularies.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
      Navigator.pop(context);
    }
  }
}
