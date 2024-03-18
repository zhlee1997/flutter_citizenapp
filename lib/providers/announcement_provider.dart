import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/major_announcement_model.dart';
import '../models/announcement_model.dart';
import '../services/announcement_services.dart';

class AnnouncementProvider with ChangeNotifier {
  List<MajorAnnouncementModel> _majorAnnouncementList = [];
  List<MajorAnnouncementModel> get majorAnnouncementList =>
      _majorAnnouncementList;

  /// Get list of major announcement when screen first renders
  /// Using queryPageList API
  Future<void> queryandSetMajorAnnouncementProvider(
      BuildContext context) async {
    final f = DateFormat('yyyy-MM-dd');
    var response = await AnnouncementServices().queryPageList(
      '1',
      annType: '3',
      nowTime: f.format(DateTime.now()),
    );

    if (response['status'] == '200') {
      var data = response['data']['list'] as List;
      List announcements =
          data.map((e) => AnnouncementModel.fromJson(e)).toList();

      List<MajorAnnouncementModel> majorAnnouncementList = [];
      announcements.forEach((element) {
        var m = MajorAnnouncementModel(
          sid: element.annId,
          image: element.attachmentDtoList.length > 0
              ? element.attachmentDtoList[0].attFilePath.toString()
              : '',
          title: AnnouncementModel.getAnnouncementTitle(
            context,
            element,
            isMajorAnnouncement: true,
          ),
          description: AnnouncementModel.getAnnouncementContent(
            context,
            element,
            isMajorAnnouncement: true,
          ),
        );
        majorAnnouncementList.add(m);
      });
      _majorAnnouncementList = majorAnnouncementList;
      notifyListeners();
    }
  }
}
