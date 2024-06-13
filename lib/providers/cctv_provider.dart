import 'package:flutter/material.dart';

import '../models/camera_subscription_model.dart';
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

  List<CCTVOtherModel> _nearbyOtherCameraList = [];
  List<CCTVOtherModel> get nearbyOtherCameraList => _nearbyOtherCameraList;

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
        "thridDeviceId": data.deviceCode,
        "urlType": AppConstant
            .urlType, // video type：1.rtsp、2.hls、3.rtmp、4.flv-http、5.dash
      };
      var response = await CCTVServices().getCctvDetail(map);
      if (response['status'] == 200) {
        _cctvModelDetail = CCTVModelDetail(
          id: data.deviceCode,
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

  /// Obtain 5 nearby other CCTVs
  Future<List<CCTVOtherModel>> queryNearbyDevicesListProvider(
      Map<String, dynamic> data) async {
    try {
      // everytime clear out the old list
      _nearbyOtherCameraList = [];
      var response = await CCTVServices().queryNearbyDevicesList(data);
      if (response['status'] == 200) {
        if (response['obj'].length > 0) {
          var list = response['obj'] as List;
          _nearbyOtherCameraList =
              list.map((e) => CCTVOtherModel.fromJson(e)).toList();
        }
      }
    } catch (e) {
      print('queryNearbyDevicesListProvider fail: ${e.toString()}');
    }
    notifyListeners();
    return _nearbyOtherCameraList;
  }
}
