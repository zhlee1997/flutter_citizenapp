class CameraSubscriptionModel {
  late String channel;
  late String deviceCode;
  late String deviceName;
  late String id;
  late String latitude;
  late String longitude;
  late String location;
  late String picUrl;

  CameraSubscriptionModel({
    required this.channel,
    required this.deviceCode,
    required this.deviceName,
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.location,
    required this.picUrl,
  });

  factory CameraSubscriptionModel.fromJson(Map<String, dynamic> json) =>
      CameraSubscriptionModel(
        channel: json["channel"],
        deviceCode: json["deviceCode"],
        deviceName: json["deviceName"],
        id: json["id"],
        latitude: json["latitude"],
        longitude: json["longitude"],
        location: json["location"],
        picUrl: json["picUrl"],
      );
}
