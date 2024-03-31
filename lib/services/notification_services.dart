import 'dart:convert';

import '../utils/api_base_helper.dart';

class NotificationServices {
  ApiBaseHelper _apiBaseHelper = ApiBaseHelper();

  /// Send FCM Token using POST method
  ///
  /// Receives [firebaseToken] as the FCM Token
  /// Returns API response object
  Future<dynamic> saveToken(String firebaseToken) async {
    Map<String, dynamic> data = {
      'firebaseToken': firebaseToken,
    };
    try {
      var response = await _apiBaseHelper.post(
        "member/save/firebase/token",
        data: json.encode(data),
      );
      print('saveToken API success: $response');
      return response;
    } catch (e) {
      print('saveToken error: ${e.toString()}');
      // TODO: Error handling
      // throw e;
      rethrow;
    }
  }

  /// Delete FCM Token
  ///
  /// Returns API response object
  Future<void> deleteToken() async {
    try {
      var response = await _apiBaseHelper.get(
        "member/remove/firebase/token",
        requireToken: true,
      );
      // TODO: Error handling for JDBC issue
      print('deleteToken API success: $response');
      return response;
    } catch (e) {
      print('deleteToken error: ${e.toString()}');
      throw e;
    }
  }
}
