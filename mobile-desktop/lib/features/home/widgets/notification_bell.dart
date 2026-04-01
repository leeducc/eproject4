import 'package:flutter/material.dart';
import '../../study_sections/services/moderation_service.dart';

class NotificationBell extends StatefulWidget {
  const NotificationBell({super.key});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  final ModerationService _service = ModerationService();
  List<dynamic> _notifications = [];

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    try {
      final data = await _service.getNotifications();
      if (mounted) {
        setState(() => _notifications = data);
      }
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
    }
  }

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1F222A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Notifications',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            if (_notifications.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Text('No new notifications', style: TextStyle(color: Colors.white54)),
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final n = _notifications[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(
                        backgroundColor: Colors.blueAccent,
                        child: Icon(Icons.info_outline, color: Colors.white, size: 20),
                      ),
                      title: Text(n['message'], style: const TextStyle(color: Colors.white, fontSize: 14)),
                      subtitle: Text(
                        n['createdAt'] != null ? DateTime.parse(n['createdAt']).toLocal().toString().split('.')[0] : "",
                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                      trailing: TextButton(
                        onPressed: () async {
                           await _service.markRead(n['id']);
                           _fetchNotifications();
                           if (context.mounted) Navigator.pop(context);
                        },
                        child: const Text('Clear', style: TextStyle(color: Colors.blue)),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int unreadCount = _notifications.length;
    return IconButton(
      icon: Stack(
        children: [
          const Icon(Icons.notifications_none, color: Colors.white, size: 28),
          if (unreadCount > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  '$unreadCount',
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      onPressed: _showNotifications,
    );
  }
}
