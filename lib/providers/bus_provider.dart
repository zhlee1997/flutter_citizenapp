import 'package:flutter/material.dart';

import '../models/bus_model.dart';
import '../services/bus_services.dart';

class BusProvider with ChangeNotifier {
  late List<BusRouteModel> _busRouteList;
  List<BusRouteModel> get busRouteList => _busRouteList;

  String? _routeId;
  String? get routeId => _routeId;

  late String _routeName;
  String get routeName => _routeName;

  /// Set the initial bus route when app is opened.
  /// And when accessing bus schedule.
  Future<void> setBusRouteProvider() async {
    try {
      _busRouteList = await BusServices().getBusRoute();
      _routeId = _busRouteList[0].routeId;
      _routeName = busRouteList[0].routeName;
    } catch (e) {
      throw e;
    }
  }

  /// Get the coordinates of bus station when rendering on Google Map.
  /// Using getBusStation API.
  ///
  /// Receives [routeId] as the bus route ID.
  /// Returns bus station coordinates in a list.
  Future<List<BusStationCoordinatesModel>> setStationCoordinates(
      String routeId) async {
    late List<BusStationCoordinatesModel> stationCoordinatesList;
    try {
      stationCoordinatesList = await BusServices().getBusStation(routeId);
      return stationCoordinatesList;
    } catch (e) {
      throw e;
    }
  }

  /// Get the detail of each station when selecting a bus station.
  /// Using getBusStationDetail API.
  ///
  /// Receives [routeId] as the bus route ID.
  /// And [stationId] as the station ID.
  /// Returns station details in a list.
  Future<List<BusStationModel>?> fetchStationDetail(
    String routeId,
    String stationId,
  ) async {
    late List<BusStationModel> _busStationDetailList;
    try {
      var response =
          await BusServices().getBusStationDetail(routeId, stationId);
      if (response['data'] != null) {
        var stationDetailData = response['data'] as List;
        _busStationDetailList =
            stationDetailData.map((e) => BusStationModel.fromJson(e)).toList();
      }
      return _busStationDetailList;
    } catch (e) {
      throw e;
    }
  }
}
