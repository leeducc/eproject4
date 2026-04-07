import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/wrong_answer_provider.dart';
import '../../../../core/models/wrong_answer.dart';
import 'wrong_answer_exam_screen.dart';

class WrongAnswersScreen extends StatefulWidget {
  const WrongAnswersScreen({Key? key}) : super(key: key);

  @override
  State<WrongAnswersScreen> createState() => _WrongAnswersScreenState();
}

class _WrongAnswersScreenState extends State<WrongAnswersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final provider = context.watch<WrongAnswerProvider>();
    
    debugPrint('[WrongAnswersScreen] build – ${provider.wrongAnswers.length} total items');

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Bộ sưu tập câu sai',
          style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: colorScheme.onSurface, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (provider.wrongAnswers.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_sweep_outlined, color: colorScheme.error),
              tooltip: 'Xóa tất cả',
              onPressed: () => _showClearDialog(context, provider),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurface.withOpacity(0.5),
          indicatorColor: colorScheme.primary,
          tabs: const [
            Tab(text: 'Listening', icon: Icon(Icons.headphones)),
            Tab(text: 'Speaking', icon: Icon(Icons.mic)),
          ],
        ),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildSkillList(context, 'LISTENING', provider),
                      _buildSkillList(context, 'SPEAKING', provider),
                    ],
                  ),
                ),
                _buildPracticeFooter(context, provider),
              ],
            ),
    );
  }

  Widget _buildPracticeFooter(BuildContext context, WrongAnswerProvider provider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final count = provider.wrongAnswers.length;
    final isEnabled = count > 10;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isEnabled)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Cần ít nhất 11 câu để bắt đầu luyện tập (Hiện có: $count)',
                  style: TextStyle(color: colorScheme.error.withOpacity(0.7), fontSize: 12),
                ),
              ),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: isEnabled 
                  ? () {
                      debugPrint('[WrongAnswersScreen] Starting practice exam with $count questions');
                      Navigator.push(
                        context, 
                        MaterialPageRoute(
                          builder: (_) => WrongAnswerExamScreen(
                            items: provider.wrongAnswers.where((item) => item.originalJson != null).toList(),
                          )
                        )
                      );
                    } 
                  : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: colorScheme.onSurface.withOpacity(0.12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text('Bắt đầu làm bài (Luyện tập)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillList(BuildContext context, String skill, WrongAnswerProvider provider) {
    final list = provider.getBySkill(skill);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              skill == 'LISTENING' ? Icons.headphones_outlined : Icons.mic_none_outlined,
              size: 80,
              color: colorScheme.onSurface.withOpacity(0.05),
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có câu sai nào cho ${skill == 'LISTENING' ? 'Nghe' : 'Nói'}',
              style: TextStyle(color: colorScheme.onSurface.withOpacity(0.4), fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        return _buildWrongAnswerCard(context, item, provider);
      },
    );
  }

  Widget _buildWrongAnswerCard(BuildContext context, WrongAnswer item, WrongAnswerProvider provider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(item.timestamp);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      color: colorScheme.surface,
      child: ExpansionTile(
        key: PageStorageKey(item.questionId),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            item.skill == 'LISTENING' ? Icons.headphones : Icons.mic,
            color: colorScheme.primary,
            size: 20,
          ),
        ),
        title: Text(
          item.questionTitle,
          style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 15),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          'Ngày học: $dateStr',
          style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontSize: 12),
        ),
        childrenPadding: const EdgeInsets.all(16),
        children: [
          _buildDetailRow('Hướng dẫn', item.instruction ?? 'N/A', colorScheme),
          if (item.explanation != null && item.explanation!.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            _buildDetailRow('Giải thích', item.explanation!, colorScheme),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => provider.removeWrongAnswer(item.questionId),
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: const Text('Đã hiểu'),
                style: TextButton.styleFrom(foregroundColor: Colors.green),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, ColorScheme colorScheme, {bool isError = false, bool isSuccess = false}) {
    Color textColor = colorScheme.onSurface;
    if (isError) textColor = Colors.redAccent;
    if (isSuccess) textColor = Colors.green;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: colorScheme.onSurface.withOpacity(0.4), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(color: textColor, fontSize: 14, fontWeight: isError || isSuccess ? FontWeight.bold : FontWeight.normal),
        ),
      ],
    );
  }

  void _showClearDialog(BuildContext context, WrongAnswerProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa tất cả?'),
        content: const Text('Bạn có chắc chắn muốn xóa toàn bộ danh sách câu sai này không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          TextButton(
            onPressed: () {
              provider.clearAll();
              Navigator.pop(context);
            },
            child: const Text('Xóa sạch', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}