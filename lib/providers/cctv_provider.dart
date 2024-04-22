import 'package:flutter/material.dart';
import 'package:flutter_citizenapp/models/camera_subscription_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/cctv_model.dart';
import '../services/cctv_services.dart';
import '../utils/app_constant.dart';

class CCTVProvider with ChangeNotifier {
  late List<CCTVModel> _cctvModel;
  List<CCTVModel> get cctvModel => _cctvModel;

  CCTVModelDetail? _cctvModelDetail;
  CCTVModelDetail? get cctvModelDetail => _cctvModelDetail;

  late String _imageUrl;
  String get imageUrl => _imageUrl;

  late List<Map<String, dynamic>> _nearCameraList;
  List<Map<String, dynamic>> get nearCameraList => _nearCameraList;

  /// Get the cctv coordinates when rendering Google Map
  /// Using getCctvCoordinates API
  ///
  /// Return 'true' if getCctvCoordinates API is successful.
  /// Return 'false' if getCctvCoordinates API is failed.
  Future<bool> getCctvCoordinatesProvider() async {
    try {
      Map<String, dynamic> data = {"channel": "02"};
      var response = await CCTVServices().getCctvCoordinates(data);
      if (response['status'] == 200) {
        var cctvData = response['obj'] as List;
        _cctvModel = cctvData.map((e) => CCTVModel.fromJson(e)).toList();
        return true;
      }
    } catch (e) {
      print("getCctvCoordinatesProvider error: ${e.toString()}");
      // throw e;
    }
    return false;
  }

  /// Get the CCTV detail and live URL when selecting on a CCTV
  /// Using getCctvDetail API
  ///
  /// Receives [data] as the CCTV information
  Future<void> getCctvDetailProvider(CameraSubscriptionModel data) async {
    try {
      Map<String, dynamic> map = {
        "channel": data.channel,
        "thridDeviceId": data.id,
        "urlType": AppConstant
            .urlType, // video type：1.rtsp、2.hls、3.rtmp、4.flv-http、5.dash
      };
      var response = await CCTVServices().getCctvDetail(map);
      if (response['status'] == 200) {
        _cctvModelDetail = CCTVModelDetail(
          id: data.id,
          name: data.deviceName,
          location: data.location,
          image: '',
          updateTime: '',
          liveUrl: response['obj']['liveUrl'],
        );
      }
    } catch (e) {
      throw e;
    }
  }

  /// Get the CCTV capture image when displaying CCTV Detail
  /// Using getCameraShortCutUrl API
  ///
  /// Receives [data] as the CCTV information
  /// Return 'true' if getCameraShortCutUrl API is successful.
  /// Return 'false' if getCameraShortCutUrl API is failed.
  Future<void> getCameraShortCutUrlProvider(Map<String, dynamic> data) async {
    try {
      var response = await CCTVServices().getCameraShortCutUrl(data);
      if (response['status'] == 200) {
        _imageUrl = response['obj']['picUrl'] ?? '';
      }
    } catch (e) {
      print('getCameraShortCutUrlProvider failed');
      throw e;
    }
  }

  // Provider - obtain 5 nearby CCTV
  Future<void> queryNearbyDevicesListProvider(Map<String, dynamic> data) async {
    try {
      var response = await CCTVServices().queryNearbyDevicesList(data);
      if (response['status'] == 200) {
        _nearCameraList = [];
        if (response['obj'].length > 0) {
          response['obj'].forEach((e) {
            Map<String, dynamic> item = {
              "cctvId": e['thridDeviceId'],
              "coodinates": LatLng(
                  double.parse(e['latitude']), double.parse(e['longitude'])),
              "name": e['thirdDeviceName'] ?? "No Device Name",
              "address": e['location'] ?? "No Address",
              "imageURL": ''
            };
            _nearCameraList.add(item);
          });
        }
      }
    } catch (e) {
      print('queryNearbyDevicesListProvider fail');
    }
  }

  // return list of CCTV capture image for nearby CCTV
  // Future getImages(List<Map<String, dynamic>> cameraList) {
  //   int counter = 0;
  //   int sum = cameraList.length;
  //   if (counter == sum) {
  //     return Future(() {
  //       return [];
  //     });
  //   }

  //   List<Future> list = [];
  //   cameraList.forEach((e) {
  //     list.add(getImageUrl(e['cctvId']));
  //   });
  //   Future future = Future.wait(list);
  //   return future;
  // }
}
