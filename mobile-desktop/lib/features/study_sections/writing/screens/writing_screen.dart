import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import '../models/topic_model.dart';
import '../models/essay_submission_response.dart';
import '../models/writing_correction.dart';
import '../services/writing_api_service.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/ielts_level_provider.dart';
import '../../../home/screens/choose_level_screen.dart';
import '../../../../core/theme/app_theme.dart';


class WritingScreen extends StatefulWidget {
  final Topic topic;

  const WritingScreen({Key? key, required this.topic}) : super(key: key);

  @override
  State<WritingScreen> createState() => _WritingScreenState();
}

class _WritingScreenState extends State<WritingScreen> with SingleTickerProviderStateMixin {
  final WritingApiService _apiService = WritingApiService();
  final TextEditingController _contentController = TextEditingController();
  late TabController _tabController;

  String _gradingType = 'AI';
  bool _isSubmitting = false;
  EssaySubmissionResponse? _submissionResponse;
  
  List<EssaySubmissionResponse> _history = [];
  bool _isLoadingHistory = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() {
      _isLoadingHistory = true;
    });
    try {
      final allSubmissions = await _apiService.fetchMySubmissions();
      if (!mounted) return;
      setState(() {
        _history = allSubmissions.where((s) => s.topic.id == widget.topic.id).toList();
        _isLoadingHistory = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingHistory = false;
      });
      debugPrint('Error fetching history: $e');
    }
  }

  Future<void> _submitEssay() async {
    if (_contentController.text.trim().isEmpty) {
      _showErrorSnackBar('Vui lòng viết bài luận của bạn.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _submissionResponse = null; 
    });

    try {
      await _apiService.submitEssay(
        widget.topic.id,
        _contentController.text.trim(),
        _gradingType,
      );

      if (!mounted) return;
      _contentController.clear();
      await _fetchHistory();

      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });

      if (_gradingType == 'HUMAN') {
        _showSuccessDialog('Bài luận của bạn đã được gửi. Giáo viên sẽ chấm bài và kết quả sẽ được gửi thông báo tới email của bạn sớm nhất.');
      } else {
        _showSuccessDialog('Bài luận của bạn đã được gửi và đang được AI chấm điểm. Vui lòng xem kết quả ở lịch sử.');
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      _showErrorSnackBar('Lỗi khi gửi bài: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: context.customColors.errorColor),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: context.colorScheme.surface,
          title: Text('Thông báo', style: TextStyle(color: context.colorScheme.onSurface)),
          content: Text(
            message,
            style: TextStyle(color: context.colorScheme.onSurface.withValues(alpha: 0.7)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Đóng', style: TextStyle(color: context.colorScheme.primary)),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _contentController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final level = context.watch<IeltsLevelProvider>().selectedLevel;

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Luyện Viết IELTS · ${level.label}',
          style: TextStyle(color: context.colorScheme.onSurface, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: context.colorScheme.onSurface, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          _LevelBadge(level: level),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildPromptHeader(),
            Divider(color: context.colorScheme.onSurface.withValues(alpha: 0.1), height: 32),
            
            if (_submissionResponse != null) 
              _buildDetailView()
            else 
              _buildWritingArea(),
              
            Divider(color: context.colorScheme.onSurface.withValues(alpha: 0.1), height: 48),
            _buildHistorySection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPromptHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.topic.title,
          style: TextStyle(color: context.colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          widget.topic.prompt,
          style: TextStyle(color: context.colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 15, height: 1.5),
        ),
        if (widget.topic.imageUrl != null && widget.topic.imageUrl!.isNotEmpty) ...[
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(widget.topic.imageUrl!),
          ),
        ],
      ],
    );
  }

  Widget _buildWritingArea() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGraderToggle(),
        const SizedBox(height: 16),
        Text(
          'Bài viết của bạn',
          style: TextStyle(color: context.colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          constraints: const BoxConstraints(minHeight: 200),
          decoration: BoxDecoration(
            color: context.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.colorScheme.onSurface.withValues(alpha: 0.1)),
          ),
          child: _buildEssayInput(),
        ),
        _buildWordCount(),
        const SizedBox(height: 24),
        _buildSubmitButton(),
      ],
    );
  }

  Widget _buildHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lịch sử làm bài',
          style: TextStyle(color: context.colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (_isLoadingHistory)
          Center(child: CircularProgressIndicator(color: context.colorScheme.primary))
        else if (_history.isEmpty)
          Text('Bạn chưa có bài nộp nào cho chủ đề này.', style: TextStyle(color: context.colorScheme.onSurface.withValues(alpha: 0.5)))
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _history.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = _history[index];
              final isAI = item.gradingType == 'AI';
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _submissionResponse = item;
                  });
                },
                child: Card(
                  color: context.colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: _submissionResponse?.id == item.id ? context.colorScheme.primary : Colors.transparent),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isAI ? context.customColors.aisurface : context.customColors.humansurface,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isAI ? 'AI' : 'Giáo viên',
                            style: TextStyle(color: isAI ? context.customColors.aiColor : context.customColors.humanColor, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _formatDate(item.createdAt),
                                style: TextStyle(color: context.colorScheme.onSurface, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.status == 'GRADED' ? 'Đã chấm' : (item.status == 'IN_PROGRESS' ? 'Đang chấm' : 'Chờ chấm'),
                                style: TextStyle(color: item.status == 'GRADED' ? context.customColors.successColor : context.customColors.warningColor, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        if (item.score != null)
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: context.colorScheme.onSurface.withValues(alpha: 0.05),
                            ),
                            child: Text(
                              '${item.score}',
                              style: TextStyle(color: context.colorScheme.onSurface, fontWeight: FontWeight.bold),
                            ),
                          )
                        else
                          Icon(Icons.chevron_right, color: context.colorScheme.onSurface.withValues(alpha: 0.3)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null) return "Gần đây";
    try {
      final date = DateTime.parse(isoDate).toLocal();
      return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return isoDate;
    }
  }

  Widget _buildDetailView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Chi tiết bài làm',
              style: TextStyle(color: context.colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _submissionResponse = null;
                });
              },
              icon: const Icon(Icons.close, size: 16),
              label: const Text('Đóng / Viết tiếp'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          constraints: const BoxConstraints(minHeight: 200),
          decoration: BoxDecoration(
            color: context.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.colorScheme.onSurface.withValues(alpha: 0.1)),
          ),
          child: _buildRichTextEssay(_submissionResponse!.content, _submissionResponse!.corrections),
        ),
        const SizedBox(height: 24),
        _buildFeedbackTabs(),
      ],
    );
  }

  Widget _buildGraderToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: SegmentedButton<String>(
        segments: const <ButtonSegment<String>>[
          ButtonSegment<String>(
            value: 'HUMAN',
            label: Text('Giáo viên'),
            icon: Icon(Icons.person_outline),
          ),
          ButtonSegment<String>(
            value: 'AI',
            label: Text('AI Grader'),
            icon: Icon(Icons.auto_awesome),
          ),
        ],
        selected: <String>{_gradingType},
        onSelectionChanged: (Set<String> newSelection) {
          setState(() {
            _gradingType = newSelection.first;
          });
        },
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: _gradingType == 'AI' ? context.customColors.aisurface : context.customColors.humansurface,
          selectedForegroundColor: _gradingType == 'AI' ? context.customColors.aiColor : context.customColors.humanColor,
          side: BorderSide(color: _gradingType == 'AI' ? context.customColors.aiColor!.withValues(alpha: 0.5) : context.customColors.humanColor!.withValues(alpha: 0.5)),
        ),
      ),
    );
  }

  Widget _buildEssayInput() {
    return TextField(
      controller: _contentController,
      style: TextStyle(color: context.colorScheme.onSurface, height: 1.5),
      maxLines: null,
      decoration: InputDecoration(
        hintText: 'Nhập bài luận của bạn vào đây...',
        hintStyle: TextStyle(color: context.colorScheme.onSurface.withValues(alpha: 0.3)),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildRichTextEssay(String content, List<WritingCorrection> corrections) {
    List<TextSpan> spans = [];
    String remaining = content;

    if (corrections.isEmpty) {
      spans.add(TextSpan(text: content, style: TextStyle(color: context.colorScheme.onSurface.withValues(alpha: 0.8))));
    } else {
      for (var correction in corrections) {
        int index = remaining.indexOf(correction.original);
        if (index != -1) {
          spans.add(TextSpan(text: remaining.substring(0, index)));
          
          spans.add(TextSpan(
            text: correction.original,
            style: TextStyle(
              color: context.customColors.errorColor,
              decoration: TextDecoration.lineThrough,
              backgroundColor: context.customColors.errorsurface,
            ),
            recognizer: TapGestureRecognizer()..onTap = () => _showCorrectionDetail(correction),
          ));

          spans.add(TextSpan(
            text: ' ${correction.corrected} ',
            style: TextStyle(
              color: context.customColors.successColor,
              fontWeight: FontWeight.bold,
              backgroundColor: context.customColors.successsurface,
            ),
            recognizer: TapGestureRecognizer()..onTap = () => _showCorrectionDetail(correction),
          ));
          
          remaining = remaining.substring(index + correction.original.length);
        }
      }
      spans.add(TextSpan(text: remaining));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: RichText(
        text: TextSpan(
          style: TextStyle(color: context.colorScheme.onSurface.withValues(alpha: 0.8), fontSize: 16, height: 1.6),
          children: spans,
        ),
      ),
    );
  }

  void _showCorrectionDetail(WritingCorrection correction) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: context.colorScheme.surface,
          title: Text('Chi tiết lỗi', style: TextStyle(color: context.colorScheme.onSurface)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Original: ${correction.original}', style: TextStyle(color: context.customColors.errorColor, decoration: TextDecoration.lineThrough)),
              const SizedBox(height: 8),
              Text('Corrected: ${correction.corrected}', style: TextStyle(color: context.customColors.successColor, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text('Explanation:', style: TextStyle(color: context.colorScheme.onSurface.withValues(alpha: 0.7), fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(correction.explanation, style: TextStyle(color: context.colorScheme.onSurface.withValues(alpha: 0.7))),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Đóng', style: TextStyle(color: context.colorScheme.primary)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWordCount() {
    int count = _contentController.text.trim().isEmpty 
        ? 0 
        : _contentController.text.trim().split(RegExp(r'\s+')).length;
    
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 4),
      child: Chip(
        visualDensity: VisualDensity.compact,
        backgroundColor: context.colorScheme.onSurface.withValues(alpha: 0.05),
        label: Text(
          '$count từ',
          style: TextStyle(color: context.colorScheme.onSurface.withOpacity(0.6), fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitEssay,
        style: ElevatedButton.styleFrom(
          backgroundColor: _gradingType == 'AI' ? context.customColors.aiColor : context.customColors.humanColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: _isSubmitting
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                  SizedBox(width: 12),
                  Text('Đang xử lý...'),
                ],
              )
            : Text(
                _gradingType == 'AI' ? 'Chấm điểm bằng AI ✨' : 'Nộp bài cho giáo viên',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Widget _buildFeedbackTabs() {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: context.colorScheme.primary,
          unselectedLabelColor: context.colorScheme.onSurface.withValues(alpha: 0.3),
          indicatorColor: context.colorScheme.primary,
          dividerColor: context.colorScheme.onSurface.withValues(alpha: 0.1),
          tabs: const [
            Tab(text: 'Feedback'),
            Tab(text: 'Kết quả'),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 400,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildFeedbackTab(),
              _buildResultTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackTab() {
    if (_submissionResponse == null) return const SizedBox();
    
    final aiFeedback = _submissionResponse!.aiFeedback;
    final teacherFeedback = _submissionResponse!.teacherFeedback;

    if ((aiFeedback == null || aiFeedback.isEmpty) && 
        (teacherFeedback == null || teacherFeedback.isEmpty)) {
      return Center(
        child: Text(
          'Chưa có feedback cho bài làm này.',
          style: TextStyle(color: context.colorScheme.onSurface.withOpacity(0.3)),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(top: 8.0),
      children: [
        if (teacherFeedback != null && teacherFeedback.isNotEmpty) ...[
          Text(
            'Overall Feedback for Student',
            style: TextStyle(color: context.colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.colorScheme.onSurface.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              teacherFeedback,
              style: TextStyle(color: context.colorScheme.onSurface.withOpacity(0.7), height: 1.6),
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (aiFeedback != null && aiFeedback.isNotEmpty) ...[
          Text(
            'AI Feedback',
            style: TextStyle(color: context.colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.colorScheme.onSurface.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              aiFeedback,
              style: TextStyle(color: context.colorScheme.onSurface.withOpacity(0.7), height: 1.6),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildResultTab() {
    if (_submissionResponse == null) {
      return Center(
        child: Text(
          'Nộp bài để xem kết quả.',
          style: TextStyle(color: context.colorScheme.onSurface.withOpacity(0.3)),
        ),
      );
    }

    return ListView(
      children: [
        Center(
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: context.colorScheme.primary, width: 4),
            ),
            child: Center(
              child: Text(
                '${_submissionResponse!.score ?? "-"}',
                style: TextStyle(color: context.colorScheme.onSurface, fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        Center(child: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text('OVERALL BAND', style: TextStyle(color: context.colorScheme.onSurface.withValues(alpha: 0.3), letterSpacing: 1.2)),
        )),
        
        const SizedBox(height: 32),
        
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.8,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            _buildScoreItem('Task Achievement', _submissionResponse!.taskAchievement ?? 0, reason: _submissionResponse!.taskAchievementReason),
            _buildScoreItem('Cohesion & Coherence', _submissionResponse!.cohesionCoherence ?? 0, reason: _submissionResponse!.cohesionCoherenceReason),
            _buildScoreItem('Lexical Resource', _submissionResponse!.lexicalResource ?? 0, reason: _submissionResponse!.lexicalResourceReason),
            _buildScoreItem('Grammatical Range', _submissionResponse!.grammaticalRange ?? 0, reason: _submissionResponse!.grammaticalRangeReason),
          ],
        ),
      ],
    );
  }

  Widget _buildScoreItem(String label, double score, {String? reason}) {
    return GestureDetector(
      onTap: () {
        if (reason != null && reason.isNotEmpty) {
           showDialog(
             context: context,
             builder: (context) => AlertDialog(
                backgroundColor: context.colorScheme.surface,
                title: Text(label, style: TextStyle(color: context.colorScheme.onSurface)),
                content: SingleChildScrollView(child: Text(reason, style: TextStyle(color: context.colorScheme.onSurface.withValues(alpha: 0.7)))),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Đóng', style: TextStyle(color: context.colorScheme.primary)),
                  ),
                ],
             ),
           );
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        label,
                        style: TextStyle(color: context.colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (reason != null && reason.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Icon(Icons.info_outline, color: context.colorScheme.primary, size: 14),
                      ),
                  ],
                ),
              ),
              Text(
                '$score',
                style: TextStyle(color: context.colorScheme.primary, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: score / 9.0,
              backgroundColor: context.colorScheme.onSurface.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(context.colorScheme.primary),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelBadge extends StatelessWidget {
  final IeltsLevel level;
  const _LevelBadge({required this.level});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        debugPrint('[_LevelBadge] Navigating to ChooseLevelScreen');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChooseLevelScreen()),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: level.primaryColor.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: level.primaryColor, width: 1),
        ),
        child: Text(
          level.range,
          style: TextStyle(color: level.primaryColor, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}