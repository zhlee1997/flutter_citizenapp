import 'dart:convert';

import '../utils/api_base_helper.dart';

class AuthServices {
  ApiBaseHelper _apiBaseHelper = ApiBaseHelper();

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
    try {
      var response = await _apiBaseHelper.post(
        'login/invalid/token',
        data: json.encode(map),
      );
      print('signOut API success: $response');
      return response;
    } catch (e) {
      print('signOut error: ${e.toString()}');
      throw e;
    }
  }
}
