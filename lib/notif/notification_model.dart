// import 'dart:math';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/timezone.dart' as tz;

// class NotificatiionService {
//   static final NotificatiionService _instance =
//       NotificatiionService._internal();
//   factory NotificatiionService() => _instance;
//   NotificatiionService._internal();

//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();
//   Future<void> initialize() async {
//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');

//     const DarwinInitializationSettings initializationSettingsIOS =
//         DarwinInitializationSettings(
//             requestAlertPermission: true,
//             requestBadgePermission: true,
//             requestSoundPermission: true);

//     const InitializationSettings initializationSettings =
//         InitializationSettings(
//             android: initializationSettingsAndroid,
//             iOS: initializationSettingsIOS);

//     await flutterLocalNotificationsPlugin.initialize(
//       initializationSettings,
//       onDidReceiveBackgroundNotificationResponse: _onNotificationTap,
//     );
//   }

//   void _onNotificationTap(NotificationResponse response) {
//     print("Notification Clicked: ${response.payload}");
//   }

//   Future<void> showInstantNotification() async {
//     const AndroidNotificationDetails androidPlatformChannelSpecifies =
//         AndroidNotificationDetails(
//       'instant_channel',
//       'Instant Notifications',
//       channelDescription: 'Channel for instant notification',
//       importance: Importance.max,
//       priority: Priority.high,
//     );
//     const NotificationDetails platformChannelSpecifies =
//         NotificationDetails(android: androidPlatformChannelSpecifies);

//         await flutterLocalNotificationsPlugin.show(0, 'title of notification', 'deskripsi notification', notificationDetails)
//   }
// }
