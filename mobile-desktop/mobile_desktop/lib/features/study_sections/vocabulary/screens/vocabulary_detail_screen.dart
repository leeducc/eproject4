import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class VocabularyDetailScreen extends StatefulWidget {
  final List<Map<String, dynamic>> vocabularies;
  final int initialIndex;

  const VocabularyDetailScreen({
    Key? key,
    required this.vocabularies,
    required this.initialIndex,
  }) : super(key: key);

  @override
  State<VocabularyDetailScreen> createState() =>
      _VocabularyDetailScreenState();
}

class _VocabularyDetailScreenState extends State<VocabularyDetailScreen> {
  late PageController _controller;
  late int currentIndex;
  final FlutterTts tts = FlutterTts();

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _controller = PageController(initialPage: currentIndex);
  }

  @override
  void dispose() {
    tts.stop();
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
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              widget.vocabularies[currentIndex]['favorite'] == true
                  ? Icons.star
                  : Icons.star_border,
              color: Colors.amber,
            ),
            onPressed: () {
              setState(() {
                widget.vocabularies[currentIndex]['favorite'] =
                !(widget.vocabularies[currentIndex]['favorite'] ?? false);
              });
            },
          )
        ],
      ),
      body: Column(
        children: [
          _buildProgress(),
          Expanded(
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (index) {
                setState(() => currentIndex = index);
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
                    ? const Color(0xFF4CAF50)
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
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Spacer(),
          Text(
            vocab['word'],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            vocab['ipa'],
            style: const TextStyle(color: Colors.white54),
          ),
          const SizedBox(height: 24),

          // ===== AUDIO =====
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _audioButton('en-GB', 'UK'),
              const SizedBox(width: 16),
              _audioButton('en-US', 'US'),
            ],
          ),

          const SizedBox(height: 32),
          Text(
            vocab['meaning'],
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 24),

          _highlightExample(vocab['example'], vocab['word']),

          const Spacer(),

          Row(
            children: [
              Expanded(
                child: _actionButton(
                  'Chưa nhớ',
                  Colors.redAccent,
                      () => _next(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _actionButton(
                  'Đã nhớ',
                  const Color(0xFF4CAF50),
                      () {
                    vocab['learned'] = true;
                    _next();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ===== AUDIO =====
  Widget _audioButton(String locale, String label) {
    return GestureDetector(
      onTap: () async {
        await tts.setLanguage(locale);
        await tts.speak(widget.vocabularies[currentIndex]['word']);
      },
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Text(label,
            style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  // ===== HIGHLIGHT EXAMPLE =====
  Widget _highlightExample(String sentence, String word) {
    final parts = sentence.split(RegExp(word, caseSensitive: false));

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          TextSpan(
              text: parts[0],
              style: const TextStyle(color: Colors.white54)),
          TextSpan(
              text: word,
              style: const TextStyle(
                  color: Color(0xFF4CAF50),
                  fontWeight: FontWeight.bold)),
          TextSpan(
              text: parts.length > 1 ? parts[1] : '',
              style: const TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }

  // ===== ACTION =====
  Widget _actionButton(
      String text, Color color, VoidCallback onTap) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      onPressed: onTap,
      child: Text(text,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold)),
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