class NotificationService {
  // key = user identifier (email / userId)
  static final Map<String, List<Map<String, String>>> _notifications = {};

  /// Tambah notifikasi untuk user tertentu
  static void addNotification({
    required String userKey,
    required String title,
    required String message,
  }) {
    // Jika user belum punya list notif → buatkan
    _notifications.putIfAbsent(userKey, () => []);

    _notifications[userKey]!.add({
      'title': title,
      'message': message,
      'time': DateTime.now().toString(),
    });
  }

  /// Ambil semua notifikasi user tertentu
  static List<Map<String, String>> getNotifications(String userKey) {
    return _notifications[userKey] ?? [];
  }

  /// Hapus semua notifikasi user (opsional)
  static void clearNotifications(String userKey) {
    _notifications.remove(userKey);
  }
}
