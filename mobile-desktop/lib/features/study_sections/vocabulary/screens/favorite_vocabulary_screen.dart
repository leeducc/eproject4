import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'favorite_manager.dart';
import 'vocabulary_detail_screen.dart';

class FavoriteVocabularyScreen extends StatefulWidget {
  const FavoriteVocabularyScreen({Key? key}) : super(key: key);

  @override
  State<FavoriteVocabularyScreen> createState() => _FavoriteVocabularyScreenState();
}

class _FavoriteVocabularyScreenState extends State<FavoriteVocabularyScreen> with SingleTickerProviderStateMixin {
  static const bgColor = Color(0xFF0F172A);
  static const primaryBlue = Color(0xFF3B82F6);
  static const cardColor = Color(0xFF1E293B);

  late TabController _tabController;
  final List<String> _levels = ['0-4', '5-6', '7-8', '9'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _levels.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Từ vựng yêu thích', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: bgColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: primaryBlue,
          labelColor: primaryBlue,
          unselectedLabelColor: Colors.grey,
          tabs: _levels.map((l) => Tab(text: 'Band $l')).toList(),
        ),
      ),
      body: Consumer<FavoriteManager>(
        builder: (context, manager, child) {
          return RefreshIndicator(
            onRefresh: () => manager.syncWithBackend(),
            child: TabBarView(
              controller: _tabController,
            children: _levels.map((level) {
              final words = manager.favorites.where((v) => v['levelGroup'] == level).toList();
              
              if (words.isEmpty) {
                return const Center(
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: 400, // Enough height to catch the drag
                      child: Center(
                        child: Text(
                          'Chưa có từ vựng yêu thích nào',
                          style: TextStyle(color: Colors.white54, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                ),
                itemCount: words.length,
                itemBuilder: (context, index) {
                  final vocab = words[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VocabularyDetailScreen(
                            vocabularies: words,
                            initialIndex: index,
                            level: 'Yêu thích',
                            topic: 'Band ${vocab['levelGroup']}',
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            vocab['word'] ?? '',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            vocab['phonetic'] ?? '',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: primaryBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              vocab['pos'] ?? '',
                              style: const TextStyle(
                                color: primaryBlue,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        );
      },
      ),
    );
  }
}
