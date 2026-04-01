import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../services/vocabulary_api_service.dart';
import 'favorite_manager.dart';
import 'practice_screen.dart';

import '../providers/vocabulary_provider.dart';
import '../services/vocabulary_test_api_service.dart';

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
  final VocabularyApiService apiService = VocabularyApiService();
  final VocabularyTestApiService testApiService = VocabularyTestApiService();
  bool isSlowMode = false;
  bool isGenerating = false;
  final Set<String> _failedWords = {};

  bool get isLastWord => currentIndex == widget.vocabularies.length - 1;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _controller = PageController(initialPage: currentIndex);
    
    // Log view for the initial word
    _logCurrentView();
  }

  void _logCurrentView() {
    final vocab = widget.vocabularies[currentIndex];
    final id = vocab['id'];
    if (id != null && id is int) {
      testApiService.logView(id);
    }
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
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.slow_motion_video,
              color: isSlowMode ? Colors.blue : Colors.white70,
            ),
            onPressed: () {
              setState(() {
                isSlowMode = !isSlowMode;
              });
            },
          ),
          Consumer<FavoriteManager>(
            builder: (context, manager, child) {
              final isFav = manager.isFavorite(widget.vocabularies[currentIndex]['word']);
              return IconButton(
                icon: Icon(
                  isFav ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                ),
                onPressed: () => manager.toggleFavorite(widget.vocabularies[currentIndex]),
              );
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
                });
                _logCurrentView();
              },
              itemCount: widget.vocabularies.length,
              itemBuilder: (context, index) {
                return _buildWordContent(widget.vocabularies[index]);
              },
            ),
          ),
          if (!isGenerating) _buildFooter(),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton(
          onPressed: () {},
          backgroundColor: const Color(0xFF1E293B),
          mini: true,
          child: const Icon(Icons.edit, color: Colors.blue, size: 20),
        ),
      ),
    );
  }

  Widget _buildProgress() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: List.generate(
          widget.vocabularies.length,
          (index) => Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              height: 3,
              decoration: BoxDecoration(
                color: index <= currentIndex ? Colors.blue : Colors.white12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWordContent(Map<String, dynamic> vocab) {
    // Trigger AI generation if definition or phonetic is missing
    final String word = vocab['word'] ?? '';
    final bool hasNoContent = (vocab['definition'] == null || vocab['definition'].toString().trim().isEmpty);

    if (hasNoContent && !isGenerating && !_failedWords.contains(word)) {
      // Trigger after build
      Future.microtask(() => _triggerAiGeneration(vocab));
    }

    if (isGenerating) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const CircularProgressIndicator(color: Colors.blue, strokeWidth: 3),
            ),
            const SizedBox(height: 24),
            const Text(
              'Đang tạo nội dung AI...',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Vui lòng chờ trong giây lát',
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ],
        ),
      );
    }

    final List<dynamic> examples = vocab['examples'] ?? [];
    
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            vocab['phonetic'] ?? '',
            style: const TextStyle(color: Colors.white54, fontSize: 18, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 8),
          
          Row(
            children: [
              Expanded(
                child: Text(
                  vocab['word'] ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.volume_up_rounded, color: Colors.blue, size: 36),
                onPressed: () => _speak(vocab['word'], 'en-US'),
              ),
            ],
          ),
          
          Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Text(
              vocab['pos'] ?? '',
              style: const TextStyle(color: Colors.blue, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
          
          const SizedBox(height: 32),
          
          const Text(
            'ĐỊNH NGHĨA',
            style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
          const SizedBox(height: 12),
          Text(
            vocab['definition'] ?? '',
            style: const TextStyle(color: Colors.white, fontSize: 17, height: 1.5, fontWeight: FontWeight.w400),
          ),
          
          const SizedBox(height: 40),
          
          const Text(
            'VÍ DỤ',
            style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
          const SizedBox(height: 20),
          if (examples.isEmpty)
            const Text('Chưa có ví dụ cho từ này.', style: TextStyle(color: Colors.white24))
          else
            ...examples.map((example) => _buildExampleItem(example.toString())),
          
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildExampleItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 18, height: 1.4, fontWeight: FontWeight.w400),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.volume_up_rounded, color: Colors.blue, size: 26),
            onPressed: () => _speak(text, 'en-US'),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          if (isLastWord) {
            _goToPractice();
          } else {
            _next();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: Text(
          isLastWord ? 'LUYỆN TẬP TỪ VỰNG' : 'TỪ TIẾP THEO',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Future<void> _speak(String text, String locale) async {
    await tts.stop();
    await tts.setLanguage(locale);
    await tts.setSpeechRate(isSlowMode ? 0.15 : 0.5);
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
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _triggerAiGeneration(Map<String, dynamic> vocab) async {
    if (isGenerating) return;
    
    setState(() {
      isGenerating = true;
    });

    try {
      final details = await apiService.fetchWordDetails(vocab['word']);
      if (details != null) {
        setState(() {
          vocab['definition'] = details['definition'];
          vocab['phonetic'] = details['phonetic'];
          vocab['examples'] = details['examples'];
          vocab['synonyms'] = details['synonyms'];
        });
      }
    } catch (e) {
      print('Error generating AI content for ${vocab['word']}: $e');
      _failedWords.add(vocab['word']);
    } finally {
      if (mounted) {
        setState(() {
          isGenerating = false;
        });
      }
    }
  }
}
