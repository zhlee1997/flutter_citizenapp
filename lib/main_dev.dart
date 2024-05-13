import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'my_app.dart';
import 'firebase_options.dart';
import './utils/notification/show_notification.dart';
import './config/app_config.dart';

Future<void> main() async {
  AppConfig.baseURL = AppConfig().baseUrlDev;
  AppConfig.picFlavor = Flavor.dev;
  AppConfig.sarawakIdCallbackURL = AppConfig().sarawakIdCallbackURLDev;
  AppConfig.sarawakIdClientID = AppConfig().sarawakIdClientIDDev;

  runZonedGuarded(
    () async {
      // Ensure Flutter is initialized
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ); // Initialize Firebase
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);
      runApp(const MyApp());
    },
    (error, stackTrace) {
      // Handle the error gracefully
      debugPrint('Error: ${error.toString()}');
      // You can log the error or send it to a crash reporting service
      FirebaseCrashlytics.instance.recordError(error, stackTrace, fatal: true);
    },
  );
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
}

// handle firebase push notification in background to show local notification
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  ShowNotification _showNotification = ShowNotification(
    flutterLocalNotificationsPlugin: _flutterLocalNotificationsPlugin,
  );

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
    // String messageId = message.data['msgId'];
    // String title = message.data['title'];
    // String body = message.data['body'];

    // _showNotification.showNormalNotification(
    //   messageId: messageId,
    //   title: title,
    //   body: body,
    // );
  }
}
