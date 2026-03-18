import 'package:flutter/material.dart';
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
  bool _showHint = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  Future<void> _submitEssay() async {
    if (_contentController.text.trim().isEmpty) {
      _showErrorSnackBar('Vui lòng viết bài luận của bạn.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _submissionResponse = null; // reset if grading again
    });

    try {
      final response = await _apiService.submitEssay(
        widget.topic.id,
        _contentController.text.trim(),
        _gradingType,
      );

      setState(() {
        _isSubmitting = false;
      });

      if (_gradingType == 'HUMAN') {
        _showHumanGradingDialog();
      } else {
        // Use data from API, fallback to defaults if not present
        final finalResponse = EssaySubmissionResponse(
          id: response.id,
          topic: response.topic,
          content: response.content,
          gradingType: response.gradingType,
          aiFeedback: response.aiFeedback,
          score: response.score,
          taskAchievement: response.taskAchievement ?? 0.0,
          grammaticalRange: response.grammaticalRange ?? 0.0,
          lexicalResource: response.lexicalResource ?? 0.0,
          cohesionCoherence: response.cohesionCoherence ?? 0.0,
          corrections: response.corrections.isNotEmpty 
              ? response.corrections 
              : [
                  WritingCorrection(
                    original: "Example: I is...",
                    corrected: "I am...",
                    explanation: "Note: Real AI corrections will appear here if the backend provides them.",
                  ),
                ],
        );

        setState(() {
          _submissionResponse = finalResponse;
        });

        // Switch to Result tab automatically
        _tabController.animateTo(2);
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

  void _showHumanGradingDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E2330),
          title: const Text('Thông báo', style: TextStyle(color: Colors.white)),
          content: const Text(
            'Bài luận của bạn đã được gửi. Giáo viên sẽ chấm bài và kết quả sẽ được gửi thông báo tới email của bạn sớm nhất.',
            style: TextStyle(color: Colors.white70),
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
      body: Column(
        children: [
          // 1. Grader Toggle
          _buildGraderToggle(),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  
                  // 2. Main Essay View (Input or Corrected View)
                  _buildEssayView(),
                  
                  const SizedBox(height: 24),

                  // 3. Submit Button (only show if not submitted or if re-editing)
                  if (_submissionResponse == null) _buildSubmitButton(),

                  const SizedBox(height: 24),

                  // 4. Bottom Tab Layout (Feedback Sections)
                  _buildFeedbackTabs(),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGraderToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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

  Widget _buildEssayView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Bài viết của bạn',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (_submissionResponse != null)
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _submissionResponse = null;
                  });
                },
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Viết lại'),
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
          child: _submissionResponse == null 
            ? _buildEssayInput() 
            : _buildRichTextEssay(_submissionResponse!.content, _submissionResponse!.corrections),
        ),
        _buildWordCount(),
      ],
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
    // Basic logic: highlight original parts that were corrected
    List<TextSpan> spans = [];
    String remaining = content;

    if (corrections.isEmpty) {
      spans.add(TextSpan(text: content, style: const TextStyle(color: Colors.white70)));
    } else {
      // Very simplified highlighting for demo purposes
      // In a real app, this would use character offsets from the AI response
      for (var correction in corrections) {
        int index = remaining.indexOf(correction.original);
        if (index != -1) {
          // Add text before correction
          spans.add(TextSpan(text: remaining.substring(0, index)));
          
          // Add original (strikethrough)
          spans.add(TextSpan(
            text: correction.original,
            style: TextStyle(
              color: Colors.redAccent.withOpacity(0.8),
              decoration: TextDecoration.lineThrough,
              backgroundColor: Colors.redAccent.withOpacity(0.1),
            ),
          ));

          // Add corrected (bold, green)
          spans.add(TextSpan(
            text: ' ${correction.corrected} ',
            style: const TextStyle(
              color: Colors.greenAccent,
              fontWeight: FontWeight.bold,
              backgroundColor: Color(0x2200FF00),
            ),
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
            Tab(text: 'Đề bài'),
            Tab(text: 'Sửa lỗi'),
            Tab(text: 'Kết quả'),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 400, // Fixed height for tab content
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildQuestionTab(),
              _buildCorrectionsTab(),
              _buildResultTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionTab() {
    return ListView(
      physics: const NeverScrollableScrollPhysics(), // Handled by outer scroll
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

  Widget _buildCorrectionsTab() {
    if (_submissionResponse == null || _submissionResponse!.corrections.isEmpty) {
      return const Center(
        child: Text(
          'Chưa có dữ liệu sửa lỗi.',
          style: TextStyle(color: Colors.white30),
        ),
      );
    }

    return ListView.separated(
      itemCount: _submissionResponse!.corrections.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final correction = _submissionResponse!.corrections[index];
        return Card(
          color: const Color(0xFF1E2330),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Colors.white10)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        correction.original,
                        style: const TextStyle(
                          color: Colors.white60,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        correction.corrected,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24, color: Colors.white10),
                Text(
                  correction.explanation,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        );
      },
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
        // Total Score
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
        
        // Sub-scores Grid
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.8,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            _buildScoreItem('Task Achievement', _submissionResponse!.taskAchievement ?? 0),
            _buildScoreItem('Cohesion & Coherence', _submissionResponse!.cohesionCoherence ?? 0),
            _buildScoreItem('Lexical Resource', _submissionResponse!.lexicalResource ?? 0),
            _buildScoreItem('Grammatical Range', _submissionResponse!.grammaticalRange ?? 0),
          ],
        ),

        const SizedBox(height: 32),

        // Feedback Text
        const Text(
          'Nhận xét chi tiết',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _submissionResponse!.aiFeedback ?? "Không có nhận xét.",
            style: const TextStyle(color: Colors.white70, height: 1.6),
          ),
        ),
      ],
    );
  }

  Widget _buildScoreItem(String label, double score) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: Colors.white60, fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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