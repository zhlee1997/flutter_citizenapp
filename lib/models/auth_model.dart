class AuthModel {
  late String sId;
  late String userName;
  late String fullName;
  String? identityNumber;
  // TODO: Passport case
  String? passportNumber;
  String? email;
  String? mobile;
  String? address;
  late bool vipStatus;
  String? vipDueDate;
  String? profileImage;
  // NOT USED
  String? numberOfUnreadMessages;

  // model constructor
  AuthModel({
    required this.sId,
    required this.userName,
    required this.fullName,
    this.identityNumber,
    this.passportNumber,
    this.email,
    this.mobile,
    required this.vipStatus,
    this.vipDueDate,
    this.profileImage,
    this.numberOfUnreadMessages,
    this.address,
  });

  // serialize from json
  AuthModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userName = json['userName'];
    fullName = json['userFullName'];
    identityNumber = json['identityNumber'];
    passportNumber = json['passportNumber'];
    email = json['email'];
    mobile = json['mobile'];
    vipStatus = json['vipStatus'];
    vipDueDate = json['vipDueDate'];
    profileImage = json['profileImage'];
    numberOfUnreadMessages = json['numberOfUnreadMessages'];
    address = json['address'];
  }

  // serialize to json
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> jsonData = <String, dynamic>{};
    jsonData['_id'] = sId;
    jsonData['userName'] = userName;
    jsonData['fullName'] = fullName;
    jsonData['identityNumber'] = identityNumber;
    jsonData['passportNumber'] = passportNumber;
    jsonData['email'] = email;
    jsonData['mobile'] = mobile;
    jsonData['vipStatus'] = vipStatus;
    jsonData['vipDueDate'] = vipDueDate;
    jsonData['profileImage'] = profileImage;
    jsonData['numberOfUnreadMessages'] = numberOfUnreadMessages;
    jsonData['address'] = address;

    return jsonData;
  }
}
