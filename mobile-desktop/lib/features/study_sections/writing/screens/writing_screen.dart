import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../models/topic_model.dart';
import '../models/essay_submission_response.dart';
import '../models/writing_correction.dart';
import '../services/writing_api_service.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/ielts_level_provider.dart';
import '../../../home/screens/choose_level_screen.dart';


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
      setState(() {
        _history = allSubmissions.where((s) => s.topic.id == widget.topic.id).toList();
        _isLoadingHistory = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingHistory = false;
      });
      print('Error fetching history: $e');
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

      _contentController.clear();
      await _fetchHistory();

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
        SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E2330),
          title: const Text('Thông báo', style: TextStyle(color: Colors.white)),
          content: Text(
            message,
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng', style: TextStyle(color: Colors.blueAccent)),
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
      backgroundColor: const Color(0xFF161A23),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Luyện Viết IELTS · ${level.label}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
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
            const Divider(color: Colors.white12, height: 32),
            
            if (_submissionResponse != null) 
              _buildDetailView()
            else 
              _buildWritingArea(),
              
            const Divider(color: Colors.white12, height: 48),
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
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          widget.topic.prompt,
          style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.5),
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
        const Text(
          'Bài viết của bạn',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          constraints: const BoxConstraints(minHeight: 200),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2330),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white12),
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
        const Text(
          'Lịch sử làm bài',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (_isLoadingHistory)
          const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
        else if (_history.isEmpty)
          const Text('Bạn chưa có bài nộp nào cho chủ đề này.', style: TextStyle(color: Colors.white54))
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
                  color: const Color(0xFF1E2330),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: _submissionResponse?.id == item.id ? Colors.blueAccent : Colors.transparent),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isAI ? Colors.purpleAccent.withOpacity(0.2) : Colors.blueAccent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isAI ? 'AI' : 'Giáo viên',
                            style: TextStyle(color: isAI ? Colors.purpleAccent : Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _formatDate(item.createdAt),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.status == 'GRADED' ? 'Đã chấm' : (item.status == 'IN_PROGRESS' ? 'Đang chấm' : 'Chờ chấm'),
                                style: TextStyle(color: item.status == 'GRADED' ? Colors.greenAccent : Colors.orangeAccent, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        if (item.score != null)
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white10,
                            ),
                            child: Text(
                              '${item.score}',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          )
                        else
                          const Icon(Icons.chevron_right, color: Colors.white30),
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
            const Text(
              'Chi tiết bài làm',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
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
            color: const Color(0xFF1E2330),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white12),
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
          selectedBackgroundColor: _gradingType == 'AI' ? Colors.purpleAccent.withOpacity(0.2) : Colors.blueAccent.withOpacity(0.2),
          selectedForegroundColor: _gradingType == 'AI' ? Colors.purpleAccent : Colors.blueAccent,
          side: BorderSide(color: _gradingType == 'AI' ? Colors.purpleAccent.withOpacity(0.5) : Colors.blueAccent.withOpacity(0.5)),
        ),
      ),
    );
  }

  Widget _buildEssayInput() {
    return TextField(
      controller: _contentController,
      style: const TextStyle(color: Colors.white, height: 1.5),
      maxLines: null,
      decoration: const InputDecoration(
        hintText: 'Nhập bài luận của bạn vào đây...',
        hintStyle: TextStyle(color: Colors.white30),
        border: InputBorder.none,
        contentPadding: EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildRichTextEssay(String content, List<WritingCorrection> corrections) {
    List<TextSpan> spans = [];
    String remaining = content;

    if (corrections.isEmpty) {
      spans.add(TextSpan(text: content, style: const TextStyle(color: Colors.white70)));
    } else {
      for (var correction in corrections) {
        int index = remaining.indexOf(correction.original);
        if (index != -1) {
          spans.add(TextSpan(text: remaining.substring(0, index)));
          
          spans.add(TextSpan(
            text: correction.original,
            style: TextStyle(
              color: Colors.redAccent.withOpacity(0.8),
              decoration: TextDecoration.lineThrough,
              backgroundColor: Colors.redAccent.withOpacity(0.1),
            ),
            recognizer: TapGestureRecognizer()..onTap = () => _showCorrectionDetail(correction),
          ));

          spans.add(TextSpan(
            text: ' ${correction.corrected} ',
            style: const TextStyle(
              color: Colors.greenAccent,
              fontWeight: FontWeight.bold,
              backgroundColor: Color(0x2200FF00),
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
          style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.6),
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
          backgroundColor: const Color(0xFF1E2330),
          title: const Text('Chi tiết lỗi', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Original: ${correction.original}', style: const TextStyle(color: Colors.redAccent, decoration: TextDecoration.lineThrough)),
              const SizedBox(height: 8),
              Text('Corrected: ${correction.corrected}', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text('Explanation:', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(correction.explanation, style: const TextStyle(color: Colors.white70)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng', style: TextStyle(color: Colors.blueAccent)),
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
        backgroundColor: Colors.white10,
        label: Text(
          '$count từ',
          style: const TextStyle(color: Colors.white60, fontSize: 12),
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
          backgroundColor: _gradingType == 'AI' ? Colors.purpleAccent : Colors.blueAccent,
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
          labelColor: Colors.blueAccent,
          unselectedLabelColor: Colors.white30,
          indicatorColor: Colors.blueAccent,
          dividerColor: Colors.white10,
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
      return const Center(
        child: Text(
          'Chưa có feedback cho bài làm này.',
          style: TextStyle(color: Colors.white30),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(top: 8.0),
      children: [
        if (teacherFeedback != null && teacherFeedback.isNotEmpty) ...[
          const Text(
            'Overall Feedback for Student',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              teacherFeedback,
              style: const TextStyle(color: Colors.white70, height: 1.6),
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (aiFeedback != null && aiFeedback.isNotEmpty) ...[
          const Text(
            'AI Feedback',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              aiFeedback,
              style: const TextStyle(color: Colors.white70, height: 1.6),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildResultTab() {
    if (_submissionResponse == null) {
      return const Center(
        child: Text(
          'Nộp bài để xem kết quả.',
          style: TextStyle(color: Colors.white30),
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
              border: Border.all(color: Colors.blueAccent, width: 4),
            ),
            child: Center(
              child: Text(
                '${_submissionResponse!.score ?? "-"}',
                style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        const Center(child: Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Text('OVERALL BAND', style: TextStyle(color: Colors.white30, letterSpacing: 1.2)),
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
                backgroundColor: const Color(0xFF1E2330),
                title: Text(label, style: const TextStyle(color: Colors.white)),
                content: SingleChildScrollView(child: Text(reason, style: const TextStyle(color: Colors.white70))),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Đóng', style: TextStyle(color: Colors.blueAccent)),
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
                        style: const TextStyle(color: Colors.white60, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (reason != null && reason.isNotEmpty)
                      const Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: Icon(Icons.info_outline, color: Colors.blueAccent, size: 14),
                      ),
                  ],
                ),
              ),
              Text(
                '$score',
                style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: score / 9.0,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
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
          color: level.primaryColor.withOpacity(0.2),
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