import 'dart:io';

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:flutter/services.dart';
// import 'package:dio/dio.dart';

// import '../utils/api_helper.dart';

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
  // static String formatDateTime({
  //   String format = 'yyyy-MM-dd – kk:mm',
  //   required String dateString,
  // }) {
  //   DateTime dateTime = DateTime.parse(dateString);
  //   String formattedDate = DateFormat(format).format(dateTime);
  //   return formattedDate;
  // }

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
            await InstalledApps.isAppInstalled(androidPackageName);
        return androidAppInstalled ?? false;
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

  // save the mp4 video from asset to application document directory
  // static Future<void> saveAssetVideoToFile() async {
  //   var content = await rootBundle.load("assets/video/sioc.mp4");
  //   final directory = await getApplicationDocumentsDirectory();
  //   var file = File("${directory.path}/sioc.mp4");
  //   file.writeAsBytesSync(content.buffer.asUint8List());
  // }

  /// Get adaptive text size for icons in home screen
  /// According to device sreeen size
  ///
  /// Receives [t] as the text size
  /// Returns adaptive text size
  // static double getAdaptiveTextSize(
  //   BuildContext context,
  //   dynamic value,
  // ) {
  //   // 720 is medium screen height
  //   return (value / 720) * MediaQuery.of(context).size.height;
  // }

  // static int getAdaptiveIconSize(
  //   BuildContext context,
  //   dynamic value,
  // ) {
  //   // 720 is medium screen height
  //   double val = (value / 720) * MediaQuery.of(context).size.height;
  //   return val.round();
  // }

  /// Clear cache using GET method when accessing inbox
  ///
  /// Receives [operType] as the operation type
  /// Returns 'true' if calling API is successful
  /// Returns 'false' if calling API is failed
  // static Future<bool> clearCache(String operType) async {
  //   try {
  //     Response? response;
  //     ApiBaseHelper _apiBaseHelper = ApiBaseHelper();

  //     response = await _apiBaseHelper.get(
  //       '/file/delCacheKey',
  //       queryParameters: {
  //         'operType': operType,
  //       },
  //     );
  //     print('clearCache $response');
  //     if (response!.data['status'] == "200") return true;
  //     return false;
  //   } catch (e) {
  //     print('clearCache fail');
  //     throw e;
  //   }
  // }
}
