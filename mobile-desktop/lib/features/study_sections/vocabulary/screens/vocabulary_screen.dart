import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/ielts_level_provider.dart';
import '../providers/vocabulary_provider.dart';
import '../models/vocabulary.dart';
import 'favorite_manager.dart';
import 'favorite_screen.dart';
import 'vocabulary_detail_screen.dart';

class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({Key? key}) : super(key: key);

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  static const bgColor = Color(0xFF0F172A);
  static const cardColor = Color(0xFF141E30);
  static const primaryBlue = Color(0xFF3B82F6);
  static const borderBlue = Color(0xFF60A5FA);

  final favoriteManager = FavoriteManager();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final levelProvider = Provider.of<IeltsLevelProvider>(context, listen: false);
      context.read<VocabularyProvider>().loadForBand(levelProvider.selectedLevel.band);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Vocabulary', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: bgColor,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FavoriteScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              final vocabProvider = Provider.of<VocabularyProvider>(context, listen: false);
              showSearch(
                context: context,
                delegate: VocabularySearchDelegate(vocabProvider.vocabularies),
              );
            },
          ),
        ],
      ),
      body: Consumer<VocabularyProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: primaryBlue));
          }

          if (provider.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  provider.error!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (provider.vocabularies.isEmpty) {
            return const Center(
              child: Text(
                'No vocabulary found.\nPlease check your connection or choose another level.',
                style: TextStyle(color: Colors.white70, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            );
          }

          final vocabularies = provider.vocabularies;
          final mappedVocabs = vocabularies.map((v) => v.toJson()).toList();
          final levelProvider = Provider.of<IeltsLevelProvider>(context, listen: false);

          return RefreshIndicator(
            onRefresh: () => provider.loadForBand(levelProvider.selectedLevel.band),
            color: primaryBlue,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: vocabularies.length,
              itemBuilder: (context, index) {
                final vocab = vocabularies[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () {
                      print('Navigating to detail screen index $index with ${mappedVocabs[index]}'); // debug log
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VocabularyDetailScreen(
                            vocabularies: mappedVocabs,
                            initialIndex: index,
                            level: levelProvider.selectedLevel.label,
                            topic: 'All',
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white12),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: primaryBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.text_fields, color: primaryBlue),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        vocab.word,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    if (vocab.pos.isNotEmpty)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.white10,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          vocab.pos,
                                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  vocab.definition.isNotEmpty ? vocab.definition : 'No definition available',
                                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(Icons.chevron_right, color: Colors.white54),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class VocabularySearchDelegate extends SearchDelegate {
  final List<Vocabulary> allVocabularies;

  VocabularySearchDelegate(this.allVocabularies);

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0F172A),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0F172A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.white54),
        border: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults(context);

  Widget _buildSearchResults(BuildContext context) {
    if (query.isEmpty) {
      return const Center(child: Text('Search vocabulary...', style: TextStyle(color: Colors.white70)));
    }

    final results = allVocabularies.where((v) {
      return v.word.toLowerCase().contains(query.toLowerCase()) ||
             v.definition.toLowerCase().contains(query.toLowerCase());
    }).toList();

    if (results.isEmpty) {
      return const Center(child: Text('No results found.', style: TextStyle(color: Colors.white70)));
    }

    final mappedAll = allVocabularies.map((v) => v.toJson()).toList();

    return ListView.builder(
      itemCount: results.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final vocab = results[index];
        return ListTile(
          title: Text(vocab.word, style: const TextStyle(color: Colors.white)),
          subtitle: Text(
            vocab.definition.isNotEmpty ? vocab.definition : vocab.pos,
            style: const TextStyle(color: Colors.white54),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () {
            print('Search Navigation: tapped ${vocab.word}');
            final realIndex = allVocabularies.indexWhere((v) => v.word == vocab.word);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VocabularyDetailScreen(
                  vocabularies: mappedAll,
                  initialIndex: realIndex != -1 ? realIndex : 0,
                  level: 'Search',
                  topic: 'All',
                ),
              ),
            );
          },
        );
      },
    );
  }
}