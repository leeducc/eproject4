import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/models/exam_model.dart';
import '../services/exam_api_service.dart';
import 'dart:async';
import 'dart:math';

class ExamTestScreen extends StatefulWidget {
  final ExamModel exam;

  const ExamTestScreen({Key? key, required this.exam}) : super(key: key);

  @override
  State<ExamTestScreen> createState() => _ExamTestScreenState();
}

enum ExamStage {
  preFlight,
  listening,
  break1,
  reading,
  break2,
  writing,
  submitting,
  finished
}

class _ExamTestScreenState extends State<ExamTestScreen> {
  final ExamApiService _apiService = ExamApiService();

  ExamStage _currentStage = ExamStage.preFlight;
  
  
  int _listeningTime = 40 * 60;
  int _readingTime = 60 * 60;
  int _writingTime = 60 * 60;
  int _breakTime = 10 * 60;

  int _currentRemainingSecs = 0;
  Timer? _timer;

  
  double? _listeningScore;
  double? _readingScore;
  int? _writingSubmissionId; 

  final TextEditingController _writingController = TextEditingController();
  String _writingGradingType = 'AI';

  @override
  void dispose() {
    _timer?.cancel();
    _writingController.dispose();
    super.dispose();
  }

  void _startTimer(int seconds) {
    _timer?.cancel();
    setState(() {
      _currentRemainingSecs = seconds;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentRemainingSecs > 0) {
        setState(() {
          _currentRemainingSecs--;
        });
      } else {
        _timer?.cancel();
        _nextStage();
      }
    });
  }

  void _nextStage() {
    _timer?.cancel();
    setState(() {
      switch (_currentStage) {
        case ExamStage.preFlight:
          _currentStage = ExamStage.listening;
          _startTimer(_listeningTime);
          break;
        case ExamStage.listening:
          _listeningScore = Random().nextDouble() * 9; 
          _currentStage = ExamStage.break1;
          _startTimer(_breakTime);
          break;
        case ExamStage.break1:
          _currentStage = ExamStage.reading;
          _startTimer(_readingTime);
          break;
        case ExamStage.reading:
          _readingScore = Random().nextDouble() * 9; 
          _currentStage = ExamStage.break2;
          _startTimer(_breakTime);
          break;
        case ExamStage.break2:
          _currentStage = ExamStage.writing;
          _startTimer(_writingTime);
          break;
        case ExamStage.writing:
          _submitExam();
          break;
        default:
          break;
      }
    });
  }

  void _skipBreak() {
    if (_currentStage == ExamStage.break1 || _currentStage == ExamStage.break2) {
      _nextStage();
    }
  }

  Future<void> _submitExam() async {
    setState(() {
      _currentStage = ExamStage.submitting;
    });

    try {
      
      
      _writingSubmissionId = 123; 

      await _apiService.submitExam(
        widget.exam.id,
        _listeningScore,
        _readingScore,
        _writingSubmissionId,
        'COMPLETED',
      );

      if (!mounted) return;
      setState(() {
        _currentStage = ExamStage.finished;
      });
    } catch (e) {
      debugPrint('Submit error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi khi nộp bài. Bạn có thể kiểm tra kết nối.')),
      );
      setState(() {
        _currentStage = ExamStage.finished;
      });
    }
  }

  void _giveUp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E2330),
        title: const Text('Bỏ cuộc?', style: TextStyle(color: Colors.white)),
        content: const Text('Bạn có chắc chắn muốn thoát? Kết quả bài thi sẽ không được lưu.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); 
              Navigator.pop(context); 
            },
            child: const Text('Thoát', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  String _formatTime(int totalSeconds) {
    int m = totalSeconds ~/ 60;
    int s = totalSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF161A23),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.exam.title,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 24),
          onPressed: _giveUp,
        ),
        actions: [
          if (_currentStage != ExamStage.preFlight && _currentStage != ExamStage.finished && _currentStage != ExamStage.submitting)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Text(
                  _formatTime(_currentRemainingSecs),
                  style: const TextStyle(color: Colors.orangeAccent, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _buildCurrentStageView(),
              ),
              if (_currentStage != ExamStage.preFlight && _currentStage != ExamStage.finished && _currentStage != ExamStage.submitting && !_currentStage.toString().toLowerCase().contains('break'))
                 ElevatedButton(
                  onPressed: _nextStage,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blueAccent,
                  ),
                  child: Text('Nộp phần thi ${_currentStage.name}'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStageView() {
    switch (_currentStage) {
      case ExamStage.preFlight:
        return _buildPreFlight();
      case ExamStage.listening:
        return _buildSectionPlaceholder('Listening', 'Nghe đoạn hội thoại và trả lời câu hỏi. (Auto-graded)');
      case ExamStage.break1:
      case ExamStage.break2:
        return _buildBreak();
      case ExamStage.reading:
        return _buildSectionPlaceholder('Reading', 'Đọc đoạn văn và trả lời câu hỏi. (Auto-graded)');
      case ExamStage.writing:
        return _buildWritingSection();
      case ExamStage.submitting:
        return const Center(child: CircularProgressIndicator());
      case ExamStage.finished:
        return _buildFinished();
    }
  }

  Widget _buildPreFlight() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Cấu hình bài thi', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Bạn có thể giảm thời gian làm bài để thử thách bản thân.', style: TextStyle(color: Colors.white54)),
          const SizedBox(height: 32),
          _buildTimeConfigRow('Listening', _listeningTime, (val) => setState(() => _listeningTime = val)),
          const SizedBox(height: 16),
          _buildTimeConfigRow('Reading', _readingTime, (val) => setState(() => _readingTime = val)),
          const SizedBox(height: 16),
          _buildTimeConfigRow('Writing', _writingTime, (val) => setState(() => _writingTime = val)),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: _nextStage,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.green,
              minimumSize: const Size.fromHeight(50)
            ),
            child: const Text('Bắt đầu làm bài', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Widget _buildTimeConfigRow(String title, int currentSecs, Function(int) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 18)),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: Colors.white54),
              onPressed: () { if (currentSecs > 60) onChanged(currentSecs - 60); },
            ),
            Text('${currentSecs ~/ 60} min', style: const TextStyle(color: Colors.white, fontSize: 16)),
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Colors.blueAccent),
              onPressed: () { onChanged(currentSecs + 60); },
            ),
          ],
        )
      ],
    );
  }

  Widget _buildBreak() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.coffee, size: 64, color: Colors.orangeAccent),
        const SizedBox(height: 24),
        const Text('Thời gian nghỉ Giải lao', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Text('Bạn có 10 phút để nghỉ ngơi trước phần thi tiếp theo.', style: const TextStyle(color: Colors.white70), textAlign: TextAlign.center,),
        const SizedBox(height: 48),
        OutlinedButton(
           onPressed: _skipBreak,
           style: OutlinedButton.styleFrom(
             padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
             side: const BorderSide(color: Colors.blueAccent),
           ),
           child: const Text('Bỏ qua nghỉ giải lao', style: TextStyle(color: Colors.blueAccent)),
        )
      ],
    );
  }

  Widget _buildSectionPlaceholder(String name, String desc) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Phần thi $name', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text(desc, style: const TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }

  Widget _buildWritingSection() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
         children: [
            const Text('Phần thi Writing', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text('Topic: Describe a difficult challenge you overcame.', style: TextStyle(color: Colors.white70, fontStyle: FontStyle.italic)),
            const SizedBox(height: 24),
            Container(
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
                selected: <String>{_writingGradingType},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _writingGradingType = newSelection.first;
                  });
                },
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: _writingGradingType == 'AI' ? Colors.purpleAccent.withValues(alpha: 0.2) : Colors.blueAccent.withValues(alpha: 0.2),
                  selectedForegroundColor: _writingGradingType == 'AI' ? Colors.purpleAccent : Colors.blueAccent,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: const Color(0xFF1E2330),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: TextField(
                controller: _writingController,
                style: const TextStyle(color: Colors.white, height: 1.5),
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Nhập bài luận của bạn vào đây...',
                  hintStyle: TextStyle(color: Colors.white30),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
             )
         ]
      ),
    );
  }

  Widget _buildFinished() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 80),
          const SizedBox(height: 24),
          const Text('Hoàn thành bài thi!', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          const Text('Kết quả của bạn đã được ghi nhận vào hệ thống.', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); 
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 48),
            ),
            child: const Text('Quay lại Home'),
          )
        ],
      ),
    );
  }
}