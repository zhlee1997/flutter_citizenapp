import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'my_app.dart';
import 'firebase_options.dart';
import './utils/notification/show_notification.dart';
import './config/app_config.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> main() async {
  AppConfig.baseURL = AppConfig().baseUrlProduction;
  AppConfig.picFlavor = Flavor.prod;
  AppConfig.sarawakIdCallbackURL = AppConfig().sarawakIdCallbackURLProduction;
  AppConfig.sarawakIdClientID = AppConfig().sarawakIdClientIDProduction;

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
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
