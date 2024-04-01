import 'dart:convert';

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

  /// Get inbox detail
  ///
  /// Receives [id] as the message ID
  /// Returns API response object
  Future<dynamic> getMsgById(String id) async {
    try {
      var response = await _apiBaseHelper.get(
        '/messageRcv/getById/$id',
        requireToken: true,
      );
      print('getMsgById API success: $response');
      return response;
    } catch (e) {
      print('getMsgById fail: ${e.toString()}');
      throw e;
    }
  }

  /// Change message status to read using POST method
  ///
  /// Receives [rcvId] as the message ID
  /// Returns API response object
  Future<dynamic> modifyByIdSelective(String rcvId) async {
    try {
      var response = await _apiBaseHelper.post(
        '/messageRcv/modifyByIdSelective',
        data: json.encode(
          {
            'rcvId': rcvId,
          },
        ),
      );
      print('modifyByIdSelective API success: $response');
      return response;
    } catch (e) {
      print('modifyByIdSelective fail: ${e.toString()}');
      throw e;
    }
  }

  /// Get the number of unread messages
  ///
  /// Return API response object
  Future<dynamic> queryCnt() async {
    try {
      var response = await _apiBaseHelper.get(
        '/messageRcv/queryCnt',
        requireToken: true,
      );
      print('getNumberOfUnreadMessage API success: $response');
      return response;
    } catch (e) {
      print('queryCnt fail: ${e.toString()}');
      throw e;
    }
  }

  /// Delete inbox messages using DELETE method
  ///
  /// Receives [rcvId] as the message ID
  /// Returns API response object
  Future<dynamic> removeById(String rcvId) async {
    try {
      var response = await _apiBaseHelper.delete(
        '/messageRcv/removeById',
        requireToken: true,
        data: json.encode(
          {
            'rcvId': rcvId,
          },
        ),
      );
      print("removeById API success: $response");
      return response;
    } catch (e) {
      print('delete inbox fail: ${e.toString()}');
      throw e;
    }
  }

  /// Delete all inbox messages using DELETE method
  ///
  /// Returns API response object
  Future<dynamic> removeAll() async {
    try {
      var response = await _apiBaseHelper.delete(
        '/messageRcv/removeAll',
        requireToken: true,
      );
      print("removeAll API success: $response");
      return response;
    } catch (e) {
      print('delete all inbox fail: ${e.toString()}');
      throw e;
    }
  }
}
