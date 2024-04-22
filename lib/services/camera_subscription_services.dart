import '../utils/api_base_helper.dart';

class CameraSubscriptionServices {
  final ApiBaseHelper _apiBaseHelper = ApiBaseHelper();

  Future<dynamic> queryDevicesByPackageId(String packageId) async {
    try {
      var response = await _apiBaseHelper.get(
        'member/memberSubscribePackage/getDeviceById/$packageId',
        requireToken: true,
      );
      print('queryDevicesByPackageId API success: $response');
      return response;
    } catch (e) {
      print("queryDevicesByPackageId API error: ${e.toString()}");
    }
  }
}
