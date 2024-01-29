import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale? _locale;
  Locale get locale => _locale ?? const Locale('en', 'US');

  /// Check local-saved language preference when app is opened
  Future<void> checkLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('language_code') != null) {
      String? languageCode = prefs.getString('language_code');
      String? countryCode = prefs.getString('country_code');
      debugPrint("checkLanguage: $languageCode");
      _locale = Locale(languageCode!, countryCode);
    } else {
      debugPrint("checkLanguage: null");
      _locale = null;
    }
    notifyListeners();
  }

  /// Change language preference when choosing different language
  ///
  /// Receives [languageCode] as the language code to set language
  /// And [countryCode] as the country code to set the version of the language
  Future<void> changeLanguage(String languageCode, String countryCode) async {
    final prefs = await SharedPreferences.getInstance();
    if (languageCode == 'ms') {
      await prefs.setString('language_code', 'ms');
      await prefs.setString('country_code', 'MY');
    } else if (languageCode == 'en') {
      await prefs.setString('language_code', 'en');
      await prefs.setString('country_code', 'US');
    } else {
      await prefs.setString('language_code', 'zh');
      await prefs.setString('country_code', 'CN');
    }
    _locale = Locale(languageCode, countryCode);
    notifyListeners();
  }
}
