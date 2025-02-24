import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';

import './show_notification.dart';
import '../navigation_service.dart';
import '../../services/notification_services.dart';
import '../../screens/announcement/announcement_detail_screen.dart';

class PushNotification {
  late bool? _initLocalNotifcation;
  NotificationServices _notificationServices = NotificationServices();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  AndroidNotificationChannel _androidNotificationChannel =
      const AndroidNotificationChannel(
    "citizenapp_notification", // id
    'CitizenApp Notification', // title
    description: 'To cater for CitizenApp Notification', // description
    importance: Importance.high,
    enableVibration: true,
    playSound: true,
  );

  /// TODO: Navigate to Announcement Detail Screen when tapping on local notification
  ///
  /// Receives [payload] as the announcement ID
  Future<dynamic> _onSelectNotitification(String? payload) async {
    NavigationService.instance.navigateTo(
      AnnouncementDetailScreen.routeName,
      arguments: {
        'id': '$payload',
        'isMajor': true,
      },
    );
  }

  /// TODO: Navigate to Announcement Detail Screen when tapping on local notification
  ///
  /// Receives [payload] as the announcement ID
  Future<dynamic> _onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) async {
    NavigationService.instance.navigateTo(
      AnnouncementDetailScreen.routeName,
      arguments: {
        'id': '${notificationResponse.payload}',
        'isMajor': true,
      },
    );
  }

  /// Initialize Firebase Cloud Messaging & Local Notifications
  ///
  /// Receives [isAuth] as the authentication status
  Future<void> setFirebase(bool isFCMRequired) async {
    // if isFCMRequired is true, then getFcmToken()
    // else, delete FCM Token
    if (isFCMRequired) {
      try {
        PermissionStatus permissionStatus =
            await Permission.notification.request();
        if (permissionStatus.isDenied) {
          Fluttertoast.showToast(
              msg:
                  "Notification permission is denied. Please turn on in OS Settings.");
        } else if (permissionStatus.isPermanentlyDenied) {
          Fluttertoast.showToast(
              msg:
                  "Notification permission is permenantly denied. Please turn on in OS Settings.");
        }
        await getFcmToken();
      } catch (e) {
        print("getFcmToken error: ${e.toString()}");
      }
    } else {
      try {
        await _firebaseMessaging.deleteToken();
        print("Delete FCM Token (Firebase service)");
        return;
      } catch (e) {
        print("Firebase service unavailable");
        Fluttertoast.showToast(msg: "Firebase service unavailable");
      }
    }

    // todo: initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    final AndroidInitializationSettings initializationSettingsAndroid =
        new AndroidInitializationSettings('@drawable/notification_icon');

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    _initLocalNotifcation = await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) async {
        try {
          await _onDidReceiveNotificationResponse(details);
        } catch (e) {
          print(e.toString());
        }
      },
    );

    if (_initLocalNotifcation!) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_androidNotificationChannel);

      ShowNotification _showNotification = ShowNotification(
        flutterLocalNotificationsPlugin: _flutterLocalNotificationsPlugin,
      );

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (Platform.isIOS) {
          String messageId = message.data['msgId'];
          String? title = message.notification!.title;
          String? body = message.notification!.body;

          _showNotification.showNormalNotification(
            messageId: messageId,
            title: title!,
            body: body!,
          );
        } else {
          String messageId = message.data['msgId'];
          String title = message.data['title'];
          String body = message.data['body'];

          _showNotification.showNormalNotification(
            messageId: messageId,
            title: title,
            body: body,
          );
        }
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        var payload = message.data['msgId'];
        print("payload: $payload");
        _onSelectNotitification(payload);
      });
    }
  }

  /// Get FCM Token from Firebase when user is authenticated
  /// And app is first opened
  Future<void> getFcmToken() async {
    try {
      String? fcmToken = await _firebaseMessaging.getToken();
      print('getFcmToken: $fcmToken');

      if (fcmToken!.isNotEmpty) {
        _firebaseMessaging.onTokenRefresh.listen((token) async {
          print('onTokenRefresh: $token');
          var response = await _notificationServices.saveToken(token);
          if (response != null) {
            print('onTokenRefresh success');
          } else {
            print('onTokenRefresh fail');
          }
        });

        var response = await _notificationServices.saveToken(fcmToken);
        if (response["status"] == "200") {
          print('saveToken success');
        } else {
          print('saveToken fail');
        }
      }
    } catch (e) {
      print('getFcmToken fail');
      // TODO: Error handling
      // throw e;
      // rethrow;
    }
  }
}
