import 'dart:convert';

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
  }) async {
    final storage = new FlutterSecureStorage();
    var siocToken = await storage.read(key: 'siocToken');
    var sarawakToken = await storage.read(key: 'sarawakToken');

    var responseJson;
    var uri = Uri.https(
      _baseUrl,
      "/mobile/api/" + url,
      queryParameters,
    );
    try {
      print("baseurl: ${uri.toString()}");
      final response = await http.get(
        uri,
        headers: {
          'Authorization': siocToken ?? '',
          'sarawakToken': sarawakToken ?? '',
        },
      );

      responseJson = _returnResponse(response);
    } on Exception catch (e) {
      print('getError: $e');
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
    final storage = new FlutterSecureStorage();
    var siocToken = await storage.read(key: 'siocToken');
    var sarawakToken = await storage.read(key: 'sarawakToken');

    var responseJson;
    // TODO
    // var uri = Uri.https(
    //   _baseUrl,
    //   "/mobile/api/" + url,
    // );
    var uri = Uri.http(
      "192.168.50.250:3000",
      url,
    );

    try {
      print("baseurl: ${uri.toString()}");
      final response = await http.post(uri,
          headers: {
            'Authorization': siocToken ?? '',
            'sarawakToken': sarawakToken ?? '',
          },
          body: data
          // onSendProgress: onSendProgress,
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

  dynamic _returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        var responseJson = json.decode(response.body.toString());
        return responseJson;
      // TODO: temp added for JSON Server
      case 201:
        var responseJson = json.decode(response.body.toString());
        return response.statusCode.toString();
      case 400:
        throw BadRequestException(response.body.toString());
      case 401:
      case 403:
        throw UnauthorisedException(response.body.toString());
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
