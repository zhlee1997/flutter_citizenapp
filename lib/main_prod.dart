import 'dart:io';
import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

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
  await runZonedGuarded(
    () async {
      await dotenv.load(fileName: ".env");
      AppConfig.baseURL = AppConfig().baseUrlProduction;
      AppConfig.picFlavor = Flavor.prod;
      AppConfig.sarawakIdCallbackURL =
          AppConfig().sarawakIdCallbackURLProduction;
      AppConfig.sarawakIdClientID = AppConfig().sarawakIdClientIDProduction;

      // Ensure Flutter is initialized
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);
      FlutterError.onError = (errorDetails) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
      };
      // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
      HttpOverrides.global = MyHttpOverrides();
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
