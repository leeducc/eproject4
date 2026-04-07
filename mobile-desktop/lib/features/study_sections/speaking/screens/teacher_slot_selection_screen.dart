import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../data/services/teacher_slot_service.dart';

class TeacherSlotSelectionScreen extends StatefulWidget {
  final int teacherId;
  final String teacherName;

  const TeacherSlotSelectionScreen({
    super.key,
    required this.teacherId,
    required this.teacherName,
  });

  @override
  _TeacherSlotSelectionScreenState createState() => _TeacherSlotSelectionScreenState();
}

class _TeacherSlotSelectionScreenState extends State<TeacherSlotSelectionScreen> {
  final TeacherSlotService _slotService = TeacherSlotService();
  late Future<List<TeacherSlot>> _slotsFuture;

  @override
  void initState() {
    super.initState();
    _slotsFuture = _slotService.getAvailableSlots(widget.teacherId);
  }

  void _bookSlot(int slotId) async {
    try {
      final success = await _slotService.bookSlot(slotId);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã đặt lịch thành công!')),
        );
        setState(() {
          _slotsFuture = _slotService.getAvailableSlots(widget.teacherId);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đặt lịch thất bại.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lịch dạy: ${widget.teacherName}'),
        backgroundColor: Colors.blue[800],
      ),
      body: FutureBuilder<List<TeacherSlot>>(
        future: _slotsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }
          final slots = snapshot.data ?? [];
          if (slots.isEmpty) {
            return const Center(
              child: Text('Giáo viên này hiện chưa có lịch trống.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: slots.length,
            itemBuilder: (context, index) {
              final slot = slots[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.withOpacity(0.2)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.access_time, color: Colors.blue),
                  ),
                  title: Text(
                    'Khung giờ: ${slot.startTime.split(' ')[0]}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Ngày: ${slot.startTime.split(' ')[1]}'),
                      Text(
                        'Dự kiến: ${slot.startTime} - ${slot.endTime}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () => _bookSlot(slot.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Đăng ký', style: TextStyle(color: Colors.white),),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}