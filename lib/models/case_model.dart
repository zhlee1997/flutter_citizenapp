class CaseModel {
  String eventId = "";
  String eventDesc = "";
  String eventTime = "";
  String eventType = "";
  String eventStatus = "";

  // model constructor
  CaseModel({
    required this.eventId,
    required this.eventDesc,
    required this.eventTime,
    required this.eventType,
    required this.eventStatus,
  });

  // serialize from json
  CaseModel.fromJson(Map<String, dynamic> json) {
    if (json.containsKey("eventId")) {
      eventId = json['eventId'];
    }
    if (json.containsKey("eventDesc")) {
      eventDesc = json['eventDesc'];
    }
    if (json.containsKey("createTime")) {
      eventTime = json['createTime'];
    }
    if (json.containsKey("eventType")) {
      eventType = json['eventType'];
    }
    if (json.containsKey("eventStatus")) {
      eventStatus = json['eventStatus'];
    }
  }
}

class EmergencyCaseModel {
  String eventId = "";
  String eventDesc = "";
  String eventTime = "";
  String eventType = "";
  String eventStatus = "";

  // model constructor
  EmergencyCaseModel({
    required this.eventId,
    required this.eventDesc,
    required this.eventTime,
    required this.eventType,
    required this.eventStatus,
  });

  // serialize from json
  EmergencyCaseModel.fromJson(Map<String, dynamic> json) {
    if (json.containsKey("eventId")) {
      eventId = json['eventId'];
    }
    if (json.containsKey("eventDesc")) {
      eventDesc = json['eventDesc'];
    }
    if (json.containsKey("createTime")) {
      eventTime = json['createTime'];
    }
    if (json.containsKey("eventTargetUrgent")) {
      eventType = json['eventTargetUrgent'];
    }
    if (json.containsKey("eventStatus")) {
      eventStatus = json['eventStatus'];
    }
  }
}

class CaseDetailModel {
  String? createBy;
  String? createTime;
  String? delFlag;
  String? eventDesc;
  String? eventId;
  String? eventLatitude;
  String? eventLevel;
  String? eventLocation;
  String? eventLongitude;
  String? eventProcessStatus;
  String? eventStatus;
  String? eventTargetGeneral;
  String? eventTargetUrgent;
  String? eventTime;
  String? eventType;
  String? eventUploadStatus;
  String? eventUrgency;
  String? talikhidmatCaseId;
  String? remarks;
  String? updateTime;

  // model constructor
  CaseDetailModel({
    this.createBy,
    this.createTime,
    this.delFlag,
    this.eventDesc,
    this.eventId,
    this.eventLatitude,
    this.eventLevel,
    this.eventLocation,
    this.eventLongitude,
    this.eventProcessStatus,
    this.eventStatus,
    this.eventTargetGeneral,
    this.eventTargetUrgent,
    this.eventTime,
    this.eventType,
    this.eventUploadStatus,
    this.eventUrgency,
    this.talikhidmatCaseId,
    this.remarks,
    this.updateTime,
  });

  // serialize from json
  CaseDetailModel.fromJson(Map<String, dynamic> json) {
    createBy = json['createBy'];
    createTime = json['createTime'];
    delFlag = json['delFlag'];
    eventDesc = json['eventDesc'];
    eventId = json['eventId'];
    eventLatitude = json['eventLatitude'];
    eventLevel = json['eventLevel'];
    eventLocation = json['eventLocation'];
    eventLongitude = json['eventLongitude'];
    eventProcessStatus = json['eventProcessStatus'];
    eventStatus = json['eventStatus'];
    eventTargetGeneral = json['eventTargetGeneral'];
    eventTargetUrgent = json['eventTargetUrgent'];
    eventTime = json['eventTime'];
    eventType = json['eventType'];
    eventUploadStatus = json['eventUploadStatus'];
    eventUrgency = json['eventUrgency'];
    talikhidmatCaseId = json['talihikmatCaseId'];
    remarks = json['remarks'];
    updateTime = json['updateTime'];
  }

  // serialize to json
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['createBy'] = createBy;
    data['createTime'] = createTime;
    data['delFlag'] = delFlag;
    data['eventDesc'] = eventDesc;
    data['eventId'] = eventId;
    data['eventLatitude'] = eventLatitude;
    data['eventLevel'] = eventLevel;
    data['eventLocation'] = eventLocation;
    data['eventLongitude'] = eventLongitude;
    data['eventProcessStatus'] = eventProcessStatus;
    data['eventStatus'] = eventStatus;
    data['eventTargetGeneral'] = eventTargetGeneral;
    data['eventTargetUrgent'] = eventTargetUrgent;
    data['eventTime'] = eventTime;
    data['eventType'] = eventType;
    data['eventUploadStatus'] = eventUploadStatus;
    data['eventUrgency'] = eventUrgency;
    data['remarks'] = remarks;
    data['updateTime'] = updateTime;
    return data;
  }
}

class AttachmentModel {
  String attFileName = "";
  String attFilePath = "";
  String attFileSuffix = "";
  String attFileType = "";
  String attId = "";
  String createTime = "";
  String delFlag = "";
  String eventId = "";
  String updateTime = "";

  // model constructor
  AttachmentModel(
    this.attFileName,
    this.attFilePath,
    this.attFileSuffix,
    this.attFileType,
    this.attId,
    this.createTime,
    this.delFlag,
    this.eventId,
    this.updateTime,
  );

  // serialize from json
  AttachmentModel.fromJson(Map<String, dynamic> json) {
    attFileName = json['attFileName'];
    attFilePath = json['attFilePath'];
    attFileSuffix = json['attFileSuffix'];
    attFileType = json['attFileType'];
    attId = json['attId'];
    delFlag = json['delFlag'];
    eventId = json['eventId'];
  }

  // serialize to json
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['attFileName'] = attFileName;
    data['attFilePath'] = attFilePath;
    data['attFileSuffix'] = attFileSuffix;
    data['attFileType'] = attFileType;
    data['attId'] = attId;
    data['createTime'] = createTime;
    data['delFlag'] = delFlag;
    data['eventId'] = eventId;
    data['updateTime'] = updateTime;
    return data;
  }
}
