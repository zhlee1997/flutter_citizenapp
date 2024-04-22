import 'package:provider/provider.dart';

import "../providers/language_provider.dart";

class AnnouncementModel {
  late String annAuthor;
  late String annEndDate;
  late String annId;
  late String annStartDate;
  late String annStatusPublish;
  late String annTitleEn;
  late String annTitleMs;
  late String annTitleZh;
  late String annMessageZh;
  late String annMessageMs;
  late String annMessageEn;
  late List<AttachmentDtoList> attachmentDtoList;
  late String delFlag;

  // modify title of announcement
  static String getAnnouncementTitle(context, element) {
    String languageCode = Provider.of<LanguageProvider>(context, listen: false)
        .locale
        .languageCode;
    if (languageCode == 'en') {
      return element.annTitleEn;
    } else if (languageCode == 'zh') {
      return element.annTitleZh;
    } else {
      return element.annTitleMs;
    }
  }

  // modify content of announcement
  static String getAnnouncementContent(context, element) {
    String languageCode = Provider.of<LanguageProvider>(context, listen: false)
        .locale
        .languageCode;
    if (languageCode == 'en') {
      return element.annMessageEn;
    } else if (languageCode == 'zh') {
      return element.annMessageZh;
    } else {
      return element.annMessageMs;
    }
  }

  // Factory method to create a AnnouncementModel object from a Map
  // serialize from json
  AnnouncementModel.fromJson(Map<String, dynamic> json) {
    annAuthor = json['annAuthor'] ?? "";
    annEndDate = json['annEndDate'] ?? "";
    annId = json['annId'] ?? "";
    annStartDate = json['annStartDate'] ?? "";
    annStatusPublish = json['annStatusPublish'] ?? "";
    annTitleEn = json['annTitleEn'] ?? "";
    annTitleMs = json['annTitleMs'] ?? "";
    annTitleZh = json['annTitleZh'] ?? "";
    annMessageZh = json['annMessageZh'] ?? "";
    annMessageMs = json['annMessageMs'] ?? "";
    annMessageEn = json['annMessageEn'] ?? "";

    if (json['attachmentDtoList'] != null) {
      attachmentDtoList = [];
      json['attachmentDtoList'].forEach((v) {
        attachmentDtoList.add(AttachmentDtoList.fromJson(v));
      });
    }

    delFlag = json['delFlag'];
  }

  // serialize to json
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['annAuthor'] = annAuthor;
    data['annEndDate'] = annEndDate;
    data['annId'] = annId;
    data['annStartDate'] = annStartDate;
    data['annStatusPublish'] = annStatusPublish;
    data['annTitleEn'] = annTitleEn;
    data['annTitleMs'] = annTitleMs;
    data['annTitleZh'] = annTitleZh;
    data['annMessageEn'] = annMessageEn;
    data['annMessageMs'] = annMessageMs;
    data['annMessageZh'] = annMessageZh;

    if (attachmentDtoList.isNotEmpty) {
      data['attachmentDtoList'] =
          attachmentDtoList.map((v) => v.toJson()).toList();
    }

    data['delFlag'] = delFlag;
    return data;
  }
}

class AttachmentDtoList {
  late String attFilePath;
  late String attFileType;
  late String attId;
  late String delFlag;

  // serialize from json
  AttachmentDtoList.fromJson(Map<String, dynamic> json) {
    attFilePath = json['attFilePath'] ?? "";
    attFileType = json['attFileType'] ?? "";
    attId = json['attId'] ?? "";
    delFlag = json['delFlag'] ?? "";
  }

  // serialize to json
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['attFilePath'] = attFilePath;
    data['attFileType'] = attFileType;
    data['attId'] = attId;
    data['delFlag'] = delFlag;
    return data;
  }
}
