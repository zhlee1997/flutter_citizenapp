import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../utils/api_base_helper.dart';
import "../../services/notification_services.dart";

class AuthServices {
  ApiBaseHelper _apiBaseHelper = ApiBaseHelper();
  NotificationServices _notificationServices = NotificationServices();

  /// Get user information
  ///
  /// Receives [memberId] as the user ID
  /// Returns API Response object
  Future<dynamic> queryUserInfo(String memberId) async {
    try {
      var response = await _apiBaseHelper.get(
        'member/getById',
        queryParameters: {
          "memberId": memberId,
        },
        requireToken: true,
      );
      print("queryUserInfo API success: $response");
      return response;
    } catch (e) {
      print(e.toString());
      print('queryUserInfo error');
      throw e;
    }
  }

  /// Sign out using POST method
  ///
  /// Receives [sarawakToken] as the token received from Sarawak ID
  /// [siocToken] as the token received from SIOC Backend
  /// Returns API Response object
  Future<dynamic> signOut({
    required String? sarawakToken,
    required String? siocToken,
  }) async {
    Map<String, dynamic> map = {
      'sarawakToken': sarawakToken,
      'token': siocToken,
      'loginMode': '1',
    };
    var response;
    try {
      response = await _apiBaseHelper.post(
        'login/invalid/token',
        data: json.encode(map),
      );
      print('signOut API success: $response');
    } catch (e) {
      print('signOut error: ${e.toString()}');
      throw e;
    }
    if (response["status"] == "200") {
      // DELETE FCM TOKEN IF LOGOUT SUCCESS
      await _notificationServices.deleteToken();
    }
    return response;
  }

  /// Get new refresh token when app is opened
  ///
  /// Receives [sarawakToken] as the token received from Sarawak ID
  /// [siocToken] as the token received from SIOC Backend
  /// Returns API Response object
  Future<dynamic> refreshToken({
    required String? sarawakToken,
    required String? siocToken,
  }) async {
    final storage = new FlutterSecureStorage();
    Map<String, dynamic> map = {
      'sarawakToken': sarawakToken,
      'token': siocToken,
      'loginMode': '1',
    };

    try {
      var response = await _apiBaseHelper.post(
        "login/refresh/token",
        data: json.encode(map),
      );

      if (response['status'] == '200') {
        await storage.write(
          key: 'siocToken',
          value: response['data']['siocToken'],
        );
        await storage.write(
          key: 'sarawakToken',
          value: response['data']['sarawakToken'],
        );
      }
      print('refreshToken API success: $response');
      return response;
    } catch (e) {
      print('refreshToken error: ${e.toString()}');
      throw e;
    }
  }

  /// Get refresh token & latest profile information
  ///
  /// Receives [accessToken] as the access token
  /// Returns API Response object
  Future<dynamic> updateProfileInfo({
    String? sarawakToken,
    required String memberId,
    required String sarawakId,
    required String ic,
  }) async {
    if (sarawakToken != null) {
      // when no IC -> foreigner,
      // pass sarawakId only for eKYC API to get photos
      Map<String, dynamic> body = ic.isEmpty
          ? {
              'accessToken': sarawakToken,
              'memberId': memberId,
              'sarawakId': sarawakId,
            }
          : {
              'accessToken': sarawakToken,
              'memberId': memberId,
              'sarawakId': sarawakId,
              'ic': ic,
            };
      try {
        var response = await _apiBaseHelper.post(
          'member/modifyById',
          data: body,
        );
        print('updateProfileInfo API success: $response');
        return response;
      } catch (e) {
        print('updateProfileInfo error: ${e.toString()}');
        throw e;
      }
    }
  }
}
