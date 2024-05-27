import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/major_announcement_model.dart';
import '../models/announcement_model.dart';
import '../services/announcement_services.dart';

class AnnouncementProvider with ChangeNotifier {
  List<MajorAnnouncementModel> _majorAnnouncementList = [];
  List<MajorAnnouncementModel> get majorAnnouncementList =>
      _majorAnnouncementList;

  // when app first open
  Future<void> checkMajorLocalStorage(
      List<MajorAnnouncementModel> annList) async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? majorAnnIdList = prefs.getStringList("majorAnnIdList");
    print("majorAnn: $majorAnnIdList");

    bool isYesterday = await checkIsYesterday();
    if (isYesterday) {
      // refresh
      prefs.remove("majorAnnIdList");
      _majorAnnouncementList = annList;
    } else {
      // today: append
      // Filter list1 against list2 (not included)
      List<MajorAnnouncementModel> filteredList = [];
      if (majorAnnIdList != null) {
        filteredList = annList
            .where((element) => !majorAnnIdList.contains(element.sid))
            .toList();
      } else {
        // first time: when majorAnnIdList is null
        filteredList = annList;
      }
      _majorAnnouncementList = filteredList;
    }
  }

  // when proceed and set new limit left
  Future<void> setMajorLocalStorage(List<String> annIdList) async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? majorAnnIdList = prefs.getStringList("majorAnnIdList");
    int timestamp = DateTime.now().millisecondsSinceEpoch;

    if (majorAnnIdList != null) {
      majorAnnIdList.addAll(annIdList);
      prefs.setStringList("majorAnnIdList", majorAnnIdList);
      prefs.setInt('majorTimestampKey', timestamp);
    } else {
      // first time: when majorAnnIdList is null
      prefs.setStringList("majorAnnIdList", annIdList);
      prefs.setInt('majorTimestampKey', timestamp);
    }
  }

  // to check whether yesterday or today
  Future<bool> checkIsYesterday() async {
    final prefs = await SharedPreferences.getInstance();
    int? timestamp = prefs.getInt('majorTimestampKey');

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    if (timestamp != null) {
      DateTime dateToCheck = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final aDate =
          DateTime(dateToCheck.year, dateToCheck.month, dateToCheck.day);
      if (aDate == today) {
        print("today");
        return false;
      } else if (aDate == yesterday) {
        print("yesterday");
        return true;
      }
    }
    print("no timestamp for subscription, then is yesterday");
    return true;
  }

  /// Get list of major announcement when screen first renders
  /// Using queryPageList API
  Future<void> queryandSetMajorAnnouncementProvider(
      BuildContext context) async {
    try {
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
            ),
            description: AnnouncementModel.getAnnouncementContent(
              context,
              element,
            ),
          );
          majorAnnouncementList.add(m);
        });
        checkMajorLocalStorage(majorAnnouncementList);
        notifyListeners();
      }
    } catch (e) {
      print("queryandSetMajorAnnouncementProvider error: ${e.toString()}");
      rethrow;
    }
  }
}
