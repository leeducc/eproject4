import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/ielts_level_provider.dart';
import '../providers/vocabulary_provider.dart';
import '../models/vocabulary.dart';
import 'vocabulary_detail_screen.dart';
import 'favorite_vocabulary_screen.dart';
import 'favorite_manager.dart';
import 'daily_test_screen.dart';
import '../../../ranking/providers/ranking_provider.dart';

class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({Key? key}) : super(key: key);

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> with SingleTickerProviderStateMixin {
  static const primaryBlue = Color(0xFF3B82F6);
  
  late TabController _tabController;

  late RankingProvider _rankingProvider;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: kIeltsLevels.length, vsync: this);
    
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _rankingProvider = context.read<RankingProvider>();
      _rankingProvider.pushLearningScreen();
      
      final levelProvider = Provider.of<IeltsLevelProvider>(context, listen: false);
      final index = kIeltsLevels.indexWhere((l) => l.band == levelProvider.selectedLevel.band);
      if (index != -1) {
        _tabController.index = index;
      }
      _loadDataForTab(_tabController.index);
    });

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _loadDataForTab(_tabController.index);
      }
    });
  }

  void _loadDataForTab(int index) {
    final band = kIeltsLevels[index].band;
    context.read<VocabularyProvider>().loadForBand(band);
  }

  @override
  void dispose() {
    _rankingProvider.popLearningScreen();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    debugPrint('[VocabularyScreen] build – brightness: ${theme.brightness}');

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Từ vựng IELTS', style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        actions: [
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
          IconButton(
            icon: const Icon(Icons.quiz, color: Colors.blue),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DailyTestScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.star, color: Colors.amber),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoriteVocabularyScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.white),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: primaryBlue,
          labelColor: primaryBlue,
          unselectedLabelColor: colorScheme.onSurface.withOpacity(0.5),
          tabs: kIeltsLevels.map((level) => Tab(text: level.label)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: kIeltsLevels.map((level) => VocabularyGrid(band: level.band)).toList(),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          border: Border(top: BorderSide(color: colorScheme.onSurface.withOpacity(0.05))),
        ),
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Bắt đầu luyện tập', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

class VocabularyGrid extends StatelessWidget {
  final IeltsBand band;

  const VocabularyGrid({Key? key, required this.band}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<VocabularyProvider>(
      builder: (context, provider, child) {
        final theme = Theme.of(context);
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator(color: Colors.blue));
        }

        if (provider.error != null) {
          return Center(child: Text(provider.error!, style: const TextStyle(color: Colors.red)));
        }

        final vocabularies = provider.vocabularies;
        if (vocabularies.isEmpty) {
          return Center(child: Text('Chưa có từ vựng cho band này', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6))));
        }

        return RefreshIndicator(
          onRefresh: () async => provider.loadForBand(band),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: HeaderSection(count: vocabularies.length, band: band),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.blue, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Từ vựng xuất hiện nhiều trong IELTS',
                        style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5), fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final vocab = vocabularies[index];
                      return GridCell(
                        index: index + 1,
                        vocab: vocab,
                        onTap: () {
                          final mappedVocabs = vocabularies.map((v) => v.toJson()).toList();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => VocabularyDetailScreen(
                                vocabularies: mappedVocabs,
                                initialIndex: index,
                                level: band.name,
                                topic: 'All',
                              ),
                            ),
                          );
                        },
                      );
                    },
                    childCount: vocabularies.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 80)), 
            ],
          ),
        );
      },
    );
  }
}

class HeaderSection extends StatelessWidget {
  final int count;
  final IeltsBand band;

  const HeaderSection({Key? key, required this.count, required this.band}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final level = kIeltsLevels.firstWhere((l) => l.band == band);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.onSurface.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [level.primaryColor, level.accentColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: level.primaryColor.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'A',
                style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Từ vựng mới ${level.label} ($count)',
                  style: TextStyle(color: colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.flash_on, color: Colors.blue, size: 16),
                    const SizedBox(width: 4),
                    Text('0/', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontSize: 13)),
                    Text('$count', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontSize: 13)),
                    const SizedBox(width: 16),
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text('0/0', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 0.0,
                    backgroundColor: colorScheme.onSurface.withOpacity(0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GridCell extends StatelessWidget {
  final int index;
  final Vocabulary vocab;
  final VoidCallback onTap;

  const GridCell({Key? key, required this.index, required this.vocab, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue.withOpacity(0.3), width: 1.5),
            ),
            child: Center(
              child: Text(
                '$index',
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          if (vocab.isPremium)
            const Positioned(
              top: -6,
              left: -6,
              child: Icon(
                Icons.workspace_premium, 
                color: Colors.amber,
                size: 20,
              ),
            ),
          Positioned(
            top: -6,
            right: -6,
            child: Consumer<FavoriteManager>(
              builder: (context, manager, child) {
                final isFav = manager.isFavorite(vocab.word);
                if (!isFav) return const SizedBox.shrink();
                return const Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 20,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class VocabularySearchDelegate extends SearchDelegate {
  final List<Vocabulary> allVocabularies;

  VocabularySearchDelegate(this.allVocabularies);

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: theme.appBarTheme.copyWith(
        elevation: 0,
      ),
      inputDecorationTheme: const InputDecorationTheme(
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    if (query.isEmpty) {
      return Center(child: Text('Search vocabulary...', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6))));
    }

    final results = allVocabularies.where((v) {
      return v.word.toLowerCase().contains(query.toLowerCase()) ||
             v.definition.toLowerCase().contains(query.toLowerCase());
    }).toList();

    if (results.isEmpty) {
      return Center(child: Text('No results found.', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6))));
    }

    final mappedAll = allVocabularies.map((v) => v.toJson()).toList();

    return ListView.builder(
      itemCount: results.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final vocab = results[index];
        return ListTile(
          title: Text(vocab.word, style: TextStyle(color: colorScheme.onSurface)),
          subtitle: Text(
            vocab.definition.isNotEmpty ? vocab.definition : vocab.pos,
            style: TextStyle(color: colorScheme.onSurface.withOpacity(0.54)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () {
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