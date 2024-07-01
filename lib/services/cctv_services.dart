import 'dart:convert';

import '../utils/api_base_helper.dart';
import '../config/app_config.dart';

class CCTVServices {
  final ApiBaseHelper _apiBaseHelper = ApiBaseHelper();

  /// Obtain list of cctv coordinates using POST method
  ///
  /// Receives [data] as the query parameters
  /// Returns API response object
  Future<dynamic> getCctvCoordinates(Map<String, dynamic> data) async {
    try {
      var response = await _apiBaseHelper.post(
        'vms/getCameraList',
        data: json.encode(data),
      );
      print('getCctvCoordinates API success: $response');
      return response;
    } catch (e) {
      print('getCctvCoordinates fail: ${e.toString()}');
      throw e;
    }
  }

  /// Obtain cctv live url using POST method
  ///
  /// Receives [data] as the CCTV details
  /// Returns API response object
  Future<dynamic> getCctvDetail(Map<String, dynamic> data) async {
    try {
      var response = await _apiBaseHelper.post(
        'vms/getCameraLiveUrl',
        data: json.encode(data),
      );
      print('getCctvDetail success: $response');
      return response;
    } catch (e) {
      print('getCctvDetail fail: ${e.toString()}');
      throw e;
    }
  }

  /// NEW: Obtain cctv live rtsp url using POST method
  ///
  /// Receives [data] as the CCTV details (video type 1 = rtsp)
  /// Returns API response object
  Future<dynamic> getCctvRTSPUrl(Map<String, dynamic> data) async {
    try {
      var response = await _apiBaseHelper.post(
        'vms/getCameraLiveUrlForRtsp',
        data: json.encode(data),
        domainFlag: true,
        domainFlagValue: 0,
      );
      print('getCctvRTSPUrl success: $response');
      return response;
    } catch (e) {
      print('getCctvRTSPUrl fail: ${e.toString()}');
      throw e;
    }
  }

  /// Obtain cctv capture image using POST method
  ///
  /// Receives [data] as the CCTV details
  /// Returns API response object
  Future<dynamic> getCameraShortCutUrl(Map<String, dynamic> data) async {
    try {
      var response = await _apiBaseHelper.post(
        'vms/getCameraShortCutUrl',
        data: json.encode(data),
      );
      print('getCameraShortCutUrl success: $response');
      return response;
    } catch (e) {
      print('getCameraShortCutUrl fail: ${e.toString()}');
      throw e;
    }
  }

  // API - obtain nearby 5 cctv
  Future<dynamic> queryNearbyDevicesList(Map<String, dynamic> data) async {
    try {
      var response = await _apiBaseHelper.post(
        'vms/getNearbyDevicesList',
        data: json.encode(data),
      );
      print('queryNearbyDevicesList success: $response');
      return response;
    } catch (e) {
      print('queryNearbyDevicesList fail: ${e.toString()}');
      throw e;
    }
  }

  /// Obtain cctv live url using POST method
  ///
  /// Receives [data] as the CCTV details
  /// Returns API response object
  Future<dynamic> getLinkingVisionLogin(Map<String, dynamic> data) async {
    try {
      var response = await _apiBaseHelper.getThirdParty(
        AppConfig().isProductionInternal
            ? 'https://10.16.24.144:18445/api/v1/Login'
            : 'https://video.sioc.sma.gov.my:18445/api/v1/Login',
        queryParameters: data,
      );
      print('getLinkingVisionLogin success: $response');
      return response;
    } catch (e) {
      print('getLinkingVisionLogin fail: ${e.toString()}');
      throw e;
    }
  }
}
