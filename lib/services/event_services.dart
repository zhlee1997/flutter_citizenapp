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
        "/eventManual/createBySelective",
        data: json.encode(parameter),
      );
      print('createCase success: $response');
      return response;
    } catch (e) {
      print('createCase failed: ${e.toString()}');
      throw e;
    }
  }

  /// Upload attachments using POST method
  ///
  /// Receives [parameter] as the file input information
  /// Returns API response object
  Future<dynamic> attachmentCreate(List<Map> parameter) async {
    try {
      var response = await _apiBaseHelper.post(
        "/eventManualAttachment/create",
        data: parameter,
      );
      print('attachmentCreate success $response');
      return response;
    } catch (e) {
      print('attachmentCreate fail: ${e.toString()}');
      throw e;
    }
  }

  /// Get list of reported cases
  ///
  /// Receives [parameter] as the query parameters
  /// Returns API response object
  Future<dynamic> queryEventPageList(
    Map<String, dynamic> parameter,
  ) async {
    try {
      var response = await _apiBaseHelper.get(
        "/eventManual/queryPageList",
        queryParameters: parameter,
        requireToken: true,
      );
      print('queryPageList success: $response');
      return response;
    } catch (e) {
      print('queryPageList fail: ${e.toString()}');
      throw e;
    }
  }

  /// Get details of a reported case
  ///
  /// Receives [id] as the case ID
  /// Returns API response object
  Future<dynamic> getEventById(String id) async {
    try {
      var response = await _apiBaseHelper.get(
        "/eventManual/getById/$id",
        requireToken: true,
      );
      print('getEventById success: $response');
      return response;
    } catch (e) {
      print('getEventById fail: ${e.toString()}');
      throw e;
    }
  }

  /// Get attachments of reported cases
  ///
  /// Receives [id] as the case ID
  /// Returns API response object
  Future<dynamic> attachmentGetById(String id) async {
    try {
      var response = await _apiBaseHelper.get(
        "/eventManualAttachment/queryList",
        queryParameters: {
          'eventId': id,
        },
        requireToken: true,
      );
      print('attachmentGetById success: $response');
      return response;
    } catch (e) {
      print('attachmentGetById fail: ${e.toString()}');
      throw e;
    }
  }

  /// Submit new case using POST method
  ///
  /// Receives [parameter] as the case input information
  /// Returns API response object
  Future<dynamic> queryEmergencyRequestFrequency() async {
    try {
      var response = await _apiBaseHelper.get(
        "/eventManual/queryUrgentEventReportNumber",
        requireToken: true,
      );
      print('queryEmergencyRequestFrequency success: $response');
      return response;
    } catch (e) {
      print('queryEmergencyRequestFrequency failed: ${e.toString()}');
      throw e;
    }
  }
}
