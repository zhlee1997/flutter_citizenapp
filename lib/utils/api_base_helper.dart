import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

import './app_exception.dart';
import '../config/app_config.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

class ApiBaseHelper {
  final String _baseUrl = AppConfig.baseURL;
  final cancelToken = CancelToken();

  Future<dynamic> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    required bool requireToken,
  }) async {
    final dio = Dio();
    const storage = FlutterSecureStorage();
    var siocToken = await storage.read(key: 'siocToken');
    var sarawakToken = await storage.read(key: 'sarawakToken');
    logger.d("Authorization header: $siocToken");

    dynamic responseJson;

    try {
      logger.d("getURL: $_baseUrl$url");
      logger.d("getParameters: $queryParameters");
      final response = await dio.get(
        "$_baseUrl$url",
        queryParameters: queryParameters,
        options: requireToken
            ? Options(
                receiveTimeout: const Duration(seconds: 15),
                sendTimeout: const Duration(seconds: 10),
                headers: {
                  'Authorization': siocToken ?? '',
                  'sarawakToken': sarawakToken ?? '',
                },
                contentType: Headers.jsonContentType,
              )
            : Options(
                receiveTimeout: const Duration(seconds: 15),
                sendTimeout: const Duration(seconds: 10),
                contentType: Headers.jsonContentType,
              ),
      );
      responseJson = _returnResponse(response);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.sendTimeout) {
        // Handle send timeout
        logger.d("Send Timeout Error: $e");
      } else if (e.type == DioExceptionType.receiveTimeout) {
        // Handle receive timeout
        logger.d("Receive Timeout Error: $e");
      } else {
        // Handle other errors
        logger.d("getError: ${e.toString()}");
      }
      rethrow;
    }
    return responseJson;
  }

  Future<dynamic> getThirdParty(
    String url, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final dio = Dio();
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      },
    );

    dynamic responseJson;

    try {
      logger.d("getURLThirdParty: $url");
      logger.d("getParametersThirdParty: $queryParameters");
      final response = await dio.get(
        url,
        queryParameters: queryParameters,
        options: Options(
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 10),
        ),
      );
      responseJson = _returnResponse(response);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.sendTimeout) {
        // Handle send timeout
        logger.d("Send Timeout Error: $e");
      } else if (e.type == DioExceptionType.receiveTimeout) {
        // Handle receive timeout
        logger.d("Receive Timeout Error: $e");
      } else {
        // Handle other errors
        logger.d("getThirdPartyError: ${e.toString()}");
      }
      rethrow;
    }
    return responseJson;
  }

  Future<dynamic> post(
    String url, {
    dynamic data,
    Function(int, int)? onSendProgress,
    CancelToken? cancelToken,
    bool domainFlag = false,
    int domainFlagValue = 0,
  }) async {
    final dio = Dio();
    const storage = FlutterSecureStorage();
    var siocToken = await storage.read(key: 'siocToken');
    var sarawakToken = await storage.read(key: 'sarawakToken');
    logger.d("Authorization header: $siocToken");

    dynamic responseJson;

    try {
      logger.d("postURL: $_baseUrl$url");
      logger.d("postData: $data");
      final response = await dio.post(
        "$_baseUrl$url",
        data: data,
        cancelToken: cancelToken,
        options: Options(
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 10),
          contentType: Headers.jsonContentType,
          headers: domainFlag
              ? {
                  'Authorization': siocToken ?? '',
                  'sarawakToken': sarawakToken ?? '',
                  'Domain-Flag': domainFlagValue,
                }
              : {
                  'Authorization': siocToken ?? '',
                  'sarawakToken': sarawakToken ?? '',
                },
        ),
      );

      responseJson = _returnResponse(response);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.sendTimeout) {
        // Handle send timeout
        logger.d("Send Timeout Error: $e");
      } else if (e.type == DioExceptionType.receiveTimeout) {
        // Handle receive timeout
        logger.d("Receive Timeout Error: $e");
      } else if (CancelToken.isCancel(e)) {
        logger.e('Request canceled: ${e.message}');
      } else {
        // Handle other errors
        logger.d("postError: ${e.toString()}");
      }
      rethrow;
    }
    return responseJson;
  }

  Future<dynamic> delete(
    String url, {
    dynamic data,
    required bool requireToken,
    Function(int, int)? onSendProgress,
  }) async {
    final dio = Dio();
    const storage = FlutterSecureStorage();
    var siocToken = await storage.read(key: 'siocToken');
    var sarawakToken = await storage.read(key: 'sarawakToken');

    dynamic responseJson;

    try {
      logger.d("deleteURL: $_baseUrl$url");
      logger.d("deleteData: $data");
      final response = await dio.delete(
        "$_baseUrl$url",
        data: data,
        options: requireToken
            ? Options(
                receiveTimeout: const Duration(seconds: 15),
                sendTimeout: const Duration(seconds: 10),
                contentType: Headers.jsonContentType,
                headers: {
                  'Authorization': siocToken ?? '',
                  'sarawakToken': sarawakToken ?? '',
                },
              )
            : null,
      );
      responseJson = _returnResponse(response);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.sendTimeout) {
        // Handle send timeout
        print("Send Timeout Error: $e");
      } else if (e.type == DioExceptionType.receiveTimeout) {
        // Handle receive timeout
        print("Receive Timeout Error: $e");
      } else {
        // Handle other errors
        print('deleteError: ${e.toString()}');
      }
      rethrow;
    }
    return responseJson;
  }

  dynamic _returnResponse(Response response) {
    switch (response.statusCode) {
      case 200:
        var responseJson = response.data;
        return responseJson;
      case 400:
        throw BadRequestException(response.data.toString());
      case 401:
      case 403:
        throw UnauthorisedException(response.data.toString());
      case 40101:
      case 40301:
        _deleteLocalData();
      case 500:
      default:
        throw FetchDataException(
            'Error occured while Communication with Server with StatusCode : ${response.statusCode}');
    }
  }

  Future<void> _deleteLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('expire', -1);
  }
}
