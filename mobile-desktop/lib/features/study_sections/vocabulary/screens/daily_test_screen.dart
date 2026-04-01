import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vocabulary_test_provider.dart';
import 'active_test_screen.dart';

class DailyTestScreen extends StatefulWidget {
  const DailyTestScreen({Key? key}) : super(key: key);

  @override
  State<DailyTestScreen> createState() => _DailyTestScreenState();
}

class _DailyTestScreenState extends State<DailyTestScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VocabularyTestProvider>().loadDueCount();
    });
  }

  @override
  Widget build(BuildContext context) {
    final testProvider = context.watch<VocabularyTestProvider>();
    const bgColor = Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Bài kiểm tra hàng ngày', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.psychology, size: 80, color: Colors.blue),
            ),
            const SizedBox(height: 32),
            const Text(
              'Rèn luyện trí nhớ',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Làm bài kiểm tra hàng ngày giúp bạn ghi nhớ từ vựng lâu hơn thông qua thuật toán lặp lại ngắt quãng.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 16),
              ),
            ),
            const SizedBox(height: 48),
            if (testProvider.isLoading)
              const CircularProgressIndicator(color: Colors.blue)
            else ...[
              Text(
                '${testProvider.dueCount} từ cần ôn tập hôm nay',
                style: const TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  await testProvider.startTest();
                  if (mounted && testProvider.currentTest != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ActiveTestScreen()),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('BẮT ĐẦU KIỂM TRA', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
