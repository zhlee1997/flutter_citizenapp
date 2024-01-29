import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalization {
  final Locale locale;

  AppLocalization(this.locale);

  // Helper method to keep the code in the widgets concise
  // Localizations are accessed using an InheritedWidget "of" syntax
  static AppLocalization? of(BuildContext context) {
    return Localizations.of<AppLocalization>(context, AppLocalization);
  }

  Map<String, String>? _localizedStrings;

  /// Load the language JSON file from the "language" folder
  /// Which is used for language translation
  /// Consists of 'en.json', 'ms.json', 'zh.json'
  Future<bool?> load() async {
    try {
      String jsonString = await rootBundle
          .loadString('assets/language/${locale.languageCode}.json');
      Map<String, dynamic> jsonMap = json.decode(jsonString);

      _localizedStrings =
          jsonMap.map((key, value) => MapEntry(key, value.toString()));
      return true;
    } catch (e) {
      print("load localization fail");
      throw e;
    }
  }

  String? translate(String key) {
    return _localizedStrings![key];
  }

  static const LocalizationsDelegate<AppLocalization> delegate =
      _AppLocalizationsDelegate();
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalization> {
  // This delegate instance will never change (it doesn't even have fields!)
  // It can provide a constant constructor.
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    // Include all of your supported language codes here
    return ['en', 'zh', 'ms'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalization> load(Locale locale) async {
    // AppLocalization class is where the JSON loading actually runs
    AppLocalization localizations = new AppLocalization(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
