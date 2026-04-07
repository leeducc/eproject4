import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/tutoring_provider.dart';
import 'tutoring_call_screen.dart';

class WaitingRoomScreen extends StatefulWidget {
  const WaitingRoomScreen({Key? key}) : super(key: key);

  @override
  State<WaitingRoomScreen> createState() => _WaitingRoomScreenState();
}

class _WaitingRoomScreenState extends State<WaitingRoomScreen> {
  bool _dialogShown = false;

  @override
  Widget build(BuildContext context) {
    final tutoringProvider = Provider.of<TutoringProvider>(context);

    // Watch for matches and show confirmation dialog
    if (tutoringProvider.lastMatch != null && !_dialogShown) {
      _dialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showMatchConfirmation(context, tutoringProvider);
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFF161A23),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              // Should probably handle cancel queueing
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
            ),
            const SizedBox(height: 48),
            const Text(
              'Đang tìm giáo viên...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Vui lòng giữ màn hình này để duy trì vị trí của bạn.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
            ),
            const SizedBox(height: 48),
            _buildQueueInfoCard(tutoringProvider),
            const SizedBox(height: 24),
            Text(
              'Cập nhật lúc: ${tutoringProvider.formatVNTime(DateTime.now())}',
              style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQueueInfoCard(TutoringProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem(
            'Vị trí',
            '#${provider.queuePosition}',
            Icons.format_list_numbered,
          ),
          Container(width: 1, height: 40, color: Colors.white.withOpacity(0.1)),
          _buildInfoItem(
            'Chờ dự kiến',
            '~${provider.ewtMinutes}m',
            Icons.access_time,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.blueAccent, size: 24),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _showMatchConfirmation(BuildContext context, TutoringProvider provider) {
    int timeLeft = 60;
    Timer? timer;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            timer ??= Timer.periodic(const Duration(seconds: 1), (t) {
              if (timeLeft > 0) {
                setDialogState(() => timeLeft--);
              } else {
                t.cancel();
                Navigator.of(context).pop(); // Close dialog
                provider.resetMatch();
                _dialogShown = false;
              }
            });

            return AlertDialog(
              backgroundColor: const Color(0xFF1F2430),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.greenAccent),
                  SizedBox(width: 12),
                  Text('Đã tìm thấy giáo viên!', style: TextStyle(color: Colors.white, fontSize: 18)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Bạn có muốn bắt đầu buổi học ngay bây giờ không?',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 24),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(
                          value: timeLeft / 60,
                          strokeWidth: 6,
                          backgroundColor: Colors.white10,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.orangeAccent),
                        ),
                      ),
                      Text(
                        '$timeLeft',
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    timer?.cancel();
                    Navigator.of(context).pop();
                    provider.resetMatch();
                    _dialogShown = false;
                  },
                  child: const Text('Bỏ qua', style: TextStyle(color: Colors.white54)),
                ),
                ElevatedButton(
                  onPressed: () {
                    timer?.cancel();
                    Navigator.of(context).pop();
                    
                    final match = provider.lastMatch;
                    if (match != null) {
                      provider.acceptMatch(match['teacherId']);
                      
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TutoringCallScreen(teacherId: match['teacherId']),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Xác nhận học ngay', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      timer?.cancel();
      _dialogShown = false;
    });
  }
}