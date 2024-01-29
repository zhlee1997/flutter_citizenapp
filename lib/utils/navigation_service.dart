import 'package:flutter/material.dart';

class NavigationService {
  late GlobalKey<NavigatorState> navigationKey;

  static NavigationService instance = NavigationService();

  NavigationService() {
    navigationKey = GlobalKey<NavigatorState>();
  }

  Future<dynamic> navigateToReplacement(String rn) {
    return navigationKey.currentState!.pushReplacementNamed(rn);
  }

  /// Navigate to particular screen when tapping on push notification
  /// Using GlobalKey
  ///
  /// Receives [rn] as the route name
  /// [arguments] as the data required by the particular screen
  Future<dynamic> navigateTo(String rn, {Object? arguments}) {
    return navigationKey.currentState!.pushNamed(rn, arguments: arguments);
  }

  Future<dynamic> navigateToRoute(MaterialPageRoute rn) {
    return navigationKey.currentState!.push(rn);
  }

  goback() {
    return navigationKey.currentState!.pop();
  }
}
