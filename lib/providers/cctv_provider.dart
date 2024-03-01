import 'package:flutter/material.dart';

import '../models/cctv_model.dart';

class CCTVProvider with ChangeNotifier {
  late List<CCTVModel> _cctvModel;
  List<CCTVModel> get cctvModel => _cctvModel;

  CCTVModelDetail? _cctvModelDetail;
  CCTVModelDetail? get cctvModelDetail => _cctvModelDetail;

  late String _imageUrl;
  String get imageUrl => _imageUrl;

  /// Get the cctv coordinates when rendering Google Map
  /// Using getCctvCoordinates API
  ///
  /// Return 'true' if getCctvCoordinates API is successful.
  /// Return 'false' if getCctvCoordinates API is failed.
  // Future<bool> getCctvCoordinatesProvider() async {
  //   try {
  //     Map<String, dynamic> data = {"channel": "02"};
  //     _response = await CctvService().getCctvCoordinates(data);
  //     if (_response!.data['status'] == 200) {
  //       var cctvData = _response!.data['obj'] as List;
  //       _cctvCoordinates =
  //           cctvData.map((e) => CctvCoordinate.fromJson(e)).toList();
  //       return true;
  //     }
  //     return false;
  //   } catch (e) {
  //     throw e;
  //   }
  // }

  /// Get the CCTV detail and live URL when selecting on a CCTV
  /// Using getCctvDetail API
  ///
  /// Receives [data] as the CCTV information
  // Future<void> getCctvDetailProvider(CctvCoordinate data) async {
  //   try {
  //     Map<String, dynamic> map = {
  //       "channel": data.channel,
  //       "thridDeviceId": data.cctvId,
  //       "urlType": AppConstant
  //           .urlType, //video type：1.rtsp、2.hls、3.rtmp、4.flv-http、5.dash
  //     };
  //     _response = await CctvService().getCctvDetail(map);
  //     if (_response!.data['status'] == 200) {
  //       _cctvDetail = CctvDetail(
  //         id: data.cctvId,
  //         name: data.deviceName,
  //         location: data.location,
  //         image: '',
  //         updateTime: '',
  //         liveUrl: _response!.data['obj']['liveUrl'],
  //       );
  //       // _cctvDetail = CctvDetail.fromJson(_response!.data['results']);
  //     }
  //   } catch (e) {
  //     throw e;
  //   }
  // }

  /// Get the CCTV capture image when displaying CCTV Detail
  /// Using getCameraShortCutUrl API
  ///
  /// Receives [data] as the CCTV information
  /// Return 'true' if getCameraShortCutUrl API is successful.
  /// Return 'false' if getCameraShortCutUrl API is failed.
  // Future<bool> getCameraShortCutUrlProvider(Map<String, dynamic> data) async {
  //   try {
  //     _response = await CctvService().getCameraShortCutUrl(data);
  //     if (_response!.data['status'] == 200) {
  //       _imageUrl = _response!.data['obj']['picUrl'] ?? '';
  //       return true;

  //       // if (_cctvDetail != null) {
  //       //   _cctvDetail!.image = _response!.data['obj']['picUrl'] ?? '';
  //       // }
  //     }
  //     return false;
  //   } catch (e) {
  //     print('getCameraShortCutUrlProvider failed');
  //     throw e;
  //   }
  // }
}
