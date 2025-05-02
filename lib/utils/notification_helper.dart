import 'package:shared_preferences/shared_preferences.dart';

class NotificationHelper {
  static const String unreadKey = "unread_notifications";

  /// Periksa apakah ada notifikasi yang belum dibaca
  static Future<bool> hasUnreadNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(unreadKey) ?? false; // Default ke false jika null
  }

  /// Tandai bahwa semua notifikasi sudah dibaca
  static Future<void> markAllAsRead() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(unreadKey, false);
  }

  /// Tandai bahwa ada notifikasi yang belum dibaca
  static Future<void> setUnreadNotifications(bool status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(unreadKey, status);
  }
}
