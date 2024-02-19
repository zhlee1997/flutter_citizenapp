import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import './screens/home_screen.dart';
import './screens/splash_video_screen.dart';

// providers
import './providers/language_provider.dart';
import './providers/auth_provider.dart';

// language settings
import './utils/app_localization.dart';
import './utils/navigation_service.dart';
import './utils/notification/show_notification.dart';

import 'firebase_options.dart';

import './routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => LanguageProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => AuthProvider(),
        ),
      ],
      child: Consumer<LanguageProvider>(
        child: const SplashVideoScreen(),
        builder: (BuildContext context, dynamic languageData, Widget? child) {
          return MaterialApp(
            navigatorKey: NavigationService.instance.navigationKey,
            title: 'CitizenApp',
            routes: routes,
            onUnknownRoute: (_) => MaterialPageRoute(
              builder: (_) => HomeScreen(),
            ),
            locale: languageData.locale,
            supportedLocales: const [
              Locale('en', 'US'),
              Locale('zh', 'CN'),
              Locale('ms', 'MY'),
            ],
            // These delegates make sure that the localization data for the proper language is loaded
            localizationsDelegates: const [
              // THIS CLASS WILL BE ADDED LATER
              // A class which loads the translations from JSON files
              AppLocalization.delegate,
              // Built-in localization of basic text for Material widgets
              GlobalMaterialLocalizations.delegate,
              // Built-in localization for text direction LTR/RTL
              GlobalWidgetsLocalizations.delegate,
              // Built-in localization of basic text for Cupertino widgets
              GlobalCupertinoLocalizations.delegate,
              // AppLocalizations.delegate,
              MonthYearPickerLocalizations.delegate,
            ],
            localeResolutionCallback: (locale, supportedLocales) {
              // Check if the current device locale is supported
              for (var supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale!.languageCode) {
                  return supportedLocale;
                }
              }

              // If the locale of the device is not supported, use the first one
              // from the list (English, in this case).
              return supportedLocales.first;
            },
            theme: ThemeData(
              useMaterial3: true,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              colorScheme:
                  ColorScheme.fromSeed(seedColor: Colors.deepPurple).copyWith(
                secondary: Colors.purple[50],
                background: Colors.white,
              ),
            ),
            home: child,
          );
        },
      ),
    );
  }
}

// handle firebase push notification in background to show local notification
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  ShowNotification _showNotification = ShowNotification(
      flutterLocalNotificationsPlugin: _flutterLocalNotificationsPlugin);

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
