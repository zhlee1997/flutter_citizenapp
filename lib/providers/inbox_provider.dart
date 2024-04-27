import 'package:flutter/material.dart';

import '../utils/general_helper.dart';
import '../services/inbox_services.dart';
import '../models/inbox_model.dart';

class InboxProvider with ChangeNotifier {
  int _unreadMessageCount = 0;
  int get unreadMessageCount => _unreadMessageCount;

  int _page = 1;
  bool _isLoading = false;

  bool _noMoreData = false;
  bool get noMoreData => _noMoreData;

  List<InboxModel> _inboxes = [];
  List<InboxModel> get inboxes => _inboxes;

  void deleteInbox() {
    _unreadMessageCount = 0;
    _page = 1;
    _noMoreData = false;
    _inboxes = [];
    notifyListeners();
  }

  void setNotificationPage(int page) {
    _page = page;
  }

  // Notification Pagination
  Future<void> queryNotificationsProvider() async {
    if (_isLoading) {
      return;
    }
    _isLoading = true;
    try {
      var response = await InboxServices().queryInboxPageList('$_page');
      if (response['status'] == '200') {
        var data = response['data']['list'] as List;
        var total = response['data']['total'] as int;
        if (total < (20 * _page)) {
          _noMoreData = true;
        }

        if (_page == 1) {
          _inboxes = data.map((e) => InboxModel.fromJson(e)).toList();
        } else {
          _inboxes.addAll(data.map((e) => InboxModel.fromJson(e)).toList());
        }
        notifyListeners();
      }
      _isLoading = false;
    } catch (e) {
      _isLoading = false;
      print('queryNotificationsProvider fail: ${e.toString()}');
      throw e;
    }
  }

  // Notification Refresh (triggered by other operation as well)
  Future<void> refreshNotificationsProvider() async {
    try {
      _page = 1;
      _noMoreData = false;
      await refreshCount();
      await queryNotificationsProvider();
    } catch (e) {
      print("_onRefreshProvider error: ${e.toString()}");
    }
  }

  /// Get the number of unread messages when app is opened
  /// When submitting cases
  /// Using queryCnt API
  Future<void> refreshCount() async {
    try {
      await GeneralHelper.clearCache('message');
      var response = await InboxServices().queryCnt();
      if (response['status'] == '200') {
        _unreadMessageCount = response['data'];
        notifyListeners();
      }
    } catch (e) {
      print("refreshCount error: ${e.toString()}");
    }
  }

  void resetMessageCount() {
    _unreadMessageCount = 0;
    notifyListeners();
  }
}
