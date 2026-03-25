import 'package:flutter/material.dart';
import '../../../../core/models/exam_submission_model.dart';
import '../services/exam_api_service.dart';

class ExamHistoryScreen extends StatefulWidget {
  const ExamHistoryScreen({Key? key}) : super(key: key);

  @override
  State<ExamHistoryScreen> createState() => _ExamHistoryScreenState();
}

class _ExamHistoryScreenState extends State<ExamHistoryScreen> {
  final ExamApiService _apiService = ExamApiService();
  List<ExamSubmissionModel> _submissions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    try {
      final submissions = await _apiService.fetchMySubmissions();
      setState(() {
        _submissions = submissions;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching history: $e');
      setState(() {
         _isLoading = false;
      });
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi tải lịch sử thi')),
      );
    }
  }
  
  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate).toLocal();
      return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF161A23),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Lịch sử thi',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
          : _submissions.isEmpty
              ? const Center(
                  child: Text(
                    'Bạn chưa thi bài nào.',
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _submissions.length,
                  itemBuilder: (context, index) {
                    final sub = _submissions[index];
                    return _buildHistoryCard(sub);
                  },
                ),
    );
  }

  Widget _buildHistoryCard(ExamSubmissionModel sub) {
    return Card(
      color: const Color(0xFF1E2330),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                    sub.examTitle,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: sub.status == 'COMPLETED' ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    sub.status,
                    style: TextStyle(color: sub.status == 'COMPLETED' ? Colors.greenAccent : Colors.orangeAccent, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Ngày thi: ${_formatDate(sub.createdAt)}',
              style: const TextStyle(color: Colors.white54, fontSize: 14),
            ),
            const Divider(color: Colors.white12, height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildScoreItem('Listening', sub.listeningScore),
                _buildScoreItem('Reading', sub.readingScore),
                _buildWritingScoreItem('Writing', sub.writingScore, sub.writingStatus),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreItem(String label, double? score) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          score != null ? score.toStringAsFixed(1) : '-',
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildWritingScoreItem(String label, double? score, String? status) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        const SizedBox(height: 4),
        if (score != null)
           Text(
            score.toStringAsFixed(1),
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          )
        else
           Text(
            status == 'GRADED' ? 'Done' : (status == 'IN_PROGRESS' ? 'Đang chấm' : 'Chờ chấm'),
            style: const TextStyle(color: Colors.orangeAccent, fontSize: 12, fontWeight: FontWeight.bold),
          ),
      ],
    );
  }
}
