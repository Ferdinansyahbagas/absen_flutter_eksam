// lib/notification_provider.dart
import 'package:flutter/material.dart';
import 'notification_model.dart';

class NotificationProvider with ChangeNotifier {
  List<NotificationModel> _notifications = [
    NotificationModel(title: "New Message", message: "You have a new message from John."),
    NotificationModel(title: "App Update", message: "Version 2.0 is now available."),
    NotificationModel(title: "Friend Request", message: "Anna sent you a friend request."),
  ];

  List<NotificationModel> get notifications => _notifications;

  void markAsRead(int index) {
    _notifications[index].isRead = true;
    notifyListeners();
  }
}
