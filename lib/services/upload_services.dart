import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../utils/api_base_helper.dart';

class UploadServices {
  ApiBaseHelper _apiBaseHelper = ApiBaseHelper();

  /// Upload attachments using POST method
  /// In FormData
  ///
  /// Receives [file] as the encoded file information
  /// [type] as the file type
  /// [fileName] as the file name
  /// Returns API response object
  Future<dynamic> uploadFile(
    Uint8List? file,
    String type,
    String fileName,
  ) async {
    try {
      if (file != null) {
        FormData formData = FormData.fromMap({
          "file": MultipartFile.fromBytes(
            file,
            filename: fileName,
            contentType: MediaType('image', type),
          )
        });

        var response = await _apiBaseHelper.post(
          "/file/uploadFile",
          data: formData,
        );
        print(response.statusCode);
        return response;
      }
    } catch (e) {
      print('uploadFile failed: ${e.toString()}');
      throw e;
    }
  }

  /// Upload attachments using POST method
  /// In FormData
  ///
  /// Receives [file] as the encoded file information
  /// [type] as the file type
  /// [fileName] as the file name
  /// Returns API response object
  Future<dynamic> uploadAudioFile(
    Uint8List? file,
    String type,
    String fileName,
  ) async {
    try {
      if (file != null) {
        // FormData formData = new FormData.fromMap({
        //   "file": MultipartFile.fromBytes(
        //     file,
        //     filename: fileName,
        //     contentType: MediaType('image', type),
        //   )
        // });
        var request = http.MultipartRequest(
            'POST', Uri.parse('https://example.com/upload'));
        request.files.add(http.MultipartFile.fromBytes(
          "file",
          file,
          filename: fileName,
          contentType: MediaType('audio', type),
        ));

        var response = await request.send();
        print(response.statusCode);
        return response;
      }
    } catch (e) {
      print('uploadFile failed: ${e.toString()}');
      throw e;
    }
  }
}
