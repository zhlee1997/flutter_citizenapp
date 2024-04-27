import 'package:flutter/material.dart';

import '../services/camera_subscription_services.dart';
import '../models/camera_subscription_model.dart';

class CameraSubscriptionProvider with ChangeNotifier {
  List<CameraSubscriptionModel> _cameraSubscription = [];
  List<CameraSubscriptionModel> get cameraSubscription => _cameraSubscription;

  Future<bool> getDevicesListByPackageIdProvider(String packageId) async {
    try {
      var response =
          await CameraSubscriptionServices().queryDevicesByPackageId(packageId);

      if (response['status'] == "200") {
        var cctvData = response['data'] as List;
        _cameraSubscription =
            cctvData.map((e) => CameraSubscriptionModel.fromJson(e)).toList();
        notifyListeners();
        return true;
      } else {
        // when response['status'] is 300 (system error)
        return false;
      }
    } catch (e) {
      print("getDevicesListByPackageIdProvider error: ${e.toString()}");
      // throw e;
    }
    return false;
  }
}
