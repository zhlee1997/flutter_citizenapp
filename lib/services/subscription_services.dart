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
      if (response!.statusCode == 200) return response;
      return null;
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
      if (response!.statusCode == 200) return response;
      return null;
    } catch (e) {
      print('confirmSubscriptionOrder error: ${e.toString()}');
      throw e;
    }
  }
}
