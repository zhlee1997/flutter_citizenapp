class CCTVModel {
  late String cctvId;
  late String latitude;
  late String longitude;
  late String channel;
  late String deviceName;
  late String location;

  // model constructor
  CCTVModel({
    required this.cctvId,
    required this.latitude,
    required this.longitude,
    required this.channel,
    required this.deviceName,
    required this.location,
  });

  // serialize from json
  CCTVModel.fromJson(Map<String, dynamic> json) {
    cctvId = json["deviceCode"];
    channel = json["channel"];
    deviceName = json["deviceName"];
    latitude = json["latitude"];
    longitude = json["longitude"];
    location = json["location"];
  }
}

class CCTVModelDetail {
  late String id;
  late String name;
  late String location;
  late String image;
  late String updateTime;
  late String liveUrl;

  // model constructor
  CCTVModelDetail({
    required this.id,
    required this.name,
    required this.location,
    required this.image,
    required this.updateTime,
    required this.liveUrl,
  });

  // serialize from json
  CCTVModelDetail.fromJson(Map<String, dynamic> json) {
    id = json["_id"];
    name = json["label"];
    location = json["location"];
    image = json["image"];
    updateTime = json["updateTime"];
  }
}
