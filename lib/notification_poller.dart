import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'notification_service.dart';

// Polls the backend every 30s for new notifications for the logged-in user.
// Converts unread DB notifications into local system notifications.
class NotificationPoller {
  Timer? _timer;
  final String baseUrl;
  final int userId;              // numeric DB user id
  final Set<int> _shownIds = {};  // prevents re-showing the same notification

  NotificationPoller({required this.baseUrl, required this.userId});

  void start() {
    _fetchAndNotify();  // run immediately on start
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _fetchAndNotify());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _fetchAndNotify() async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/notifications/$userId'))
          .timeout(const Duration(seconds: 10));

      if (res.statusCode != 200) return;

      final List notifications = jsonDecode(res.body)['notifications'];

      for (final notif in notifications) {
        final int id = notif['id'];
        final bool isRead = notif['read'] == true;

        if (!isRead && !_shownIds.contains(id)) {
          _shownIds.add(id);
          await LocalNotificationService.show(
            id: id,
            title: notif['title'] ?? 'Lineless',
            body: notif['message'] ?? '',
          );
          // Mark as read on the backend
          _markRead(id);
        }
      }
    } catch (e) {
      debugPrint('[NotificationPoller] fetch error: $e');
    }
  }

  Future<void> _markRead(int notificationId) async {
    try {
      await http.post(
        Uri.parse('$baseUrl/notifications/$notificationId/read'),
      );
    } catch (_) {}
  }
}