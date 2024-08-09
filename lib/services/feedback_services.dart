import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/api_base_helper.dart';

class FeedbackServices {
  ApiBaseHelper _apiBaseHelper = ApiBaseHelper();

  Future<dynamic> postFeedback({
    required int rating,
    required List<int> services,
    String? comment,
    bool isLogin = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    var userId = prefs.getString('userId');

    Map<String, dynamic> data = isLogin
        ? {
            "starLevel": rating,
            "talikhidmat": services.contains(0) ? 1 : 0,
            "emergencyButton": services.contains(1) ? 1 : 0,
            "trafficImages": services.contains(2) ? 1 : 0,
            "tourismInformation": services.contains(3) ? 1 : 0,
            "liveVideo": services.contains(4) ? 1 : 0,
            "billPayment": services.contains(5) ? 1 : 0,
            "busSchedule": services.contains(6) ? 1 : 0,
            "others": services.contains(7) ? 1 : 0,
            "marks": comment ?? "",
            // MEMBER ID (OPTIONAL)
            "memberId": userId,
          }
        : {
            "starLevel": rating,
            "talikhidmat": services.contains(0) ? 1 : 0,
            "emergencyButton": services.contains(1) ? 1 : 0,
            "trafficImages": services.contains(2) ? 1 : 0,
            "tourismInformation": services.contains(3) ? 1 : 0,
            "liveVideo": services.contains(4) ? 1 : 0,
            "billPayment": services.contains(5) ? 1 : 0,
            "busSchedule": services.contains(6) ? 1 : 0,
            "others": services.contains(7) ? 1 : 0,
            "marks": comment ?? "",
          };
    try {
      var response = await _apiBaseHelper.post(
        "member/memberFeedback/createBySelective",
        data: json.encode(data),
      );
      print("postFeedback success: $response");
      return response;
    } catch (e) {
      print('postFeedback error: ${e.toString()}');
      throw e;
    }
  }

  Future<dynamic> queryUserFeedbacks(
    String pageNum, {
    String pageSize = '20',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    // var userId = prefs.getString('userId');
    var queryParameters = {
      'pageNum': pageNum,
      'pageSize': pageSize,
      // "memberId": userId,
    };
    try {
      var response = await _apiBaseHelper.get(
        "member/memberFeedback/queryPageList",
        queryParameters: queryParameters,
        requireToken: true,
      );
      print("queryUserFeedbacks success: $response");
      return response;
    } catch (e) {
      print('queryUserFeedbacks error: ${e.toString()}');
      throw e;
    }
  }
}
