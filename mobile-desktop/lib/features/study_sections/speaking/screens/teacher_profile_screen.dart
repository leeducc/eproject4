import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/tutoring_provider.dart';
import '../../../../data/models/tutoring_models.dart';

class TeacherProfileScreen extends StatelessWidget {
  final TeacherSchedule teacher;

  const TeacherProfileScreen({Key? key, required this.teacher}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          teacher.fullName,
          style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: colorScheme.onSurface, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Teacher Header Profile
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: colorScheme.primary.withOpacity(0.1),
                    child: teacher.avatar.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Image.network(
                              teacher.avatar,
                              fit: BoxFit.cover,
                              width: 100,
                              height: 100,
                              errorBuilder: (_, __, ___) => Icon(Icons.person, color: colorScheme.primary, size: 50),
                            ),
                          )
                        : Icon(Icons.person, color: colorScheme.primary, size: 50),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    teacher.fullName,
                    style: TextStyle(color: colorScheme.onSurface, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        teacher.averageRating.toStringAsFixed(1),
                        style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7), fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 12),
                      Text('•', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.2))),
                      const SizedBox(width: 12),
                      Text('IELTS Specialist', style: TextStyle(color: colorScheme.primary, fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Bio Section
            Text(
              'Giới thiệu',
              style: TextStyle(color: colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              teacher.bio.isNotEmpty ? teacher.bio : 'Chưa có thông tin giới thiệu cho giáo viên này.',
              style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7), fontSize: 15, height: 1.6),
            ),
            
            const SizedBox(height: 32),
            
            // Schedule Section
            Text(
              'Lịch dạy',
              style: TextStyle(color: colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            teacher.availableSlots.isEmpty
                ? _buildEmptySlots(context)
                : _buildGroupedSchedule(context),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupedSchedule(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // Group slots by date string "dd/MM/yyyy"
    final Map<String, List<TeacherSlot>> groupedSlots = {};
    for (var slot in teacher.availableSlots) {
      final date = slot.startTime.split(' ').last;
      groupedSlots.putIfAbsent(date, () => []).add(slot);
    }

    final sortedDates = groupedSlots.keys.toList()..sort((a, b) {
      // Sort by dd/MM/yyyy
      final aParts = a.split('/');
      final bParts = b.split('/');
      final aDt = DateTime(int.parse(aParts[2]), int.parse(aParts[1]), int.parse(aParts[0]));
      final bDt = DateTime(int.parse(bParts[2]), int.parse(bParts[1]), int.parse(bParts[0]));
      return aDt.compareTo(bDt);
    });

    return Column(
      children: sortedDates.map((date) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today, color: colorScheme.primary, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    _formatDateHeader(date),
                    style: TextStyle(color: colorScheme.primary, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: groupedSlots[date]!.map((slot) => _buildSlotPill(context, slot)).toList(),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _formatDateHeader(String dateStr) {
    // Convert dd/MM/yyyy to "Ngày dd Tháng MM" or "Hôm nay, dd/MM"
    final now = DateTime.now();
    final todayStr = "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";
    if (dateStr == todayStr) return "Hôm nay, $dateStr";
    return dateStr;
  }

  Widget _buildEmptySlots(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.onSurface.withOpacity(0.05)),
      ),
      child: Center(
        child: Text(
          'Giáo viên này hiện chưa có lịch dạy nào.',
          textAlign: TextAlign.center,
          style: TextStyle(color: colorScheme.onSurface.withOpacity(0.4), fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildSlotPill(BuildContext context, TeacherSlot slot) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final timeStr = slot.startTime.split(' ').first;
    final bool isBooked = slot.status == 'BOOKED';

    return GestureDetector(
      onTap: isBooked ? null : () => _confirmBooking(context, slot),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isBooked ? colorScheme.onSurface.withOpacity(0.05) : colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isBooked ? colorScheme.onSurface.withOpacity(0.1) : colorScheme.primary.withOpacity(0.35),
          ),
        ),
        child: Text(
          timeStr,
          style: TextStyle(
            color: isBooked ? colorScheme.onSurface.withOpacity(0.2) : colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 15,
            decoration: isBooked ? TextDecoration.lineThrough : null,
          ),
        ),
      ),
    );
  }

  void _confirmBooking(BuildContext context, TeacherSlot slot) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Xác nhận đặt lịch', style: TextStyle(color: colorScheme.onSurface)),
        content: Text(
          'Bạn có muốn đặt lịch học vào lúc ${slot.startTime} với ${teacher.fullName}?',
          style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Hủy', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.pop(dialogContext);
              _bookSlot(context, slot.id);
            },
            child: const Text('Xác nhận', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _bookSlot(BuildContext context, int slotId) async {
    final success = await context.read<TutoringProvider>().bookSlot(slotId);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Đặt lịch thành công!' : 'Đặt lịch thất bại. Vui lòng thử lại.'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
      if (success) {
        // Optionally navigate back or refresh current view
        // Since TutoringProvider.bookSlot calls fetchAvailableTeachers(), 
        // if we want the local teacher object to update, we might need more logic 
        // but for now, navigating back is a safe bet or just relying on user to see it's gone if they reopen.
        Navigator.pop(context); 
      }
    }
  }
}
