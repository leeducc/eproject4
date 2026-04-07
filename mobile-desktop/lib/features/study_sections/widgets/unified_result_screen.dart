import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class UnifiedResultScreen extends StatefulWidget {
  final int score;
  final int total;
  final int time; 
  final String skill; 

  const UnifiedResultScreen({
    super.key,
    required this.score,
    required this.total,
    required this.time,
    required this.skill,
  });

  @override
  State<UnifiedResultScreen> createState() => _UnifiedResultScreenState();
}

class _UnifiedResultScreenState extends State<UnifiedResultScreen> {
  late ConfettiController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ConfettiController(duration: const Duration(seconds: 5));
    _controller.play();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String formatTime(int seconds) {
    int m = seconds ~/ 60;
    int s = seconds % 60;
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    double percent = widget.total > 0 ? (widget.score / widget.total * 100) : 0;
    bool pass = percent >= 60;
    bool isReading = widget.skill == 'READING';

    return Scaffold(
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isReading
                  ? [const Color(0xFFF9A825), const Color(0xFFE65100)]
                  : [const Color(0xFF42A5F5), const Color(0xFF1E88E5)],
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              ConfettiWidget(
                confettiController: _controller,
                blastDirectionality: BlastDirectionality.explosive,
                numberOfParticles: 20,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  const Icon(
                    Icons.emoji_events,
                    size: 120,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    pass ? "Tuyệt vời! 🎉" : "Cố gắng lên! 💪",
                    style: const TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    pass ? "Bạn đã hoàn thành xuất sắc" : "Bạn cần luyện tập thêm",
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 40),
                  _buildStatsRow(percent),
                  const SizedBox(height: 80),
                  const Text(
                    "Chạm vào màn hình để quay lại",
                    style: TextStyle(color: Colors.white60, fontSize: 14),
                  ),
                ],
              ),
              Positioned(
                top: 50,
                left: 10,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(double percent) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem("${percent.toStringAsFixed(0)}%", "Chính xác"),
          Container(height: 40, width: 1, color: Colors.white24),
          _buildStatItem("${widget.score}/${widget.total}", "Kết quả"),
          Container(height: 40, width: 1, color: Colors.white24),
          _buildStatItem(formatTime(widget.time), "Thời gian"),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            color: Colors.yellowAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}