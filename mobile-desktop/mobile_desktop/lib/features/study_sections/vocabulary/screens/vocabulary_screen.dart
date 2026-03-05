import 'package:flutter/material.dart';
import 'topic_vocabulary_screen.dart';
import 'vocabulary_detail_screen.dart';

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
        'vi': 'màu đỏ',
        'phonetic': '/red/',
        'pos': 'noun',
        'meaning': 'the color of blood',
        'meaning_vi': 'màu của máu',
      },
      {
        'word': 'blue',
        'vi': 'màu xanh dương',
        'phonetic': '/bluː/',
        'pos': 'noun',
        'meaning': 'the color of the sky',
        'meaning_vi': 'màu của bầu trời',
      },
    ],

    'Animals': [
      {
        'word': 'dog',
        'vi': 'con chó',
        'phonetic': '/dɒɡ/',
        'pos': 'noun',
        'meaning': 'a common domestic animal',
        'meaning_vi': 'một loài động vật nuôi phổ biến',
      },
      {
        'word': 'cat',
        'vi': 'con mèo',
        'phonetic': '/kæt/',
        'pos': 'noun',
        'meaning': 'a small domestic animal',
        'meaning_vi': 'một loài động vật nuôi nhỏ',
      },
    ],

    'Objects': [
      {
        'word': 'table',
        'vi': 'cái bàn',
        'phonetic': '/ˈteɪbl/',
        'pos': 'noun',
        'meaning': 'a piece of furniture',
        'meaning_vi': 'một món đồ nội thất',
      },
      {
        'word': 'chair',
        'vi': 'cái ghế',
        'phonetic': '/tʃeə/',
        'pos': 'noun',
        'meaning': 'something you sit on',
        'meaning_vi': 'vật dùng để ngồi',
      },
    ],

    'Greetings': [
      {
        'word': 'hello',
        'vi': 'xin chào',
        'phonetic': '/həˈləʊ/',
        'pos': 'exclamation',
        'meaning': 'used to greet someone',
        'meaning_vi': 'dùng để chào hỏi ai đó',
      },
      {
        'word': 'goodbye',
        'vi': 'tạm biệt',
        'phonetic': '/ˌɡʊdˈbaɪ/',
        'pos': 'exclamation',
        'meaning': 'used when leaving',
        'meaning_vi': 'dùng khi rời đi',
      },
    ],

    'Time': [
      {
        'word': 'today',
        'vi': 'hôm nay',
        'phonetic': '/təˈdeɪ/',
        'pos': 'noun',
        'meaning': 'the present day',
        'meaning_vi': 'ngày hiện tại',
      },
      {
        'word': 'tomorrow',
        'vi': 'ngày mai',
        'phonetic': '/təˈmɒrəʊ/',
        'pos': 'noun',
        'meaning': 'the day after today',
        'meaning_vi': 'ngày sau hôm nay',
      },
    ],

    'Places': [
      {
        'word': 'school',
        'vi': 'trường học',
        'phonetic': '/skuːl/',
        'pos': 'noun',
        'meaning': 'a place to study',
        'meaning_vi': 'nơi để học tập',
      },
      {
        'word': 'home',
        'vi': 'nhà',
        'phonetic': '/həʊm/',
        'pos': 'noun',
        'meaning': 'the place where you live',
        'meaning_vi': 'nơi bạn sinh sống',
      },
    ],

    'Family': [
      {
        'word': 'father',
        'vi': 'cha / bố',
        'phonetic': '/ˈfɑːðə/',
        'pos': 'noun',
        'meaning': 'male parent',
        'meaning_vi': 'cha (bố)',
      },
      {
        'word': 'mother',
        'vi': 'mẹ',
        'phonetic': '/ˈmʌðə/',
        'pos': 'noun',
        'meaning': 'female parent',
        'meaning_vi': 'mẹ',
      },
    ],

    'School': [
      {
        'word': 'student',
        'vi': 'học sinh / sinh viên',
        'phonetic': '/ˈstjuːdənt/',
        'pos': 'noun',
        'meaning': 'a person who studies',
        'meaning_vi': 'người học tập',
      },
      {
        'word': 'teacher',
        'vi': 'giáo viên',
        'phonetic': '/ˈtiːtʃə/',
        'pos': 'noun',
        'meaning': 'a person who teaches',
        'meaning_vi': 'người giảng dạy',
      },
    ],

    'Sports': [
      {
        'word': 'football',
        'vi': 'bóng đá',
        'phonetic': '/ˈfʊtbɔːl/',
        'pos': 'noun',
        'meaning': 'a popular team sport',
        'meaning_vi': 'một môn thể thao đồng đội phổ biến',
      },
      {
        'word': 'swimming',
        'vi': 'bơi lội',
        'phonetic': '/ˈswɪmɪŋ/',
        'pos': 'noun',
        'meaning': 'moving in water',
        'meaning_vi': 'di chuyển trong nước',
      },
    ],

    'Food': [
      {
        'word': 'breakfast',
        'vi': 'bữa sáng',
        'phonetic': '/ˈbrekfəst/',
        'pos': 'noun',
        'meaning': 'the first meal of the day',
        'meaning_vi': 'bữa ăn đầu tiên trong ngày',
      },
      {
        'word': 'delicious',
        'vi': 'ngon',
        'phonetic': '/dɪˈlɪʃəs/',
        'pos': 'adjective',
        'meaning': 'tastes very good',
        'meaning_vi': 'có hương vị rất ngon',
      },
    ],

    'Shopping': [
      {
        'word': 'price',
        'vi': 'giá cả',
        'phonetic': '/praɪs/',
        'pos': 'noun',
        'meaning': 'the cost of something',
        'meaning_vi': 'chi phí của một thứ gì đó',
      },
      {
        'word': 'discount',
        'vi': 'giảm giá',
        'phonetic': '/ˈdɪskaʊnt/',
        'pos': 'noun',
        'meaning': 'a reduction in price',
        'meaning_vi': 'sự giảm giá',
      },
    ],

    'Transport': [
      {
        'word': 'bus',
        'vi': 'xe buýt',
        'phonetic': '/bʌs/',
        'pos': 'noun',
        'meaning': 'a public vehicle',
        'meaning_vi': 'phương tiện giao thông công cộng',
      },
      {
        'word': 'train',
        'vi': 'tàu hỏa',
        'phonetic': '/treɪn/',
        'pos': 'noun',
        'meaning': 'a railway vehicle',
        'meaning_vi': 'phương tiện giao thông đường sắt',
      },
    ],

    'Weather': [
      {
        'word': 'rain',
        'vi': 'mưa',
        'phonetic': '/reɪn/',
        'pos': 'noun',
        'meaning': 'water falling from the sky',
        'meaning_vi': 'nước rơi từ bầu trời',
      },
      {
        'word': 'sunny',
        'vi': 'nắng',
        'phonetic': '/ˈsʌni/',
        'pos': 'adjective',
        'meaning': 'full of sunshine',
        'meaning_vi': 'đầy ánh nắng',
      },
    ],

    // ===== HSK 5 =====
    'Travel': [
      {
        'word': 'airport',
        'vi': 'sân bay',
        'phonetic': '/ˈeəpɔːt/',
        'pos': 'noun',
        'meaning': 'a place where airplanes land and take off',
        'meaning_vi': 'nơi máy bay cất cánh và hạ cánh',
      },
      {
        'word': 'passport',
        'vi': 'hộ chiếu',
        'phonetic': '/ˈpɑːspɔːt/',
        'pos': 'noun',
        'meaning': 'an official document for international travel',
        'meaning_vi': 'giấy tờ chính thức dùng cho việc đi lại quốc tế',
      },
      {
        'word': 'luggage',
        'vi': 'hành lý',
        'phonetic': '/ˈlʌɡɪdʒ/',
        'pos': 'noun',
        'meaning': 'bags and suitcases for traveling',
        'meaning_vi': 'túi xách và vali dùng khi đi du lịch',
      },
    ],

    'Work': [
      {
        'word': 'employee',
        'vi': 'nhân viên',
        'phonetic': '/ˌemplɔɪˈiː/',
        'pos': 'noun',
        'meaning': 'a person who works for a company',
        'meaning_vi': 'người làm việc cho một công ty',
      },
      {
        'word': 'deadline',
        'vi': 'hạn chót',
        'phonetic': '/ˈdedlaɪn/',
        'pos': 'noun',
        'meaning': 'the latest time something must be done',
        'meaning_vi': 'thời hạn cuối cùng phải hoàn thành',
      },
    ],

    'Media': [
      {
        'word': 'broadcast',
        'vi': 'phát sóng',
        'phonetic': '/ˈbrɔːdkɑːst/',
        'pos': 'verb',
        'meaning': 'to send out programs by radio or TV',
        'meaning_vi': 'phát chương trình qua radio hoặc truyền hình',
      },
      {
        'word': 'journalist',
        'vi': 'nhà báo',
        'phonetic': '/ˈdʒɜːnəlɪst/',
        'pos': 'noun',
        'meaning': 'a person who reports news',
        'meaning_vi': 'người đưa tin, làm báo',
      },
    ],

    'Lifestyle': [
      {
        'word': 'routine',
        'vi': 'thói quen hàng ngày',
        'phonetic': '/ruːˈtiːn/',
        'pos': 'noun',
        'meaning': 'daily habits or activities',
        'meaning_vi': 'những thói quen hoặc hoạt động hằng ngày',
      },
      {
        'word': 'balance',
        'vi': 'sự cân bằng',
        'phonetic': '/ˈbæləns/',
        'pos': 'noun',
        'meaning': 'a state of equal or proper proportions',
        'meaning_vi': 'trạng thái cân đối hoặc hài hòa',
      },
    ],

    // ===== HSK 6 =====
    'Technology': [
      {
        'word': 'software',
        'vi': 'phần mềm',
        'phonetic': '/ˈsɒftweə/',
        'pos': 'noun',
        'meaning': 'computer programs',
        'meaning_vi': 'các chương trình máy tính',
      },
      {
        'word': 'database',
        'vi': 'cơ sở dữ liệu',
        'phonetic': '/ˈdeɪtəbeɪs/',
        'pos': 'noun',
        'meaning': 'an organized collection of data',
        'meaning_vi': 'tập hợp dữ liệu được tổ chức',
      },
      {
        'word': 'algorithm',
        'vi': 'thuật toán',
        'phonetic': '/ˈælɡərɪðəm/',
        'pos': 'noun',
        'meaning': 'a set of rules to solve a problem',
        'meaning_vi': 'tập hợp các quy tắc để giải quyết vấn đề',
      },
    ],

    'Business': [
      {
        'word': 'investment',
        'vi': 'sự đầu tư',
        'phonetic': '/ɪnˈvestmənt/',
        'pos': 'noun',
        'meaning': 'the act of putting money into something',
        'meaning_vi': 'hành động bỏ tiền vào một lĩnh vực nào đó',
      },
      {
        'word': 'profit',
        'vi': 'lợi nhuận',
        'phonetic': '/ˈprɒfɪt/',
        'pos': 'noun',
        'meaning': 'money earned after costs are paid',
        'meaning_vi': 'tiền kiếm được sau khi trừ chi phí',
      },
    ],

    'Education': [
      {
        'word': 'assignment',
        'vi': 'bài tập',
        'phonetic': '/əˈsaɪnmənt/',
        'pos': 'noun',
        'meaning': 'a task given to students',
        'meaning_vi': 'nhiệm vụ được giao cho học sinh',
      },
      {
        'word': 'curriculum',
        'vi': 'chương trình học',
        'phonetic': '/kəˈrɪkjələm/',
        'pos': 'noun',
        'meaning': 'subjects taught in a course',
        'meaning_vi': 'các môn học được giảng dạy trong khóa học',
      },
    ],

    'Health': [
      {
        'word': 'nutrition',
        'vi': 'dinh dưỡng',
        'phonetic': '/njuːˈtrɪʃn/',
        'pos': 'noun',
        'meaning': 'the process of eating healthy food',
        'meaning_vi': 'quá trình ăn uống lành mạnh',
      },
      {
        'word': 'exercise',
        'vi': 'tập thể dục',
        'phonetic': '/ˈeksəsaɪz/',
        'pos': 'noun',
        'meaning': 'physical activity to stay healthy',
        'meaning_vi': 'hoạt động thể chất để giữ sức khỏe',
      },
    ],

    'Environment': [
      {
        'word': 'pollution',
        'vi': 'ô nhiễm',
        'phonetic': '/pəˈluːʃn/',
        'pos': 'noun',
        'meaning': 'damage to air, water, or land',
        'meaning_vi': 'sự gây hại cho không khí, nước hoặc đất',
      },
      {
        'word': 'recycle',
        'vi': 'tái chế',
        'phonetic': '/ˌriːˈsaɪkl/',
        'pos': 'verb',
        'meaning': 'to reuse materials',
        'meaning_vi': 'tái sử dụng vật liệu',
      },
    ],

    // ===== HSK 7–9 =====
    'Politics': [
      {
        'word': 'democracy',
        'vi': 'nền dân chủ',
        'phonetic': '/dɪˈmɒkrəsi/',
        'pos': 'noun',
        'meaning': 'government by the people',
        'meaning_vi': 'chính quyền do nhân dân làm chủ',
      },
      {
        'word': 'election',
        'vi': 'cuộc bầu cử',
        'phonetic': '/ɪˈlekʃn/',
        'pos': 'noun',
        'meaning': 'a process of choosing leaders',
        'meaning_vi': 'quá trình lựa chọn lãnh đạo',
      },
    ],

    'Economy': [
      {
        'word': 'inflation',
        'vi': 'lạm phát',
        'phonetic': '/ɪnˈfleɪʃn/',
        'pos': 'noun',
        'meaning': 'general increase in prices',
        'meaning_vi': 'sự gia tăng chung của giá cả',
      },
      {
        'word': 'recession',
        'vi': 'suy thoái kinh tế',
        'phonetic': '/rɪˈseʃn/',
        'pos': 'noun',
        'meaning': 'a period of economic decline',
        'meaning_vi': 'giai đoạn suy giảm kinh tế',
      },
    ],

    'Law': [
      {
        'word': 'legislation',
        'vi': 'luật pháp',
        'phonetic': '/ˌledʒɪsˈleɪʃn/',
        'pos': 'noun',
        'meaning': 'laws passed by a government',
        'meaning_vi': 'các đạo luật được chính phủ ban hành',
      },
      {
        'word': 'justice',
        'vi': 'công lý',
        'phonetic': '/ˈdʒʌstɪs/',
        'pos': 'noun',
        'meaning': 'fair treatment by law',
        'meaning_vi': 'sự đối xử công bằng theo pháp luật',
      },
    ],

    'Philosophy': [
      {
        'word': 'ethics',
        'vi': 'đạo đức',
        'phonetic': '/ˈeθɪks/',
        'pos': 'noun',
        'meaning': 'moral principles',
        'meaning_vi': 'các nguyên tắc đạo đức',
      },
      {
        'word': 'existence',
        'vi': 'sự tồn tại',
        'phonetic': '/ɪɡˈzɪstəns/',
        'pos': 'noun',
        'meaning': 'the state of being',
        'meaning_vi': 'trạng thái tồn tại',
      },
    ],

    'Research': [
      {
        'word': 'hypothesis',
        'vi': 'giả thuyết',
        'phonetic': '/haɪˈpɒθəsɪs/',
        'pos': 'noun',
        'meaning': 'a proposed explanation',
        'meaning_vi': 'một lời giải thích được đưa ra',
      },
      {
        'word': 'analysis',
        'vi': 'phân tích',
        'phonetic': '/əˈnæləsɪs/',
        'pos': 'noun',
        'meaning': 'detailed examination of data',
        'meaning_vi': 'sự xem xét chi tiết dữ liệu',
      },
    ],

    'Culture': [
      {
        'word': 'tradition',
        'vi': 'truyền thống',
        'phonetic': '/trəˈdɪʃn/',
        'pos': 'noun',
        'meaning': 'customs passed down generations',
        'meaning_vi': 'phong tục được truyền qua nhiều thế hệ',
      },
      {
        'word': 'heritage',
        'vi': 'di sản',
        'phonetic': '/ˈherɪtɪdʒ/',
        'pos': 'noun',
        'meaning': 'cultural inheritance',
        'meaning_vi': 'di sản văn hóa',
      },
    ],
  };

  final hskData = [
    {
      'level': 'IELTS7-9',
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
      'level': 'IELTS6',
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
      'level': 'IELTS5',
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
      'level': 'IELTS4',
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
      'level': 'IELTS3',
      'total': 150,
      'lessons': 14,
      'topics': [
        {'title': 'Family', 'icon': Icons.family_restroom},
        {'title': 'School', 'icon': Icons.menu_book},
        {'title': 'Sports', 'icon': Icons.sports_soccer},
      ]
    },
    {
      'level': 'IELTS2',
      'total': 150,
      'lessons': 14,
      'topics': [
        {'title': 'Greetings', 'icon': Icons.waving_hand},
        {'title': 'Time', 'icon': Icons.access_time},
        {'title': 'Places', 'icon': Icons.place},
      ]
    },
    {
      'level': 'IELTS1',
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
      body: TabBarView(
        controller: _tabController,
        children: List.generate(hskData.length, (index) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _buildTopCardByIndex(index),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 16),
                ),
                _buildTopicGridSliver(index),
              ],
            ),
          );
        }),
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
        'Từ vựng IELTS',
        style: TextStyle(color: Colors.white, fontSize: 17),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, size: 18),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            showSearch(
              context: context,
              delegate: VocabularySearchDelegate(topicVocabularyData),
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
  Widget _buildTopCardByIndex(int index) {
    final current = hskData[index];

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

  SliverGrid _buildTopicGridSliver(int index) {
    final topics = hskData[index]['topics'] as List<Map>;

    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
            (context, i) {
          final topic = topics[i];
          final topicTitle = topic['title'];

          return InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              final vocabByTopic =
                  topicVocabularyData[topicTitle] ?? [];

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
                    topicTitle,
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
        childCount: topics.length,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.3,
      ),
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
class VocabularySearchDelegate extends SearchDelegate {
  final Map<String, List<Map<String, dynamic>>> topicVocabularyData;

  VocabularySearchDelegate(this.topicVocabularyData);

  @override
  String get searchFieldLabel => 'Tìm từ, dịch nghĩa, ví dụ';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        )
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
    return _buildResultList(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.trim().isEmpty) {
      return const SizedBox();
    }
    return _buildResultList(context);
  }

  Widget _buildResultList(BuildContext context) {
    final results = <Map<String, dynamic>>[];

    topicVocabularyData.forEach((topic, list) {
      for (var v in list) {
        if (v['word']
            .toString()
            .toLowerCase()
            .contains(query.toLowerCase())) {
          results.add({
            ...v,
            '__topic': topic,
            '__topicList': list,
          });
        }
      }
    });

    if (results.isEmpty) {
      return const Center(
        child: Text('Không tìm thấy từ',
            style: TextStyle(color: Colors.white54)),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];

        return ListTile(
          title: Text(
            item['word'],
            style: const TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            '${item['phonetic']} • ${item['meaning']}',
            style: const TextStyle(color: Colors.white54),
          ),
          onTap: () {
            final vocabList =
            item['__topicList'] as List<Map<String, dynamic>>;

            final startIndex = vocabList.indexWhere(
                  (e) => e['word'] == item['word'],
            );

            close(context, null);

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VocabularyDetailScreen(
                  vocabularies: vocabList,
                  initialIndex: startIndex,
                ),
              ),
            );
          },
        );
      },
    );
  }
}