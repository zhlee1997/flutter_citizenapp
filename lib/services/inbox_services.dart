import '../utils/api_base_helper.dart';

class InboxServices {
  ApiBaseHelper _apiBaseHelper = ApiBaseHelper();

  /// Get list of messages
  ///
  /// Receives [pageNum] as the number of pagination
  /// Returns API response object
  Future<dynamic> queryInboxPageList(String pageNum) async {
    try {
      var response = await _apiBaseHelper.get(
        '/messageRcv/queryPageList',
        queryParameters: {
          'pageNum': pageNum,
          'pageSize': 20,
        },
        requireToken: true,
      );
      print('queryInboxPageList API success: $response');
      return response;
    } catch (e) {
      print('queryInboxPageList fail: ${e.toString()}');
      throw e;
    }
  }
}
