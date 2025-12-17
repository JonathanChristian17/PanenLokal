import 'package:flutter/material.dart';
import '../services/notification_service.dart'; // pastikan path sesuai lokasi notification_service.dart
import '../services/auth_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, String>> _notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final user = await AuthService.getLocalUser();
    if (user == null) {
      setState(() {
        _notifications = [];
        _loading = false;
      });
      return;
    }
    final String userKey = user.email;
    final list = NotificationService.getNotifications(user.email);
    setState(() {
      _notifications = List<Map<String, String>>.from(list);
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notifikasi")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
          ? const Center(
              child: Text(
                "Belum ada notifikasi",
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notif = _notifications[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    title: Text(notif['title'] ?? ""),
                    subtitle: Text(notif['message'] ?? ""),
                    leading: const Icon(Icons.notifications),
                  ),
                );
              },
            ),
    );
  }
}
