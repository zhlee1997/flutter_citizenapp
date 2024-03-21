import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ShowNotification {
  final FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;

  ShowNotification({this.flutterLocalNotificationsPlugin});

  AndroidNotificationDetails androidPlatformChannelSpecifics =
      const AndroidNotificationDetails(
    'your channel id',
    'your channel name',
    channelDescription: 'your channel description',
    color: Colors.white,
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
    largeIcon: DrawableResourceAndroidBitmap('@drawable/notification_icon'),
  );

  DarwinNotificationDetails iOSPlatformChannelSpecifics =
      const DarwinNotificationDetails();

  /// Displays local notification when receives push notification
  ///
  /// Receives [body] as the message content
  /// [title] as the message title
  /// [messageId] as the message ID
  Future<void> showNormalNotification({
    required String body,
    required String title,
    required String messageId,
  }) async {
    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin!.show(
      Random().nextInt(100),
      title,
      body,
      platformChannelSpecifics,
      payload: messageId.toString(),
    );
  }
}
