import 'package:flutter/material.dart';
import '../../../../core/models/exam_model.dart';
import '../services/exam_api_service.dart';
import '../../exam_engine/screens/exam_launcher_screen.dart';
import 'exam_history_screen.dart';

class SimulateExamScreen extends StatefulWidget {
  const SimulateExamScreen({Key? key}) : super(key: key);

  @override
  State<SimulateExamScreen> createState() => _SimulateExamScreenState();
}

class _SimulateExamScreenState extends State<SimulateExamScreen> {
  final ExamApiService _apiService = ExamApiService();
  List<ExamModel> _exams = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchExams();
  }

  Future<void> _fetchExams() async {
    try {
      final exams = await _apiService.fetchExamsByType('IELTS');
      setState(() {
        _exams = exams;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching mock exams: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi tải danh sách bài thi Mock Exam')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    debugPrint('[SimulateExamScreen] build – brightness: ${theme.brightness}');

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Mock Exam',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: colorScheme.onSurface, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.history, color: colorScheme.onSurface),
            onPressed: () {
              debugPrint('[SimulateExamScreen] History tapped');
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ExamHistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
          : _exams.isEmpty
              ? Center(
                  child: Text(
                    'Hiện chưa có bài thi Mock Exam nào.',
                    style: TextStyle(color: colorScheme.onSurface.withOpacity(0.54), fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _exams.length,
                  itemBuilder: (context, index) {
                    final exam = _exams[index];
                    return _buildExamCard(exam, theme);
                  },
                ),
    );
  }

  Widget _buildExamCard(ExamModel exam, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    int _ = (exam.questions?.length ?? 0) + (exam.groups?.length ?? 0) * 5; 
    
    return Card(
      color: theme.cardTheme.color ?? colorScheme.surface,
      elevation: theme.cardTheme.elevation ?? 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: theme.cardTheme.shape ?? RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          debugPrint('[SimulateExamScreen] Exam tapped: ${exam.title}');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ExamLauncherScreen(exam: exam),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      exam.title,
                      style: TextStyle(color: colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('MOCK', style: TextStyle(color: Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                exam.description ?? 'Full IELTS Mock Test',
                style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6), fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.access_time, color: colorScheme.onSurface.withOpacity(0.3), size: 16),
                  const SizedBox(width: 4),
                  Text('160 mins', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6), fontSize: 12)),
                  const SizedBox(width: 16),
                  Icon(Icons.format_list_bulleted, color: colorScheme.onSurface.withOpacity(0.3), size: 16),
                  const SizedBox(width: 4),
                  Text('4 Skills', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6), fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}