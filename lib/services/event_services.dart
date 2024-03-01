import 'dart:convert';

import '../utils/api_base_helper.dart';

class EventServices {
  final ApiBaseHelper _apiBaseHelper = ApiBaseHelper();

  /// Submit new case using POST method
  ///
  /// Receives [parameter] as the case input information
  /// Returns API response object
  Future<dynamic> create(Map parameter) async {
    try {
      var response = await _apiBaseHelper.post(
        // "/eventManual/createBySelective",
        "/emergency",
        data: json.encode(parameter),
      );
      print('createCase success: $response');
      return response;
    } catch (e) {
      print('createCase failed: ${e.toString()}');
      throw e;
    }
  }
}
