import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import './app_exception.dart';
import '../config/app_config.dart';

class ApiBaseHelper {
  final String _baseUrl = AppConfig().baseUrl;

  Future<dynamic> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    required bool requireToken,
  }) async {
    final dio = Dio();
    final storage = new FlutterSecureStorage();
    var siocToken = await storage.read(key: 'siocToken');
    var sarawakToken = await storage.read(key: 'sarawakToken');
    print("Authorization header: $siocToken");

    var responseJson;

    try {
      print("getURL: $_baseUrl$url");
      print("getParameters: $queryParameters");
      final response = await dio.get(
        "$_baseUrl$url",
        options: requireToken
            ? Options(
                headers: {
                  'Authorization': siocToken ?? '',
                  'sarawakToken': sarawakToken ?? '',
                },
              )
            : null,
        queryParameters: queryParameters,
      );
      responseJson = _returnResponse(response);
    } on Exception catch (e) {
      print('getError: ${e.toString()}');
      // make it explicit that this function can throw exceptions
      rethrow;
    }
    // _checkResponse(responseJson);
    return responseJson;
  }

  Future<dynamic> post(
    String url, {
    dynamic data,
    Function(int, int)? onSendProgress,
  }) async {
    final dio = Dio();
    final storage = new FlutterSecureStorage();
    var siocToken = await storage.read(key: 'siocToken');
    var sarawakToken = await storage.read(key: 'sarawakToken');

    var responseJson;

    try {
      print("postURL: $_baseUrl$url");
      print("postData: $data");
      final response = await dio.post(
        "$_baseUrl$url",
        options: Options(
          headers: {
            'Authorization': siocToken ?? '',
            'sarawakToken': sarawakToken ?? '',
          },
        ),
        data: data,
      );
      responseJson = _returnResponse(response);
    } catch (e) {
      print('postError: ${e.toString()}');
      // make it explicit that this function can throw exceptions
      rethrow;
    }
    // _checkResponse(responseJson);
    return responseJson;
  }

  dynamic _returnResponse(Response response) {
    switch (response.statusCode) {
      case 200:
        var responseJson = response.data;
        return responseJson;
      // TODO: temp added for JSON Server
      // case 201:
      //   var responseJson = json.decode(response.data.toString());
      // return response.statusCode.toString();
      case 400:
        throw BadRequestException(response.data.toString());
      case 401:
      case 403:
        throw UnauthorisedException(response.data.toString());
      case 500:
      default:
        throw FetchDataException(
            'Error occured while Communication with Server with StatusCode : ${response.statusCode}');
    }
  }

  void _checkResponse(http.Response response) {
    var responseJson = json.decode(response.body.toString());
    if (responseJson['status'] == 40101 || responseJson['status'] == 40301) {
      _deleteLocalData();
    }
  }

  Future<void> _deleteLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('expire', -1);
  }
}
