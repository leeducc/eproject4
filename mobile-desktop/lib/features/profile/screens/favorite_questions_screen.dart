import 'package:flutter/material.dart';
import '../../study_sections/services/favorite_question_service.dart';
import '../../../core_quiz/models/quiz_question.dart';
import '../../../core/models/quiz_bank_models.dart';
import '../../../core_quiz/widgets/dynamic_question_builder.dart';

class FavoriteQuestionsScreen extends StatefulWidget {
  const FavoriteQuestionsScreen({Key? key}) : super(key: key);

  @override
  State<FavoriteQuestionsScreen> createState() => _FavoriteQuestionsScreenState();
}

class _FavoriteQuestionsScreenState extends State<FavoriteQuestionsScreen> {
  final FavoriteQuestionService _service = FavoriteQuestionService();
  bool _isLoading = true;
  List<Question> _favorites = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    try {
      final data = await _service.fetchFavorites();
      if (mounted) {
        setState(() {
          _favorites = data.map((json) => Question.fromJson(json)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading favorites: $e')),
        );
      }
    }
  }

  Future<void> _toggleFavorite(Question q) async {
    try {
      await _service.toggleFavorite(q.id);
      if (mounted) {
        setState(() {
          _favorites.removeWhere((item) => item.id == q.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa khỏi danh sách yêu thích')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  void _showQuestionDetail(Question q) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      q.skill.name.toUpperCase(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              DynamicQuestionBuilder(
                question: QuizQuestion.from(q),
                isAnswered: false,
                onAnswer: (_) {},
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Questions', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favorites.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _favorites.length,
                  itemBuilder: (context, index) {
                    final q = _favorites[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                      color: theme.cardColor,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          q.instruction.isEmpty ? 'Question #${q.id}' : q.instruction,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            children: [
                              Icon(Icons.layers_outlined, size: 14, color: theme.colorScheme.primary),
                              const SizedBox(width: 4),
                              Text(q.difficultyBand.replaceAll('BAND_', 'Band '), 
                                style: TextStyle(fontSize: 12, color: theme.colorScheme.primary)),
                              const SizedBox(width: 12),
                              Icon(Icons.category_outlined, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(q.type.name.replaceAll('QuestionType.', ''), 
                                style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.favorite, color: Colors.redAccent),
                          onPressed: () => _toggleFavorite(q),
                        ),
                        onTap: () => _showQuestionDetail(q),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: Colors.grey.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text(
            'Chưa có câu hỏi yêu thích',
            style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Hãy lưu những câu hỏi bạn muốn ôn tập lại nhé!',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
