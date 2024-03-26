import 'package:flutter/material.dart';

import '../utils/general_helper.dart';
import '../services/inbox_services.dart';

class InboxProvider with ChangeNotifier {
  int _unreadMessageCount = 0;
  int get unreadMessageCount => _unreadMessageCount;

  /// Get the number of unread messages when app is opened
  /// When submitting cases
  /// Using queryCnt API
  Future<void> refreshCount() async {
    await GeneralHelper.clearCache('message');
    var response = await InboxServices().queryCnt();
    if (response != null && response['status'] == '200') {
      _unreadMessageCount = response['data'];
      notifyListeners();
    }
  }

  void resetMessageCount() {
    _unreadMessageCount = 0;
    notifyListeners();
  }
}
