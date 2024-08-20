import 'dart:io';

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:appcheck/appcheck.dart';

import '../utils/api_base_helper.dart';
import '../config/app_config.dart';

class GeneralHelper {
  /// Perform formatting of price input when in Bill Payment
  ///
  /// Receives [value] as the input value
  /// Returns formatted price input
  static TextEditingValue formatCurrency({
    required String value,
    required TextEditingController controller,
    required bool isFirst,
  }) {
    String newValue = value.replaceAll(',', '').replaceAll('.', '');
    if (value.isEmpty || newValue == '00') {
      controller.clear();
      isFirst = true;
    }
    double value1 = double.parse(newValue);
    if (!isFirst) value1 = value1 * 100;
    value =
        NumberFormat.currency(customPattern: '###,###.##').format(value1 / 100);
    return TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  /// Perform formatting of datetime
  ///
  /// Receives [format] as the desired datetime format
  /// [dateString] as the datetime value
  /// Returns formatted datetime value
  static String formatDateTime({
    String format = 'yyyy-MM-dd – kk:mm',
    required String dateString,
  }) {
    DateTime dateTime = DateTime.parse(dateString);
    String formattedDate = DateFormat(format).format(dateTime);
    return formattedDate;
  }

  /// Perform check if an application is installed on the mobile device
  /// Through package name
  /// Used when initiating payment using S Pay Global
  ///
  /// Receives [iOSPackageName] as the iOS package name
  /// [androidPackageName] as the android package name
  /// [data] as the URL string for iOS package name
  /// Returns 'true' if application is installed
  /// Returns 'false' if application is not installed
  static Future<bool> checkAppInstalled({
    required String iOSPackageName,
    required String androidPackageName,
    String data = '',
  }) async {
    try {
      if (Platform.isIOS) {
        Uri iOSUri = Uri.parse('$iOSPackageName?$data');
        bool iosAppInstalled = await canLaunchUrl(iOSUri);
        return iosAppInstalled;
      } else {
        bool? androidAppInstalled =
            await AppCheck().isAppInstalled(androidPackageName);
        return androidAppInstalled;
      }
    } catch (e) {
      print("checkAppInstalled fail: ${e.toString()}");
      return false;
    }
  }

  // return file url based on application documents directory
  static Future<String> getFileUrl(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    return "${directory.path}/$fileName";
  }

  /// Clear cache using GET method when accessing inbox
  ///
  /// Receives [operType] as the operation type
  /// Returns 'true' if calling API is successful
  /// Returns 'false' if calling API is failed
  static Future<bool> clearCache(String operType) async {
    try {
      ApiBaseHelper _apiBaseHelper = ApiBaseHelper();
      var response = await _apiBaseHelper.get(
        'file/delCacheKey',
        queryParameters: {
          'operType': operType,
        },
        requireToken: true,
      );
      print('clearCache inbox API success: $response');
      if (response['status'] == "200") return true;
      return false;
    } catch (e) {
      print('clearCache API fail: ${e.toString()}');
      return false;
      // throw e;
    }
  }

  // https://pic.sioc.sma.gov.my/picture/20240409171742-804329712.jpg
  static String flavorFormatImageUrl(String imageUrl) {
    Flavor flavor = AppConfig.picFlavor;

    if (imageUrl.isNotEmpty) {
      Uri uri = Uri.parse(imageUrl);
      String path = uri.path;
      if (path.isNotEmpty) {
        if (flavor == Flavor.dev) {
          String newDomain = AppConfig().picBaseUrlDev;
          return "$newDomain$path";
        } else if (flavor == Flavor.test) {
          String newDomain = AppConfig().picBaseUrlTest;
          return "$newDomain$path";
        } else if (flavor == Flavor.staging) {
          String newDomain = AppConfig().picBaseUrlStaging;
          return "$newDomain$path";
        } else if (flavor == Flavor.prod) {
          String newDomain = AppConfig().picBaseUrlProduction;
          return "$newDomain$path";
        } else {
          return "";
        }
      } else {
        return "";
      }
    } else {
      return "";
    }
  }
}
