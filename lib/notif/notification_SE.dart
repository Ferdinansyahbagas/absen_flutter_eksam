// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/data/latest.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;

// class NotificationHelper {
//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   void initializeNotifications() async {
//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');
//     const InitializationSettings initializationSettings =
//         InitializationSettings(android: initializationSettingsAndroid);
//     await flutterLocalNotificationsPlugin.initialize(initializationSettings);
//     tz.initializeTimeZones(); // Inisialisasi timezone
//   }

//   void scheduleNotifications() async {
//     await flutterLocalNotificationsPlugin.zonedSchedule(
//       0,
//       "Pengingat Masuk Kerja",
//       "Jangan lupa hari ini masuk jam 8.",
//       _scheduleDaily(Time(6, 0)),
//       const NotificationDetails(
//         android: AndroidNotificationDetails(
//           'daily_reminder',
//           'Daily Reminder',
//         ),
//       ),
//       androidAllowWhileIdle: true,
//       uiLocalNotificationDateInterpretation:
//           UILocalNotificationDateInterpretation.absoluteTime,
//       matchDateTimeComponents: DateTimeComponents.time,
//     );

//     await flutterLocalNotificationsPlugin.zonedSchedule(
//       1,
//       "Ayo Absen!",
//       "Ayo absenn, jangan sampai telat!",
//       _scheduleDaily(Time(7, 30)),
//       const NotificationDetails(
//         android: AndroidNotificationDetails(
//           'daily_reminder',
//           'Daily Reminder',
//         ),
//       ),
//       androidAllowWhileIdle: true,
//       uiLocalNotificationDateInterpretation:
//           UILocalNotificationDateInterpretation.absoluteTime,
//       matchDateTimeComponents: DateTimeComponents.time,
//     );

//     await flutterLocalNotificationsPlugin.zonedSchedule(
//       2,
//       "Oops, Terlambat!",
//       "Kamu terlambat, tapi tetap semangat! Jangan lupa absen ya.",
//       _scheduleDaily(Time(8, 0)),
//       const NotificationDetails(
//         android: AndroidNotificationDetails(
//           'daily_reminder',
//           'Daily Reminder',
//         ),
//       ),
//       androidAllowWhileIdle: true,
//       uiLocalNotificationDateInterpretation:
//           UILocalNotificationDateInterpretation.absoluteTime,
//       matchDateTimeComponents: DateTimeComponents.time,
//     );

//     await flutterLocalNotificationsPlugin.zonedSchedule(
//       3,
//       "Saatnya Pulang!",
//       "Kerja keras hari ini luar biasa, saatnya pulang dan istirahat!",
//       _scheduleDaily(Time(16, 0)),
//       const NotificationDetails(
//         android: AndroidNotificationDetails(
//           'daily_reminder',
//           'Daily Reminder',
//         ),

//       ),
//       androidAllowWhileIdle: true,
//       uiLocalNotificationDateInterpretation:
//           UILocalNotificationDateInterpretation.absoluteTime,
//       matchDateTimeComponents: DateTimeComponents.time,
//     );
//   }

//   tz.TZDateTime _scheduleDaily(Time time) {
//     final now = tz.TZDateTime.now(tz.local);
//     final scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day,
//         time.hour, time.minute, time.second);
//     return scheduledDate.isBefore(now)
//         ? scheduledDate.add(Duration(days: 1))
//         : scheduledDate;
//   }
// }
// 
