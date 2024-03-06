import 'dart:convert';

import '../utils/api_base_helper.dart';

class SubscriptionServices {
  final ApiBaseHelper _apiBaseHelper = ApiBaseHelper();

  // TODO: NEW API: querySubcriptionPackage
  Future<dynamic> querySubscriptionPackage() async {
    try {
      var response =
          await _apiBaseHelper.get('/subscription/querySubscriptionPackage');
      print("querySubscriptionPackage API success: $response");
      return response;
    } catch (e) {
      print('querySubscriptionPackage error: ${e.toString()}');
      // TODO: Error handling
      // throw e;
      rethrow;
    }
  }

  // TODO: NEW API: querySubscriptionStatus
  Future<dynamic> querySubscriptionStatus() async {
    try {
      var response =
          await _apiBaseHelper.get('/subscription/querySubscriptionStatus');
      print("querySubscriptionStatus API success: $response");
      return response;
    } catch (e) {
      print('querySubscriptionStatus error: ${e.toString()}');
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
      print('decryptData API success: $response');
      return response;
    } catch (e) {
      print('decryptData error: ${e.toString()}');
      throw e;
    }
  }
}
