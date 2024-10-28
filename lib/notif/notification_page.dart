// lib/notification_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'notification_provider.dart';

class NotificationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          return ListView.builder(
            itemCount: provider.notifications.length,
            itemBuilder: (context, index) {
              final notification = provider.notifications[index];
              return ListTile(
                title: Text(notification.title),
                subtitle: Text(notification.message),
                tileColor: notification.isRead ? Colors.grey[300] : Colors.white,
                onTap: () {
                  provider.markAsRead(index);
                  // Here you can navigate to a detailed page or show more information
                },
              );
            },
          );
        },
      ),
    );
  }
}
