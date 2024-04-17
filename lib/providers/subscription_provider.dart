import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/subscription_services.dart';

class SubscriptionProvider with ChangeNotifier {
  bool _isSubscription = false;
  bool get isSubscription => _isSubscription;

  bool _isSubscriptionEnabled = true;
  bool get isSubscriptionEnabled => _isSubscriptionEnabled;

  bool _isWhitelisted = false;
  bool get isWhitelisted => _isWhitelisted;

  String _subscribeId = "";
  String get subscribeId => _subscribeId;

  String _frequencyLimit = "";
  String get frequencyLimit => _frequencyLimit;

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

  Future<void> queryAndSetIsSubscriptionEnabled() async {
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
        // playback duration
        _playbackDuration = filteredList[0]["playbackDuration"];
        // check whether subscription service enabled
        if (filteredList[0]["subscriptionEnable"] == "0") {
          _isSubscriptionEnabled = false;
        } else {
          _isSubscriptionEnabled = true;
        }
      }
      notifyListeners();
    } catch (e) {
      print("queryAndSetIsSubscriptionEnabled: ${e.toString()}");
    }
  }

  Future<bool> queryAndSetIsWhitelisted(String memberId) async {
    try {
      // TODO: Temp use Lucy, to get nickName from auth model
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
