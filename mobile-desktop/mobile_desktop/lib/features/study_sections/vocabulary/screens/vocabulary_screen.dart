import 'package:flutter/material.dart';
import 'review_screen.dart';
import 'topic_vocabulary_screen.dart';

class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({Key? key}) : super(key: key);

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen>
    with SingleTickerProviderStateMixin {
  // ===== Colors =====
  static const bgColor = Color(0xFF0F172A);
  static const cardColor = Color(0xFF141E30);
  static const primaryBlue = Color(0xFF3B82F6);
  static const borderBlue = Color(0xFF60A5FA);

  late TabController _tabController;
  final Map<String, List<Map<String, dynamic>>> topicVocabularyData = {
    'Colors': [
      {
        'word': 'red',
        'phonetic': '/red/',
        'pos': 'noun',
        'meaning': 'the color of blood',
        'learned': false,
      },
      {
        'word': 'blue',
        'phonetic': '/bluː/',
        'pos': 'noun',
        'meaning': 'the color of the sky',
        'learned': false,
      },
    ],

    'Animals': [
      {
        'word': 'dog',
        'phonetic': '/dɒɡ/',
        'pos': 'noun',
        'meaning': 'a common domestic animal',
        'learned': false,
      },
      {
        'word': 'cat',
        'phonetic': '/kæt/',
        'pos': 'noun',
        'meaning': 'a small domestic animal',
        'learned': false,
      },
    ],

    'Objects': [
      {
        'word': 'table',
        'phonetic': '/ˈteɪbl/',
        'pos': 'noun',
        'meaning': 'a piece of furniture',
        'learned': false,
      },
      {
        'word': 'chair',
        'phonetic': '/tʃeə/',
        'pos': 'noun',
        'meaning': 'something you sit on',
        'learned': false,
      },
    ],
    'Greetings': [
      {
        'word': 'hello',
        'phonetic': '/həˈləʊ/',
        'pos': 'exclamation',
        'meaning': 'used to greet someone',
        'learned': false,
      },
      {
        'word': 'goodbye',
        'phonetic': '/ˌɡʊdˈbaɪ/',
        'pos': 'exclamation',
        'meaning': 'used when leaving',
        'learned': false,
      },
    ],

    'Time': [
      {
        'word': 'today',
        'phonetic': '/təˈdeɪ/',
        'pos': 'noun',
        'meaning': 'the present day',
        'learned': false,
      },
      {
        'word': 'tomorrow',
        'phonetic': '/təˈmɒrəʊ/',
        'pos': 'noun',
        'meaning': 'the day after today',
        'learned': false,
      },
    ],

    'Places': [
      {
        'word': 'school',
        'phonetic': '/skuːl/',
        'pos': 'noun',
        'meaning': 'a place to study',
        'learned': false,
      },
      {
        'word': 'home',
        'phonetic': '/həʊm/',
        'pos': 'noun',
        'meaning': 'the place where you live',
        'learned': false,
      },
    ],
    'Family': [
      {
        'word': 'father',
        'phonetic': '/ˈfɑːðə/',
        'pos': 'noun',
        'meaning': 'male parent',
        'learned': false,
      },
      {
        'word': 'mother',
        'phonetic': '/ˈmʌðə/',
        'pos': 'noun',
        'meaning': 'female parent',
        'learned': false,
      },
    ],

    'School': [
      {
        'word': 'student',
        'phonetic': '/ˈstjuːdənt/',
        'pos': 'noun',
        'meaning': 'a person who studies',
        'learned': false,
      },
      {
        'word': 'teacher',
        'phonetic': '/ˈtiːtʃə/',
        'pos': 'noun',
        'meaning': 'a person who teaches',
        'learned': false,
      },
    ],

    'Sports': [
      {
        'word': 'football',
        'phonetic': '/ˈfʊtbɔːl/',
        'pos': 'noun',
        'meaning': 'a popular team sport',
        'learned': false,
      },
      {
        'word': 'swimming',
        'phonetic': '/ˈswɪmɪŋ/',
        'pos': 'noun',
        'meaning': 'moving in water',
        'learned': false,
      },
    ],
    'Food': [
      {
        'word': 'breakfast',
        'phonetic': '/ˈbrekfəst/',
        'pos': 'noun',
        'meaning': 'the first meal of the day',
        'learned': false,
      },
      {
        'word': 'delicious',
        'phonetic': '/dɪˈlɪʃəs/',
        'pos': 'adjective',
        'meaning': 'tastes very good',
        'learned': false,
      },
    ],

    'Shopping': [
      {
        'word': 'price',
        'phonetic': '/praɪs/',
        'pos': 'noun',
        'meaning': 'the cost of something',
        'learned': false,
      },
      {
        'word': 'discount',
        'phonetic': '/ˈdɪskaʊnt/',
        'pos': 'noun',
        'meaning': 'a reduction in price',
        'learned': false,
      },
    ],

    'Transport': [
      {
        'word': 'bus',
        'phonetic': '/bʌs/',
        'pos': 'noun',
        'meaning': 'a public vehicle',
        'learned': false,
      },
      {
        'word': 'train',
        'phonetic': '/treɪn/',
        'pos': 'noun',
        'meaning': 'a railway vehicle',
        'learned': false,
      },
    ],

    'Weather': [
      {
        'word': 'rain',
        'phonetic': '/reɪn/',
        'pos': 'noun',
        'meaning': 'water falling from the sky',
        'learned': false,
      },
      {
        'word': 'sunny',
        'phonetic': '/ˈsʌni/',
        'pos': 'adjective',
        'meaning': 'full of sunshine',
        'learned': false,
      },
    ],
    // ===== HSK 5 =====
    'Travel': [
      {
        'word': 'airport',
        'phonetic': '/ˈeəpɔːt/',
        'pos': 'noun',
        'meaning': 'a place where airplanes land and take off',
        'learned': false,
      },
      {
        'word': 'passport',
        'phonetic': '/ˈpɑːspɔːt/',
        'pos': 'noun',
        'meaning': 'an official document for international travel',
        'learned': false,
      },
      {
        'word': 'luggage',
        'phonetic': '/ˈlʌɡɪdʒ/',
        'pos': 'noun',
        'meaning': 'bags and suitcases for traveling',
        'learned': false,
      },
    ],

    'Work': [
      {
        'word': 'employee',
        'phonetic': '/ˌemplɔɪˈiː/',
        'pos': 'noun',
        'meaning': 'a person who works for a company',
        'learned': false,
      },
      {
        'word': 'deadline',
        'phonetic': '/ˈdedlaɪn/',
        'pos': 'noun',
        'meaning': 'the latest time something must be done',
        'learned': false,
      },
    ],

    'Media': [
      {
        'word': 'broadcast',
        'phonetic': '/ˈbrɔːdkɑːst/',
        'pos': 'verb',
        'meaning': 'to send out programs by radio or TV',
        'learned': false,
      },
      {
        'word': 'journalist',
        'phonetic': '/ˈdʒɜːnəlɪst/',
        'pos': 'noun',
        'meaning': 'a person who reports news',
        'learned': false,
      },
    ],

    'Lifestyle': [
      {
        'word': 'routine',
        'phonetic': '/ruːˈtiːn/',
        'pos': 'noun',
        'meaning': 'daily habits or activities',
        'learned': false,
      },
      {
        'word': 'balance',
        'phonetic': '/ˈbæləns/',
        'pos': 'noun',
        'meaning': 'a state of equal or proper proportions',
        'learned': false,
      },
    ],

    // ===== HSK 6 =====
    'Technology': [
      {
        'word': 'software',
        'phonetic': '/ˈsɒftweə/',
        'pos': 'noun',
        'meaning': 'computer programs',
        'learned': false,
      },
      {
        'word': 'database',
        'phonetic': '/ˈdeɪtəbeɪs/',
        'pos': 'noun',
        'meaning': 'an organized collection of data',
        'learned': false,
      },
      {
        'word': 'algorithm',
        'phonetic': '/ˈælɡərɪðəm/',
        'pos': 'noun',
        'meaning': 'a set of rules to solve a problem',
        'learned': false,
      },
    ],

    'Business': [
      {
        'word': 'investment',
        'phonetic': '/ɪnˈvestmənt/',
        'pos': 'noun',
        'meaning': 'the act of putting money into something',
        'learned': false,
      },
      {
        'word': 'profit',
        'phonetic': '/ˈprɒfɪt/',
        'pos': 'noun',
        'meaning': 'money earned after costs are paid',
        'learned': false,
      },
    ],

    'Education': [
      {
        'word': 'assignment',
        'phonetic': '/əˈsaɪnmənt/',
        'pos': 'noun',
        'meaning': 'a task given to students',
        'learned': false,
      },
      {
        'word': 'curriculum',
        'phonetic': '/kəˈrɪkjələm/',
        'pos': 'noun',
        'meaning': 'subjects taught in a course',
        'learned': false,
      },
    ],

    'Health': [
      {
        'word': 'nutrition',
        'phonetic': '/njuːˈtrɪʃn/',
        'pos': 'noun',
        'meaning': 'the process of eating healthy food',
        'learned': false,
      },
      {
        'word': 'exercise',
        'phonetic': '/ˈeksəsaɪz/',
        'pos': 'noun',
        'meaning': 'physical activity to stay healthy',
        'learned': false,
      },
    ],

    'Environment': [
      {
        'word': 'pollution',
        'phonetic': '/pəˈluːʃn/',
        'pos': 'noun',
        'meaning': 'damage to air, water, or land',
        'learned': false,
      },
      {
        'word': 'recycle',
        'phonetic': '/ˌriːˈsaɪkl/',
        'pos': 'verb',
        'meaning': 'to reuse materials',
        'learned': false,
      },
    ],

    // ===== HSK 7–9 =====
    'Politics': [
      {
        'word': 'democracy',
        'phonetic': '/dɪˈmɒkrəsi/',
        'pos': 'noun',
        'meaning': 'government by the people',
        'learned': false,
      },
      {
        'word': 'election',
        'phonetic': '/ɪˈlekʃn/',
        'pos': 'noun',
        'meaning': 'a process of choosing leaders',
        'learned': false,
      },
    ],

    'Economy': [
      {
        'word': 'inflation',
        'phonetic': '/ɪnˈfleɪʃn/',
        'pos': 'noun',
        'meaning': 'general increase in prices',
        'learned': false,
      },
      {
        'word': 'recession',
        'phonetic': '/rɪˈseʃn/',
        'pos': 'noun',
        'meaning': 'a period of economic decline',
        'learned': false,
      },
    ],

    'Law': [
      {
        'word': 'legislation',
        'phonetic': '/ˌledʒɪsˈleɪʃn/',
        'pos': 'noun',
        'meaning': 'laws passed by a government',
        'learned': false,
      },
      {
        'word': 'justice',
        'phonetic': '/ˈdʒʌstɪs/',
        'pos': 'noun',
        'meaning': 'fair treatment by law',
        'learned': false,
      },
    ],

    'Philosophy': [
      {
        'word': 'ethics',
        'phonetic': '/ˈeθɪks/',
        'pos': 'noun',
        'meaning': 'moral principles',
        'learned': false,
      },
      {
        'word': 'existence',
        'phonetic': '/ɪɡˈzɪstəns/',
        'pos': 'noun',
        'meaning': 'the state of being',
        'learned': false,
      },
    ],

    'Research': [
      {
        'word': 'hypothesis',
        'phonetic': '/haɪˈpɒθəsɪs/',
        'pos': 'noun',
        'meaning': 'a proposed explanation',
        'learned': false,
      },
      {
        'word': 'analysis',
        'phonetic': '/əˈnæləsɪs/',
        'pos': 'noun',
        'meaning': 'detailed examination of data',
        'learned': false,
      },
    ],

    'Culture': [
      {
        'word': 'tradition',
        'phonetic': '/trəˈdɪʃn/',
        'pos': 'noun',
        'meaning': 'customs passed down generations',
        'learned': false,
      },
      {
        'word': 'heritage',
        'phonetic': '/ˈherɪtɪdʒ/',
        'pos': 'noun',
        'meaning': 'cultural inheritance',
        'learned': false,
      },
    ],
  };

  final hskData = [
    {
      'level': 'HSK7-9',
      'total': 300,
      'lessons': 20,
      'topics': [
        {'title': 'Politics', 'icon': Icons.account_balance},
        {'title': 'Economy', 'icon': Icons.trending_up},
        {'title': 'Law', 'icon': Icons.gavel},
        {'title': 'Philosophy', 'icon': Icons.psychology},
        {'title': 'Research', 'icon': Icons.science},
        {'title': 'Culture', 'icon': Icons.public},
      ]
    },
    {
      'level': 'HSK6',
      'total': 250,
      'lessons': 18,
      'topics': [
        {'title': 'Business', 'icon': Icons.business_center},
        {'title': 'Technology', 'icon': Icons.computer},
        {'title': 'Health', 'icon': Icons.health_and_safety},
        {'title': 'Environment', 'icon': Icons.eco},
        {'title': 'Education', 'icon': Icons.school},
      ]
    },
    {
      'level': 'HSK5',
      'total': 200,
      'lessons': 16,
      'topics': [
        {'title': 'Work', 'icon': Icons.work},
        {'title': 'Travel', 'icon': Icons.flight_takeoff},
        {'title': 'Media', 'icon': Icons.movie},
        {'title': 'Lifestyle', 'icon': Icons.self_improvement},
      ]
    },
    {
      'level': 'HSK4',
      'total': 180,
      'lessons': 15,
      'topics': [
        {'title': 'Food', 'icon': Icons.restaurant},
        {'title': 'Shopping', 'icon': Icons.shopping_bag},
        {'title': 'Transport', 'icon': Icons.directions_bus},
        {'title': 'Weather', 'icon': Icons.cloud},
      ]
    },
    {
      'level': 'HSK3',
      'total': 150,
      'lessons': 14,
      'topics': [
        {'title': 'Family', 'icon': Icons.family_restroom},
        {'title': 'School', 'icon': Icons.menu_book},
        {'title': 'Sports', 'icon': Icons.sports_soccer},
      ]
    },
    {
      'level': 'HSK2',
      'total': 150,
      'lessons': 14,
      'topics': [
        {'title': 'Greetings', 'icon': Icons.waving_hand},
        {'title': 'Time', 'icon': Icons.access_time},
        {'title': 'Places', 'icon': Icons.place},
      ]
    },
    {
      'level': 'HSK1',
      'total': 150,
      'lessons': 14,
      'topics': [
        {'title': 'Colors', 'icon': Icons.palette},
        {'title': 'Animals', 'icon': Icons.pets},
        {'title': 'Objects', 'icon': Icons.category},
      ]
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: hskData.length,
      initialIndex: hskData.length - 1,
      vsync: this,
    );
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ===== BUILD =====
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: _buildAppBar(context),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTopCard(),
            const SizedBox(height: 16),
            Expanded(child: _buildTopicGrid()),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: _buildStartButton(context),
      ),
    );
  }

  // ===== AppBar =====
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: bgColor,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        'Từ vựng HSK 2.0',
        style: TextStyle(color: Colors.white, fontSize: 17),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, size: 18),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () async {
            await showSearch(
              context: context,
              delegate: LessonSearchDelegate(
                List.generate(
                  hskData[_tabController.index]['lessons'] as int,
                      (i) => i + 1,
                ),
              ),
            );
          },
        ),
        PopupMenuButton<int>(
          icon: const Icon(Icons.more_horiz),
          color: cardColor,
          offset: const Offset(0, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          itemBuilder: (context) => [
            PopupMenuItem<int>(
              value: 1,
              child: Row(
                children: const [
                  Icon(Icons.star, color: Colors.yellow, size: 18),
                  SizedBox(width: 10),
                  Text(
                    'Chữ Tiếng Anh đã lưu',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            PopupMenuItem<int>(
              value: 2,
              child: Row(
                children: const [
                  Icon(Icons.book, color: Colors.blue, size: 18),
                  SizedBox(width: 10),
                  Text(
                    'Từ mới',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 1) {
              // TODO: reset progress
            } else if (value == 2) {
              // TODO: show info
            }
          },
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        isScrollable: false,
        dividerColor: Colors.transparent,
        indicatorColor: Color(0xFF3B82F6),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white54,
        tabs:
        hskData.map((e) => Tab(text: e['level'] as String)).toList(),
      ),
    );
  }

  // ===== Top Card =====
  Widget _buildTopCard() {
    final current = hskData[_tabController.index];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: primaryBlue.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.book, color: primaryBlue),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Từ vựng mới ${current['level']} (${current['total']})',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '0 / ${current['total']}    ⭐ 0 / ${current['lessons']}',
                  style: const TextStyle(color: Colors.white54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicGrid() {
    final topics =
    hskData[_tabController.index]['topics'] as List<Map>;

    return GridView.builder(
      itemCount: topics.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.3,
      ),
      itemBuilder: (_, i) {
        final topic = topics[i];
        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            final topicTitle = topic['title'];

            // MOCK vocab theo topic (sau này đổi sang API / DB)
            final vocabByTopic = topicVocabularyData[topicTitle] ?? [];

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TopicVocabularyScreen(
                  topicName: topicTitle,
                  vocabularies: vocabByTopic,
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderBlue, width: 1.2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: primaryBlue.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    topic['icon'],
                    color: primaryBlue,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  topic['title'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ===== Footer Button =====
  Widget _buildStartButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: () {
          final currentLevel = hskData[_tabController.index];
          final topics = currentLevel['topics'] as List<Map>;

          if (topics.isEmpty) return;

          // 👉 chủ đề đầu tiên của level
          final firstTopic = topics.first;
          final topicTitle = firstTopic['title'];

          final vocabularies = topicVocabularyData[topicTitle] ?? [];

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TopicVocabularyScreen(
                topicName: topicTitle,
                vocabularies: vocabularies,
              ),
            ),
          );
        },
        child: const Text(
          'Bắt đầu luyện tập',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// ===== SEARCH DELEGATE =====
class LessonSearchDelegate extends SearchDelegate<int?> {
  final List<int> lessons;

  LessonSearchDelegate(this.lessons);

  @override
  String get searchFieldLabel => 'Tìm từ, dịch nghĩa, ví dụ';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final result =
    lessons.where((e) => e.toString().contains(query)).toList();
    return _buildList(result, context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final result =
    lessons.where((e) => e.toString().contains(query)).toList();
    return _buildList(result, context);
  }

  Widget _buildList(List<int> items, BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (_, i) => ListTile(
        title: Text(
          'Bài ${items[i]}',
          style: const TextStyle(color: Colors.white),
        ),
        onTap: () => close(context, items[i]),
      ),
    );
  }
}