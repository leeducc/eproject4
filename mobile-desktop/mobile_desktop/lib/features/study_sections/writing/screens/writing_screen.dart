import 'package:flutter/material.dart';
import '../models/topic_model.dart';
import '../models/essay_submission_response.dart';
import '../services/writing_api_service.dart';

class WritingScreen extends StatefulWidget {
  final Topic topic;

  const WritingScreen({Key? key, required this.topic}) : super(key: key);

  @override
  State<WritingScreen> createState() => _WritingScreenState();
}

class _WritingScreenState extends State<WritingScreen> {
  final WritingApiService _apiService = WritingApiService();
  final TextEditingController _contentController = TextEditingController();

  String _gradingType = 'AI';
  bool _isSubmitting = false;
  String? _aiFeedback;
  bool _showHint = false;

  Future<void> _submitEssay() async {
    if (_contentController.text.trim().isEmpty) {
      _showErrorSnackBar('Vui lòng viết bài luận của bạn.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _aiFeedback = null; // reset if grading again
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
        setState(() {
          _aiFeedback = response.aiFeedback;
        });
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF161A23),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Luyện Viết IELTS',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Topic Title
            Text(
              widget.topic.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Topic Description
            Text(
              widget.topic.description,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),

            // Optional Image
            if (widget.topic.imageUrl != null && widget.topic.imageUrl!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    widget.topic.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Text('Không thể tải hình ảnh.', style: TextStyle(color: Colors.redAccent)),
                  ),
                ),
              ),

            // Optional Audio (Placeholder for a generic audio player UI)
            if (widget.topic.audioUrl != null && widget.topic.audioUrl!.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2330),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.audiotrack, color: Colors.blueAccent),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'File âm thanh đính kèm',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.play_arrow, color: Colors.blueAccent),
                      onPressed: () {
                        // TODO: Implement Audio playing logic
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Chức năng phát âm thanh đang được hoàn thiện.')),
                        );
                      },
                    ),
                  ],
                ),
              ),

            // Toggleable Hint
            if (widget.topic.hint != null && widget.topic.hint!.isNotEmpty)
              Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  title: const Text(
                    'Xem gợi ý bài viết (Hint)',
                    style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                  ),
                  iconColor: Colors.blueAccent,
                  collapsedIconColor: Colors.blueAccent,
                  onExpansionChanged: (expanded) {
                    setState(() {
                      _showHint = expanded;
                    });
                  },
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blueAccent.withOpacity(0.5)),
                      ),
                      child: Text(
                        widget.topic.hint!,
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    )
                  ],
                ),
              ),
            
            const SizedBox(height: 20),
            const Text(
              'Phương thức chấm điểm:',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            Row(
              children: [
                Radio<String>(
                  value: 'AI',
                  groupValue: _gradingType,
                  activeColor: Colors.blueAccent,
                  fillColor: MaterialStateProperty.resolveWith((states) => Colors.blueAccent),
                  onChanged: (String? value) {
                    setState(() {
                      _gradingType = value!;
                    });
                  },
                ),
                const Text('AI (Ollama)', style: TextStyle(color: Colors.white)),
                const SizedBox(width: 20),
                Radio<String>(
                  value: 'HUMAN',
                  groupValue: _gradingType,
                  activeColor: Colors.blueAccent,
                  fillColor: MaterialStateProperty.resolveWith((states) => Colors.blueAccent),
                  onChanged: (String? value) {
                    setState(() {
                      _gradingType = value!;
                    });
                  },
                ),
                const Text('Giáo viên', style: TextStyle(color: Colors.white)),
              ],
            ),
            const SizedBox(height: 16),

            // Text Input For Essay
            Container(
              height: 300, // Fixed height for input area
              decoration: BoxDecoration(
                color: const Color(0xFF1E2330),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white24),
              ),
              child: TextField(
                controller: _contentController,
                style: const TextStyle(color: Colors.white),
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  hintText: 'Nhập bài luận của bạn vào đây...',
                  hintStyle: TextStyle(color: Colors.white30),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Submit Button or Loading State
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitEssay,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isSubmitting
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(width: 12),
                          Text(
                            'AI đang chấm bài của bạn, vui lòng đợi...',
                            style: TextStyle(color: Colors.white),
                          )
                        ],
                      )
                    : const Text(
                        'Nộp bài',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
              ),
            ),

            // Inline AI Feedback display
            if (_aiFeedback != null && _gradingType == 'AI')
              Container(
                margin: const EdgeInsets.only(top: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2330),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.greenAccent.withOpacity(0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.greenAccent),
                        SizedBox(width: 8),
                        Text(
                          'Kết quả chấm từ AI',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _aiFeedback!,
                      style: const TextStyle(color: Colors.white70, height: 1.5),
                    )
                  ],
                ),
              ),
              
            const SizedBox(height: 40), // Padding at bottom of scrollable area
          ],
        ),
      ),
    );
  }
}