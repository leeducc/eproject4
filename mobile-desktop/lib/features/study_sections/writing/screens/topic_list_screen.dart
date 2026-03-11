import 'package:flutter/material.dart';
import '../../../../features/study_sections/writing/models/topic_model.dart';
import '../../../../features/study_sections/writing/services/writing_api_service.dart';
import '../../../../features/profile/screens/upgrade_pro_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'writing_screen.dart';

class TopicListScreen extends StatefulWidget {
  const TopicListScreen({Key? key}) : super(key: key);

  @override
  State<TopicListScreen> createState() => _TopicListScreenState();
}

class _TopicListScreenState extends State<TopicListScreen> {
  final WritingApiService _apiService = WritingApiService();
  List<Topic> _topics = [];
  bool _isLoading = true;
  bool _isPro = false;

  @override
  void initState() {
    super.initState();
    _loadTopics();
  }

  Future<void> _loadTopics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isProUser = prefs.getBool('is_pro') ?? false;

      final topics = await _apiService.fetchTopics();
      setState(() {
        _topics = topics;
        _isPro = isProUser;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải danh sách chủ đề: $e'), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF161A23),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Chọn Chủ Đề Viết',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
          : _topics.isEmpty
              ? const Center(
                  child: Text(
                    'Không có chủ đề nào.',
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _topics.length,
                  itemBuilder: (context, index) {
                    final topic = _topics[index];
                    return Card(
                      color: const Color(0xFF1E2330),
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          if (topic.isProOnly && !_isPro) {
                            _showUpgradePrompt();
                            return;
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WritingScreen(topic: topic),
                            ),
                          );
                        },
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    topic.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    topic.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (topic.isProOnly && !_isPro)
                              const Positioned(
                                top: 16,
                                right: 16,
                                child: Icon(Icons.lock, color: Colors.orange, size: 24),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  void _showUpgradePrompt() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF222834),
        title: const Text('Nội dung PLUS', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Chủ đề này chỉ dành cho người dùng PLUS. Vui lòng nâng cấp để tiếp tục sử dụng.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UpgradeProScreen()),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Nâng cấp ngay', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
