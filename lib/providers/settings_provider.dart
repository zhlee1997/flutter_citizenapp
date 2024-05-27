import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

class SettingsProvider with ChangeNotifier {
  late bool _isSplashScreenMusicEnabled;
  bool get isSplashScreenMusicEnabled => _isSplashScreenMusicEnabled;

  bool _isPushNotificationEnabled = true;
  bool get isPushNotificationEnabled => _isPushNotificationEnabled;

  /// Turn on music of splash video in Settings
  Future<void> enableSplashScreenMusic() async {
    final prefs = await SharedPreferences.getInstance();
    _isSplashScreenMusicEnabled = true;
    await prefs.setBool('enableSplashScreenMusic', _isSplashScreenMusicEnabled);
    notifyListeners();
  }

  /// Turn off music of splash video in Settings
  Future<void> disableSplashScreenMusic() async {
    final prefs = await SharedPreferences.getInstance();
    _isSplashScreenMusicEnabled = false;
    await prefs.setBool('enableSplashScreenMusic', _isSplashScreenMusicEnabled);
    notifyListeners();
  }

  /// Check last-saved settings preference when app is opened
  Future<void> checkSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('enableSplashScreenMusic') != null) {
      _isSplashScreenMusicEnabled = prefs.getBool('enableSplashScreenMusic')!;
      logger.d('checkSettings: $_isSplashScreenMusicEnabled');
    } else {
      _isSplashScreenMusicEnabled = true;
      logger.d('checkSettings: null');
    }
    notifyListeners();
  }

  /// Turn on push notification in Settings
  Future<void> enablePushNotification() async {
    final prefs = await SharedPreferences.getInstance();
    _isPushNotificationEnabled = true;
    await prefs.setBool('enablePushNotification', _isPushNotificationEnabled);
    notifyListeners();
  }

  /// Turn off push notification in Settings
  Future<void> disablePushNotification() async {
    final prefs = await SharedPreferences.getInstance();
    _isPushNotificationEnabled = false;
    await prefs.setBool('enablePushNotification', _isPushNotificationEnabled);
    notifyListeners();
  }

  /// Check last-saved settings preference when app is opened
  Future<bool> checkPushNotification() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool('enablePushNotification') != null) {
        _isPushNotificationEnabled = prefs.getBool('enablePushNotification')!;
        logger.d('checkPushNotification: $_isPushNotificationEnabled');
      } else {
        _isPushNotificationEnabled = true;
        logger.d('checkPushNotification: null');
      }
      notifyListeners();
      return _isPushNotificationEnabled;
    } catch (e) {
      print("checkPushNotification error: ${e.toString()}");
      rethrow;
    }
  }
}
