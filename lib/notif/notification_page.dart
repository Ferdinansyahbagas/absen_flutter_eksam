// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/data/latest.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;
// import 'package:flutter_native_timezone/flutter_native_timezone.dart';

// class NotificationHelper {
//   static const String unreadKey = "unread_notifications";
//   static final FlutterLocalNotificationsPlugin
//       _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

//   /// Periksa apakah ada notifikasi yang belum dibaca
//   static Future<bool> hasUnreadNotifications() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getBool(unreadKey) ?? false; // Default ke false jika null
//   }

//   /// Tandai bahwa semua notifikasi sudah dibaca
//   static Future<void> markAllAsRead() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setBool(unreadKey, false);
//   }

//   /// Tandai bahwa ada notifikasi yang belum dibaca
//   static Future<void> setUnreadNotifications(bool status) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setBool(unreadKey, status);
//   }

//   static Future<void> initialize() async {
//     // Inisialisasi database zona waktu
//     tz.initializeTimeZones();
//     String currentTimeZone = await FlutterNativeTimezone.getLocalTimezone();
//     tz.setLocalLocation(tz.getLocation(currentTimeZone));

//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');
//     const InitializationSettings initializationSettings =
//         InitializationSettings(android: initializationSettingsAndroid);
//     await _flutterLocalNotificationsPlugin.initialize(
//       initializationSettings,
//     );

//     // Inisialisasi timezone
//     // tz.initializeTimeZones();
//     // final String currentTimeZone = await tz.getLocalTimeZone();
//     // tz.setLocalLocation(tz.getLocation(currentTimeZone));
//   }

//   static Future<void> showNotification({
//     required int id,
//     required String title,
//     required String body,
//   }) async {
//     const AndroidNotificationDetails androidPlatformChannelSpecifics =
//         AndroidNotificationDetails(
//       'default_channel_id',
//       'Default Channel',
//       channelDescription: 'Channel untuk notifikasi pengingat',
//       importance: Importance.high,
//       priority: Priority.high,
//     );

//     const NotificationDetails platformChannelSpecifics =
//         NotificationDetails(android: androidPlatformChannelSpecifics);

//     await _flutterLocalNotificationsPlugin.show(
//       id,
//       title,
//       body,
//       platformChannelSpecifics,
//     );
//   }

//   static Future<void> scheduleNotification({
//     required int id,
//     required String title,
//     required String body,
//     required DateTime scheduledTime,
//   }) async {
//     const AndroidNotificationDetails androidPlatformChannelSpecifics =
//         AndroidNotificationDetails(
//       'scheduled_channel_id',
//       'Scheduled Channel',
//       channelDescription: 'Channel untuk notifikasi terjadwal',
//       importance: Importance.high,
//       priority: Priority.high,
//     );

//     const NotificationDetails platformChannelSpecifics =
//         NotificationDetails(android: androidPlatformChannelSpecifics);

//     await _flutterLocalNotificationsPlugin.zonedSchedule(
//       id,
//       title,
//       body,
//       tz.TZDateTime.from(scheduledTime, tz.local), // Konversi waktu ke TZ
//       platformChannelSpecifics,
//       androidAllowWhileIdle: true,
//       uiLocalNotificationDateInterpretation:
//           UILocalNotificationDateInterpretation.absoluteTime,
//       matchDateTimeComponents:
//           DateTimeComponents.time, // Hanya mencocokkan waktu
//     );
//   }
// }




// // import 'package:shared_preferences/shared_preferences.dart';

// // class NotificationHelper {
// //   static Future<bool> hasUnreadNotifications() async {
// //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //     return prefs.getBool('hasUnreadNotifications') ?? false;
// //   }

// //   static Future<void> setUnreadNotifications(bool status) async {
// //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //     await prefs.setBool('hasUnreadNotifications', status);
// //   }
// // }

// // import 'package:shared_preferences/shared_preferences.dart';

// // class NotificationHelper {
// //   static const String unreadKey = "unread_notifications";

// //   // Mengecek apakah ada notifikasi yang belum dibaca
// //   static Future<bool> hasUnreadNotifications() async {
// //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //     return prefs.getBool(unreadKey) ?? false;
// //   }

// //   // Menyimpan status notifikasi (dibaca/tidak)
// //   static Future<void> setUnreadNotifications(bool status) async {
// //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //     await prefs.setBool(unreadKey, status);
// //   }
// // }