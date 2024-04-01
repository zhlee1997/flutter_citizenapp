import '../utils/api_base_helper.dart';

class AnnouncementServices {
  ApiBaseHelper _apiBaseHelper = ApiBaseHelper();

  /// Get announcement list
  ///
  /// Receives [pageNum] as the number of pagination
  /// [pageSize] as the number of size in a page
  /// [annType] as the announcement type (1. citizen, 2. tourist, 3. major)
  /// [nowTime] as the current datetime
  /// Returns API Response object
  Future<dynamic> queryPageList(
    String pageNum, {
    String pageSize = '20',
    String? annType,
    String? nowTime,
  }) async {
    try {
      var parameters = {
        'pageNum': pageNum,
        'pageSize': pageSize,
        'annStatusPublish': '1'
      };

      if (annType != null) {
        parameters['annType'] = annType;
      }

      if (nowTime != null) {
        parameters['nowTime'] = nowTime;
      }
      var response = await _apiBaseHelper.get(
        'announcement/queryPageList',
        queryParameters: parameters,
        requireToken: false,
      );
      print("queryPageList API success: $response");
      return response;
    } catch (e) {
      print('get announcement page list fail');
      // TODO: Error handling
      // throw e;
      rethrow;
    }
  }

  /// Get announcement detail
  ///
  /// Receives [attId] as the announcement ID
  /// Returns API Response object
  Future<dynamic> queryAnnouncementDetail(String attId) async {
    try {
      var response = await _apiBaseHelper.get(
        'announcement/getById/$attId',
        requireToken: false,
      );
      print("queryAnnouncementDetail API success: $response");
      return response;
    } catch (e) {
      print('get announcement detail fail');
      throw e;
    }
  }
}
