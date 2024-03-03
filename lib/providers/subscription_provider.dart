import 'package:flutter/material.dart';

class SubscriptionProvider with ChangeNotifier {
  bool _isSubscription = false;
  bool get isSubscription => _isSubscription;

  /// Determine whether it is subscription payment when paying using S Pay Global
  ///
  /// Receives [value] as the boolean value.
  /// If [value] is 'true', it is subscription payment.
  /// If [value] is 'false', it is not subscription payment.
  void changeIsSubscription(bool value) {
    _isSubscription = value;
  }
}
