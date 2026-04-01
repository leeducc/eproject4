import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vocabulary_test_provider.dart';

class TestSummaryScreen extends StatelessWidget {
  const TestSummaryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final testProvider = context.watch<VocabularyTestProvider>();
    final questions = testProvider.currentTest!['questions'] as List<dynamic>;
    const bgColor = Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.emoji_events, size: 100, color: Colors.amber),
              const SizedBox(height: 32),
              const Text(
                'Chúc mừng!',
                style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'Bạn đã hoàn thành bài kiểm tra hôm nay.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 18),
              ),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatCard('Đúng', testProvider.correctCount.toString(), Colors.green),
                  _buildStatCard('Tổng số', questions.length.toString(), Colors.blue),
                ],
              ),
              const SizedBox(height: 64),
              ElevatedButton(
                onPressed: () async {
                  await testProvider.finalizeTest();
                  if (context.mounted) {
                    Navigator.pop(context); // Go back to DailyTestScreen (it will show updated due count)
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: testProvider.isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('HOÀN TẤT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(color: color, fontSize: 36, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 16)),
        ],
      ),
    );
  }
}
