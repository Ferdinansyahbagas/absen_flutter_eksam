// lib/notification_model.dart
class NotificationModel {
  String title;
  String message;
  bool isRead;

  NotificationModel({
    required this.title,
    required this.message,
    this.isRead = false,
  });
}
