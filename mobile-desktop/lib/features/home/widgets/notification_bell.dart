import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../../data/services/system_notification_service.dart';
import '../../study_sections/services/moderation_service.dart';

class NotificationBell extends StatefulWidget {
  const NotificationBell({super.key});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  final ModerationService _moderationService = ModerationService();
  final SystemNotificationService _systemService = SystemNotificationService();
  
  List<dynamic> _allNotifications = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      final moderationData = await _moderationService.getNotifications();
      final systemData = await _systemService.getNotifications();
      
      final List<Map<String, dynamic>> modMapped = moderationData.map<Map<String, dynamic>>((n) => {
        'id': n['id'],
        'title': 'Moderation Update',
        'content': n['message'],
        'type': 'MODERATION',
        'createdAt': n['createdAt'],
        'isRead': false,
      }).toList();

      final List<Map<String, dynamic>> sysMapped = systemData.map<Map<String, dynamic>>((n) => {
        'id': n['id'],
        'title': n['title'],
        'content': n['content'],
        'type': n['type'],
        'createdAt': n['createdAt'],
        'isRead': n['isRead'] ?? false,
      }).toList();

      final combined = [...modMapped, ...sysMapped];
      combined.sort((a, b) {
        final dateA = DateTime.parse(a['createdAt']);
        final dateB = DateTime.parse(b['createdAt']);
        return dateB.compareTo(dateA);
      });

      if (mounted) {
        setState(() {
          _allNotifications = combined;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showNotifications() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Notifications',
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.refresh, color: theme.primaryColor),
                    onPressed: () {
                      _fetchNotifications().then((_) => setModalState(() {}));
                    },
                  )
                ],
              ),
              const SizedBox(height: 20),
              if (_isLoading)
                const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
              else if (_allNotifications.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 60),
                    child: Column(
                      children: [
                        Icon(Icons.notifications_off_outlined, color: theme.disabledColor.withOpacity(0.2), size: 64),
                        const SizedBox(height: 16),
                        Text('No notifications yet', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5), fontSize: 16)),
                      ],
                    ),
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _allNotifications.length,
                    separatorBuilder: (context, index) => Divider(color: theme.dividerColor, height: 1),
                    itemBuilder: (context, index) {
                      final n = _allNotifications[index];
                      final isRead = n['isRead'] == true;
                      
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: n['type'] == 'POLICY_UPDATE' ? Colors.amber.withOpacity(0.2) : theme.primaryColor.withOpacity(0.2),
                                  child: Icon(
                                    n['type'] == 'POLICY_UPDATE' ? Icons.shield_outlined : Icons.info_outline,
                                    color: n['type'] == 'POLICY_UPDATE' ? Colors.amber : theme.primaryColor,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        n['title'],
                                        style: theme.textTheme.titleSmall?.copyWith(
                                          color: isRead ? theme.colorScheme.onSurface.withOpacity(0.6) : theme.colorScheme.onSurface,
                                          fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Html(
                                        data: n['content'],
                                        style: {
                                          "body": Style(
                                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                                            fontSize: FontSize(13),
                                            margin: Margins.zero,
                                            padding: HtmlPaddings.zero,
                                          ),
                                          "strong": Style(color: theme.colorScheme.onSurface),
                                        },
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        n['createdAt'] != null ? DateTime.parse(n['createdAt']).toLocal().toString().split('.')[0] : "",
                                        style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.3), fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                                if (!isRead)
                                  TextButton(
                                    onPressed: () async {
                                      if (n['type'] == 'MODERATION') {
                                        await _moderationService.markRead(n['id']);
                                      } else {
                                        await _systemService.markRead(n['id']);
                                      }
                                      await _fetchNotifications();
                                      setModalState(() {});
                                    },
                                    child: Text('Clear', style: TextStyle(color: theme.primaryColor, fontSize: 12)),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final unreadCount = _allNotifications.where((n) => n['isRead'] == false).length;

    return IconButton(
      icon: Stack(
        children: [
          Icon(Icons.notifications_none_rounded, color: theme.colorScheme.onSurface, size: 28),
          if (unreadCount > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: theme.appBarTheme.backgroundColor ?? theme.colorScheme.surface, width: 1.5),
                ),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                child: Text(
                  unreadCount > 9 ? '9+' : '$unreadCount',
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