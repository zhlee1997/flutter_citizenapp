import 'dart:convert';

import '../utils/api_base_helper.dart';

class SubscriptionServices {
  final ApiBaseHelper _apiBaseHelper = ApiBaseHelper();

  // TODO: NEW API: queryPackageAndSubscriptionEnable
  Future<dynamic> queryPackageAndSubscriptionEnable() async {
    try {
      var response = await _apiBaseHelper.get(
        'member/memberSubscribePackage/queryList',
        requireToken: false,
      );
      print("queryPackageAndSubscriptionEnable API success: $response");
      return response;
    } catch (e) {
      print('queryPackageAndSubscriptionEnable error: ${e.toString()}');
      // throw e;
      rethrow;
    }
  }

  // NEW API: querySubscriptionWhitelisted
  Future<dynamic> querySubscriptionWhitelisted({
    required String subscribeId,
    required String memberId,
  }) async {
    try {
      Map<String, dynamic> queryParameters = {
        "subscribeId": subscribeId,
        // "memberId": memberId,
      };
      var response = await _apiBaseHelper.get(
        'member/subscribePackageMemberRlt/queryList',
        queryParameters: queryParameters,
        requireToken: true,
      );
      print("querySubscriptionWhitelisted API success: $response");
      return response;
    } catch (e) {
      print('querySubscriptionWhitelisted error: ${e.toString()}');
      // throw e;
      rethrow;
    }
  }

  // check subscription package option
  // NEW API: querySubscriptionPackageOption
  Future<dynamic> querySubscriptionPackageOption({
    required String subscribeId,
    required String memberId,
  }) async {
    Map<String, dynamic> queryParameters = {
      "subscribeId": subscribeId,
      // "memberId": memberId,
    };
    try {
      var response = await _apiBaseHelper.get(
        'member/queryList',
        queryParameters: queryParameters,
        requireToken: true,
      );
      print("querySubscriptionPackageOption API success: $response");
      return response;
    } catch (e) {
      print('querySubscriptionPackageOption error: ${e.toString()}');
      // TODO: Error handling
      // throw e;
      rethrow;
    }
  }

  /// Create payment order using POST method
  ///
  /// Receives [data] as the payment information
  /// Returns API Response object
  Future<dynamic> createSubcriptionOrder(Map data) async {
    try {
      var response = await _apiBaseHelper.post(
        'payment/orderForm/createBySelective',
        data: json.encode(data),
      );
      print('createSubcriptionOrder API success: $response');
      return response;
    } catch (e) {
      print('createSubcriptionOrder error: ${e.toString()}');
      throw e;
    }
  }

  /// Obtain encrypted payment data using POST method
  ///
  /// Receives [data] as the order ID
  /// Returns API Response object
  Future<dynamic> confirmSubscriptionOrder(Map<String, dynamic> data) async {
    try {
      var response = await _apiBaseHelper.post(
        'payment/orderForm/create/confirm',
        data: json.encode(data),
      );
      print('confirmSubscriptionOrder API success: $response');
      return response;
    } catch (e) {
      print('confirmSubscriptionOrder error: ${e.toString()}');
      throw e;
    }
  }

  /// Obtain decrypted payment status after payment using POST method
  ///
  /// Receives [data] as the transaction result which is retrieved from SPay SDK
  /// Returns API Response object
  Future<dynamic> decryptData(Map<String, dynamic> data) async {
    try {
      var response = await _apiBaseHelper.post(
        'payment/orderForm/decryptData',
        data: json.encode(data),
      );

      if (response["status"] == "500") {
        throw Exception("decryptData error: ${response["message"]}");
      }

      print('decryptData API success: $response');
      return response;
    } catch (e) {
      print('decryptData error: ${e.toString()}');
      throw e;
    }
  }
}
