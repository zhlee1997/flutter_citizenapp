class BusModel {}

class BusStationModel {
  late String scheduleId;
  late String arrivalTime;

  // model constructor
  BusStationModel({
    required this.scheduleId,
    required this.arrivalTime,
  });

  // serialize from json
  factory BusStationModel.fromJson(Map<String, dynamic> json) =>
      BusStationModel(
        scheduleId: json["scheduleId"],
        arrivalTime: json["arrivalTime"],
      );
}

class BusRouteModel {
  late String routeId;
  late String routeName;
  late String stationNameStart;
  late String stationNameEnd;
  late String routeStartTime;
  late String routeEndTime;

  // model constructor
  BusRouteModel({
    required this.routeId,
    required this.routeName,
    required this.stationNameStart,
    required this.stationNameEnd,
    required this.routeStartTime,
    required this.routeEndTime,
  });

  // serialize from json (factory pattern)
  factory BusRouteModel.fromJson(Map<String, dynamic> json) => BusRouteModel(
        routeId: json['routeId'],
        routeName: json['routeName'],
        stationNameStart: json['stationNameStart'],
        stationNameEnd: json['stationNameEnd'],
        routeStartTime: json['routeStartTime'],
        routeEndTime: json['routeEndTime'],
      );
}

class BusStationCoordinatesModel {
  late String stationId;
  late String stationName;
  late String stationLongitude;
  late String stationLatitude;

  // model constructor
  BusStationCoordinatesModel({
    required this.stationId,
    required this.stationName,
    required this.stationLongitude,
    required this.stationLatitude,
  });

  // serialize from json
  factory BusStationCoordinatesModel.fromJson(Map<String, dynamic> json) =>
      BusStationCoordinatesModel(
        stationId: json["stationId"],
        stationName: json["stationName"],
        stationLongitude: json["stationLongitude"],
        stationLatitude: json["stationLatitude"],
      );
}
