import 'dart:convert';

import '../utils/api_base_helper.dart';

class FeedbackServices {
  ApiBaseHelper _apiBaseHelper = ApiBaseHelper();

  Future<dynamic> postFeedback({
    required int rating,
    List<int>? services,
    String? comment,
  }) async {
    Map<String, dynamic> data = {
      'rating': rating,
      'services': services,
      'comment': comment,
    };
    try {
      var response = await _apiBaseHelper.post(
        "feedback",
        data: json.encode(data),
      );
      print("postFeedback success: $response");
      return response;
    } catch (e) {
      print('postFeedback error: ${e.toString()}');
      throw e;
    }
  }
}
