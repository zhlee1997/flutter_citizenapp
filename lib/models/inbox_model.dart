class InboxModel {
  String createBy = "";
  String createTime = "";
  String delFlag = "";
  String msgContext = "";
  String msgMarkStatus = "";
  String msgReadStatus = "";
  String msgTitle = "";
  String msgType = "";
  String rcvId = "";
  String rcvLoginName = "";
  String rcvMemberId = "";
  String rcvSarawakId = "";
  String updateBy = "";
  String updateTime = "";

  // serialize from json
  InboxModel.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('createBy')) {
      createBy = json['createBy'];
    }
    if (json.containsKey('createTime')) {
      createTime = json['createTime'];
    }
    if (json.containsKey('delFlag')) {
      delFlag = json['delFlag'];
    }
    if (json.containsKey('msgContext')) {
      msgContext = json['msgContext'];
    }
    if (json.containsKey('msgMarkStatus')) {
      msgMarkStatus = json['msgMarkStatus'];
    }
    if (json.containsKey('msgReadStatus')) {
      msgReadStatus = json['msgReadStatus'];
    }
    if (json.containsKey('msgTitle')) {
      msgTitle = json['msgTitle'];
    }
    if (json.containsKey('msgType')) {
      msgType = json['msgType'];
    }
    if (json.containsKey('rcvId')) {
      rcvId = json['rcvId'];
    }
    if (json.containsKey('rcvMemberId')) {
      rcvMemberId = json['rcvMemberId'];
    }
    if (json.containsKey('rcvSarawakId')) {
      rcvSarawakId = json['rcvSarawakId'];
    }
    if (json.containsKey('rcvLoginName')) {
      rcvLoginName = json['rcvLoginName'];
    }
    if (json.containsKey('updateBy')) {
      updateBy = json['updateBy'];
    }
    if (json.containsKey('updateTime')) {
      updateTime = json['updateTime'];
    }
  }

  // serialize to json
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['createBy'] = createBy;
    data['createTime'] = createTime;
    data['delFlag'] = delFlag;
    data['msgContext'] = msgContext;
    data['msgMarkStatus'] = msgMarkStatus;
    data['msgReadStatus'] = msgReadStatus;
    data['msgTitle'] = msgTitle;
    data['msgType'] = msgType;
    data['rcvId'] = rcvId;
    data['rcvLoginName'] = rcvLoginName;
    data['rcvMemberId'] = rcvMemberId;
    data['rcvSarawakId'] = rcvSarawakId;
    data['updateBy'] = updateBy;
    data['updateTime'] = updateTime;
    return data;
  }
}
