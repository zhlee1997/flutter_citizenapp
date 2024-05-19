import '../utils/api_base_helper.dart';
import '../models/bus_model.dart';

class BusServices {
  final ApiBaseHelper _apiBaseHelper = ApiBaseHelper();

  /// Get bus routes ID
  ///
  /// Returns list of bus routes
  Future<List<BusRouteModel>> getBusRoute() async {
    late List<BusRouteModel> busRouteList;

    try {
      var response = await _apiBaseHelper.get(
        'busRoute/queryList',
        requireToken: false,
      );
      if (response['status'] == '200') {
        print('getBusRoute API success: $response');
        var busRouteData = response['data'] as List;
        busRouteList =
            busRouteData.map((e) => BusRouteModel.fromJson(e)).toList();
      }
      return busRouteList;
    } catch (e) {
      print('getBusRoute fail: ${e.toString()}');
      throw e;
    }
  }

  /// Get bus stations
  ///
  /// Receives [routeId] as the bus route ID
  /// Returns list of bus stations
  Future<List<BusStationCoordinatesModel>> getBusStation(String routeId) async {
    late List<BusStationCoordinatesModel> busStationList;

    try {
      var response = await _apiBaseHelper.get(
        'busStation/queryList',
        queryParameters: {
          "routeId": routeId,
        },
        requireToken: false,
      );
      if (response['status'] == '200') {
        print('getBusStation API success: $response');
        var busStationData = response['data'] as List;
        busStationList = busStationData
            .map((e) => BusStationCoordinatesModel.fromJson(e))
            .toList();
      }
    } catch (e) {
      print('getBusStation fail: ${e.toString()}');
      throw e;
    }
    return busStationList;
  }

  /// Get detail of a bus station
  ///
  /// Receives [routeId] as the bus route ID
  /// [stationId] as the bus station ID
  /// Returns API response object
  Future<dynamic> getBusStationDetail(
    String routeId,
    String stationId,
  ) async {
    try {
      var response = await _apiBaseHelper.get(
        'busScheduleStation/queryList',
        queryParameters: {
          'routeId': routeId,
          'stationId': stationId,
        },
        requireToken: false,
      );
      print('getBusStationDetail API success: $response');
      return response;
    } catch (e) {
      print('getBusStationDetail fail: ${e.toString()}');
      throw e;
    }
  }
}
