import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/tutoring_provider.dart';
import '../../../../data/models/tutoring_models.dart';

class SpeakingScreen extends StatefulWidget {
  const SpeakingScreen({Key? key}) : super(key: key);

  @override
  State<SpeakingScreen> createState() => _SpeakingScreenState();
}

class _SpeakingScreenState extends State<SpeakingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TutoringProvider>().fetchAvailableTeachers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<TutoringProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF161A23),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Luyện Nói 1-1',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: () => tp.fetchAvailableTeachers(),
          ),
        ],
      ),
      body: tp.isLoadingTeachers
          ? const Center(child: CircularProgressIndicator())
          : tp.availableTeachers.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: () => tp.fetchAvailableTeachers(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: tp.availableTeachers.length,
                    itemBuilder: (context, index) {
                      return _buildTeacherCard(tp.availableTeachers[index]);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off_rounded, size: 64, color: Colors.white24),
          SizedBox(height: 16),
          Text(
            'Hiện chưa có giáo viên nào sẵn sàng.',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherCard(TeacherSchedule teacher) {
    return Card(
      color: Colors.white.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.only(bottom: 24),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.blueAccent.withOpacity(0.2),
                  child: teacher.avatar.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(32),
                          child: Image.network(teacher.avatar,
                              fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.person, color: Colors.blueAccent)))
                      : const Icon(Icons.person, color: Colors.blueAccent, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        teacher.fullName,
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            teacher.averageRating.toStringAsFixed(1),
                            style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 8),
                          const Text('•', style: TextStyle(color: Colors.white24)),
                          const SizedBox(width: 8),
                          const Text('IELTS Specialist', style: TextStyle(color: Colors.blueAccent, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (teacher.bio.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                teacher.bio,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white60, fontSize: 14, height: 1.4),
              ),
            ],
            const SizedBox(height: 24),
            const Text(
              'Lịch dạy hôm nay',
              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            teacher.availableSlots.isEmpty
                ? const Text('Chưa có lịch dạy.', style: TextStyle(color: Colors.white24, fontSize: 13))
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: teacher.availableSlots.map((slot) => _buildSlotPill(slot)).toList(),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlotPill(TeacherSlot slot) {
    // Extract HH:mm from "HH:mm dd/MM/yyyy"
    final timeStr = slot.startTime.split(' ').first;

    return GestureDetector(
      onTap: () => _confirmBooking(slot),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.blueAccent.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
        ),
        child: Text(
          timeStr,
          style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
    );
  }

  void _confirmBooking(TeacherSlot slot) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E2430),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Xác nhận đặt lịch', style: TextStyle(color: Colors.white)),
        content: Text(
          'Bạn có muốn đặt lịch học vào lúc ${slot.startTime}?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.pop(context);
              _bookSlot(slot.id);
            },
            child: const Text('Xác nhận', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _bookSlot(int slotId) async {
    final success = await context.read<TutoringProvider>().bookSlot(slotId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Đặt lịch thành công!' : 'Đặt lịch thất bại. Vui lòng thử lại.'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }
}