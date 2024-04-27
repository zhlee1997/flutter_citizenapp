import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/subscription_services.dart';

class SubscriptionProvider with ChangeNotifier {
  bool _isSubscription = false;
  bool get isSubscription => _isSubscription;

  bool _isSubscriptionEnabled = false;
  bool get isSubscriptionEnabled => _isSubscriptionEnabled;

  bool _isWhitelisted = false;
  bool get isWhitelisted => _isWhitelisted;

  String _subscribeId = "";
  String get subscribeId => _subscribeId;

  String _frequencyLimit = "";
  String get frequencyLimit => _frequencyLimit;

  int _frequencyLimitLeft = -1;
  int get frequencyLimitLeft => _frequencyLimitLeft;

  String _playbackDuration = "";
  String get playbackDuration => _playbackDuration;

  late String _paymentItem;
  String get paymentItem => _paymentItem;

  // use pay_id from payment/orderForm/create/confrim
  late String _receiptNumber;
  String get receiptNumber => _receiptNumber;

  // use order_id from payment/orderForm/createBySelective
  late String _referenceNumber;
  String get referenceNumber => _referenceNumber;

  final SubscriptionServices _subscriptionServices = SubscriptionServices();

  /// Determine whether it is subscription payment when paying using S Pay Global
  ///
  /// Receives [value] as the boolean value.
  /// If [value] is 'true', it is subscription payment.
  /// If [value] is 'false', it is not subscription payment.
  void changeIsSubscription(bool value) {
    _isSubscription = value;
    notifyListeners();
  }

  // when app first open
  Future<void> checkFrequencyLimit(String frequencyLimit) async {
    final prefs = await SharedPreferences.getInstance();
    int frequency = int.parse(frequencyLimit);
    int num = prefs.getInt("frequencyLimitLeft") ?? 0;

    bool isYesterday = await checkIsYesterday();
    if (isYesterday) {
      _frequencyLimitLeft = frequency;
    } else {
      // today: use back
      if (num > frequency) {
        // api return smaller set frequency (set temp to remember)
        _frequencyLimitLeft = frequency;
      } else {
        // api return bigger no chap, continue
        _frequencyLimitLeft = num;
      }
    }
  }

  // when proceed and set new limit left
  Future<bool> setFrequencyLimit() async {
    final prefs = await SharedPreferences.getInstance();

    int timestamp = DateTime.now().millisecondsSinceEpoch;
    int num = _frequencyLimitLeft;
    print(num);
    num = num - 1;
    if (num >= 0) {
      prefs.setInt("frequencyLimitLeft", num);
      prefs.setInt('myTimestampKey', timestamp);
      return true;
    } else {
      prefs.setInt("frequencyLimitLeft", 0);
      prefs.setInt('myTimestampKey', timestamp);
      return false;
    }
  }

  // to check whether yesterday or today
  Future<bool> checkIsYesterday() async {
    final prefs = await SharedPreferences.getInstance();
    int? timestamp = prefs.getInt('myTimestampKey');

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

  Future<bool> queryAndSetIsSubscriptionEnabled() async {
    try {
      var response =
          await _subscriptionServices.queryPackageAndSubscriptionEnable();
      if (response['status'] == '200') {
        List subscribeList = response["data"] as List;
        List filteredList = subscribeList
            .where((element) => element["subscribeCode"] == "Default")
            .toList();
        // assign subscribedId
        _subscribeId = filteredList[0]["subscribeId"];
        // frequency limit
        _frequencyLimit = filteredList[0]["frequencyLimit"];
        await checkFrequencyLimit(_frequencyLimit);
        // playback duration
        _playbackDuration = filteredList[0]["playbackDuration"];
        // check whether subscription service enabled
        if (filteredList[0]["subscriptionEnable"] == "0") {
          _isSubscriptionEnabled = false;
          notifyListeners();
          return false;
        } else {
          _isSubscriptionEnabled = true;
          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      print("queryAndSetIsSubscriptionEnabled: ${e.toString()}");
    }
    notifyListeners();
    return false;
  }

  Future<bool> queryAndSetIsWhitelisted(String memberId) async {
    try {
      var response = await _subscriptionServices.querySubscriptionWhitelisted(
        subscribeId: _subscribeId,
        memberId: memberId,
      );
      if (response['status'] == '200') {
        var responseList = response['data'] as List;
        if (responseList.isNotEmpty) {
          _isWhitelisted = true;
          return true;
        } else {
          _isWhitelisted = false;
          return false;
        }
      }
      notifyListeners();
    } catch (e) {
      print("queryAndSetIsWhitelisted: ${e.toString()}");
    }
    return false;
  }

  Future<String> querySubscriptionPackageOptionProvider() async {
    String packageId = "";
    try {
      final prefs = await SharedPreferences.getInstance();
      String memberId = prefs.getString('userId') ?? '';
      var response = await _subscriptionServices.querySubscriptionPackageOption(
        subscribeId: subscribeId,
        memberId: memberId,
      );
      if (response["status"] == "200") {
        // packageId: option_1, option_2, option_3
        List subscribeList = response["data"] as List;
        // List filteredList = subscribeList
        //     .where((element) => element["subscribeCode"] == "Default")
        //     .toList();
        List filteredList = subscribeList;
        if (filteredList.isNotEmpty) {
          packageId = filteredList[0]["option"] ?? "";
        }
      }
    } catch (e) {
      print("querySubscriptionPackageOptionProvider: ${e.toString()}");
    }
    return packageId;
  }

  // set paymentItem
  void setPaymentItem(String item) {
    _paymentItem = item;
  }

  // set receiptNumber
  void setReceiptNumber(String number) {
    _receiptNumber = number;
  }

  // set referenceNumber
  void setReferenceNumber(String number) {
    _referenceNumber = number;
  }
}
