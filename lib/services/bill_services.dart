import 'dart:convert';

import 'package:dio/dio.dart';

import '../utils/api_base_helper.dart';

class BillServices {
  ApiBaseHelper _apiBaseHelper = ApiBaseHelper();

  /// Create payment order using POST method
  ///
  /// Receives [data] as the payment information
  /// Returns API Response object
  Future<dynamic> createBillOrder(Map data) async {
    try {
      var response = await _apiBaseHelper.post(
        'payment/orderForm/createBySelective',
        data: json.encode(data),
      );
      print('createBillOrder API success: $response');
      return response;
    } catch (e) {
      print('createBillOrder error: ${e.toString()}');
      throw e;
    }
  }

  /// Obtain encrypted payment data using POST method
  ///
  /// Receives [data] as the order ID
  /// Returns API Response object
  Future<dynamic> confirmBillOrder(Map<String, dynamic> data) async {
    try {
      var response = await _apiBaseHelper.post(
        'payment/orderForm/create/confirm',
        data: json.encode(data),
      );
      print('confirmBillOrder API success: $response');
      return response;
    } catch (e) {
      print('confirmBillOrder error: ${e.toString()}');
      throw e;
    }
  }

  /// Obtain decrypted payment status after payment using POST method
  ///
  /// Receives [data] as the transaction result which is retrieved from SPay SDK
  /// Returns API Response object
  Future<dynamic> decryptBillData(Map<String, dynamic> data) async {
    try {
      var response = await _apiBaseHelper.post(
        'payment/orderForm/decryptData',
        data: json.encode(data),
      );
      print('decryptBillData API success: $response');
      return response;
    } catch (e) {
      print('decryptBillData error: ${e.toString()}');
      throw e;
    }
  }
}
