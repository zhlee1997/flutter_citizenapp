import '../utils/api_base_helper.dart';

class TrasactionServices {
  final ApiBaseHelper _apiBaseHelper = ApiBaseHelper();

  /// Get transaction list
  ///
  /// Receives [data] as the query parameters
  /// Returns API Response object
  Future<dynamic> queryTransaction(Map<String, dynamic> data) async {
    try {
      var response = await _apiBaseHelper.get(
        'payment/orderForm/queryList',
        queryParameters: data,
        requireToken: true,
      );
      print("queryTransaction API success: $response");
      return response;
    } catch (e) {
      print('queryTransaction error: ${e.toString()}');
      throw e;
    }
  }
}
