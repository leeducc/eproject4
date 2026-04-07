import 'package:flutter/material.dart';
import '../../../../features/study_sections/writing/models/topic_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../services/writing_provider.dart';
import 'writing_screen.dart';
import '../../../../core/theme/app_theme.dart';

class TopicListScreen extends StatefulWidget {
  const TopicListScreen({Key? key}) : super(key: key);

  @override
  State<TopicListScreen> createState() => _TopicListScreenState();
}

class _TopicListScreenState extends State<TopicListScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkProStatus();
  }

  Future<void> _checkProStatus() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final writingProvider = context.watch<WritingProvider>();
    final topics = writingProvider.items;
    final isLoading = writingProvider.state == LoadState.loading || _isLoading;

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Chọn Chủ Đề Viết',
          style: TextStyle(color: context.colorScheme.onSurface, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: context.colorScheme.onSurface, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: context.colorScheme.primary))
          : topics.isEmpty
              ? Center(
                  child: Text(
                    'Không có chủ đề nào.',
                    style: TextStyle(color: context.colorScheme.onSurface.withValues(alpha: 0.54), fontSize: 16),
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
                      color: context.colorScheme.surface,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          
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
                                    style: TextStyle(
                                      color: context.colorScheme.onSurface,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: context.colorScheme.onSurface.withValues(alpha: 0.54),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isProOnly)
                              
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

}