import 'package:flutter/material.dart';
import '../../../../features/study_sections/writing/models/topic_model.dart';
import '../../../../features/study_sections/writing/services/writing_api_service.dart';
import '../../../../features/profile/screens/upgrade_pro_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../services/writing_provider.dart';
import 'writing_screen.dart';

class TopicListScreen extends StatefulWidget {
  const TopicListScreen({Key? key}) : super(key: key);

  @override
  State<TopicListScreen> createState() => _TopicListScreenState();
}

class _TopicListScreenState extends State<TopicListScreen> {
  bool _isLoading = true;
  bool _isPro = false;

  @override
  void initState() {
    super.initState();
    _checkProStatus();
  }

  Future<void> _checkProStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isPro = prefs.getBool('is_pro') ?? false;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final writingProvider = context.watch<WritingProvider>();
    final topics = writingProvider.items;
    final isLoading = writingProvider.state == LoadState.loading || _isLoading;

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
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
          : topics.isEmpty
              ? const Center(
                  child: Text(
                    'Không có chủ đề nào.',
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: topics.length,
                  itemBuilder: (context, index) {
                    final topicPrompt = topics[index];
                    final title = topicPrompt.title;
                    final description = topicPrompt.promptText;
                    final topicId = int.tryParse(topicPrompt.id) ?? 0;
                    const isProOnly = false; 

                    return Card(
                      color: const Color(0xFF1E2330),
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          if (isProOnly && !_isPro) {
                            _showUpgradePrompt();
                            return;
                          }
                          
                          // Convert back to Topic for WritingScreen
                          final topic = Topic(
                            id: topicId,
                            title: title,
                            prompt: description,
                          );

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
                                    title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    description,
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
                            if (isProOnly && !_isPro)
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
