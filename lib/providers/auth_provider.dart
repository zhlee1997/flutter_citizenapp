import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';

import "../models/auth_model.dart";
import "../services/auth_services.dart";
import "../services/notification_services.dart";
import "../services/subscription_services.dart";
import '../../utils/app_localization.dart';

class AuthProvider with ChangeNotifier {
  AuthServices _authServices = AuthServices();
  NotificationServices _notificationServices = NotificationServices();

  int currentMilliSec = DateTime.now().millisecondsSinceEpoch;

  bool _isAuth = false;
  bool get isAuth => _isAuth;

  bool _isSubscriptionEnabled = true;
  bool get isSubscriptionEnabled => _isSubscriptionEnabled;

  bool _isWhitelisted = false;
  bool get isWhitelisted => _isWhitelisted;

  String? _vipDueDate;
  String? get vipDueDate => _vipDueDate;

  AuthModel? _auth;
  AuthModel get auth =>
      _auth ??
      AuthModel(
        address: '',
        mobile: '',
        email: '',
        sId: '',
        userName: '',
        fullName: '',
        isSubscribed: false,
      );

  /// Sign in.
  /// Using signIn API.
  ///
  /// Receives [data] as authentication data from API.
  /// Such as full name and Sarawak ID.
  /// Return 'true' if sign in is successful.
  /// Return 'false' if sign in is failed.
  Future<Map<String, String>?> signInProvider(Map<String, String> data) async {
    final prefs = await SharedPreferences.getInstance();
    final storage = new FlutterSecureStorage();

    try {
      print(data);
      if (data['userId'] != null) {
        prefs.setBool("isSubscribed", data['isSubscribed'] == 'true');
        prefs.setInt(
            "expire", int.parse(data['expire']!) * 1000 + currentMilliSec);
        prefs.setString("userId", data['userId'] ?? '');

        // VIP due date
        if (data['isSubscribed'] == 'true') {
          _vipDueDate = data['vipDueDate'] ?? '';
          prefs.setString("vipDueDate", data['vipDueDate'] ?? '');
        }
        storage.write(
          key: 'siocToken',
          value: data['siocToken'] ?? '',
        );
        storage.write(
          key: 'sarawakToken',
          value: data['sarawakToken'] ?? '',
        );

        // _isShow = true;
        _isAuth = true;
        notifyListeners();
        return data;
      } else {
        _auth = null;
        _isAuth = false;
        return null;
      }
    } catch (e) {
      _auth = null;
      _isAuth = false;
      return null;
    }
  }

  /// Sign out.
  /// Using signOut API.
  ///
  /// Return 'true' if sign out is successful.
  /// Return 'false' if sign out is failed.
  Future<bool> signOutProvider(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final storage = new FlutterSecureStorage();

    String? siocToken = await storage.read(key: 'siocToken');
    String? sarawakToken = await storage.read(key: 'sarawakToken');

    try {
      // TODO: deleteToken
      // await _notificationServices.deleteToken();
      var response = await _authServices.signOut(
        sarawakToken: sarawakToken,
        siocToken: siocToken,
      );
      // if (response['status'] == '200') {
      // TODO: temp added
      if (response['loginMode'] == '1') {
        // Provider.of<InboxProvider>(context, listen: false).resetMessageCount();
        prefs.clear();
        storage.deleteAll();
        // _isShow = true;
        _isAuth = false;
        _auth = null;
        notifyListeners();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: AppLocalization.of(context)!.translate('sign_out_failed')!,
      );
      return false;
    }
  }

  Future<bool> queryLoginUserInfo(String userId, bool isSubscribed) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      var response = await _authServices.queryUserInfo(userId);
      if (response['status'] == '200') {
        // User Information
        _auth = AuthModel(
          address: response['data']['address'] ?? '',
          mobile: response['data']['mobile'] ?? '',
          email: response['data']['email'] ?? '',
          sId: response['data']['memberId'] ?? '',
          userName: response['data']['sarawakId'] ?? '',
          fullName: response['data']['nickName'] ?? '',
          isSubscribed: isSubscribed,
        );

        prefs.setString("userEmail", response['data']['email'] ?? '');
        prefs.setString("userFullName", response['data']['nickName'] ?? '');
        prefs.setString("userId", response['data']['memberId'] ?? '');
        prefs.setString("userMobileNo", response['data']['mobile'] ?? '');
        prefs.setString("userShortName", response['data']['sarawakId'] ?? '');
        prefs.setString("userResAddr1", response['data']['address'] ?? '');
        notifyListeners();
        return true;
      } else {
        _auth = AuthModel(
          address: '',
          mobile: '',
          email: '',
          sId: '',
          userName: '',
          fullName: '',
          isSubscribed: isSubscribed,
        );
        notifyListeners();
        return false;
      }
    } catch (e) {
      print(e.toString());
      print('queryLoginUserInfo fail');
      throw e;
    }
  }

  /// Check expiry of token when app is opened.
  ///
  /// Return 'true' if does not exceeds valid refresh period.
  /// And refresh new token.
  /// Return 'false' if exceeds valid refresh period.
  /// And sign out.
  Future<bool> checkIsAuth(BuildContext context) async {
    bool isTokenOk = false;
    final prefs = await SharedPreferences.getInstance();
    final storage = new FlutterSecureStorage();

    String? siocToken = await storage.read(key: 'siocToken');
    String? sarawakToken = await storage.read(key: 'sarawakToken');
    int? expire = prefs.getInt('expire');

    print("siocTokenLocal: $siocToken");
    print("expireLocal: $expire");

    if (expire != null &&
        !expire.isNaN &&
        siocToken != null &&
        siocToken.isNotEmpty &&
        sarawakToken != null &&
        sarawakToken.isNotEmpty) {
      // TODO: Setup signOut API
      // Sign out if exceeds valid refresh period
      if (currentMilliSec > expire) {
        print("signOut");
        // signOut(context);
      } else {
        // TODO: Setup refreshToken API
        // If within valid refresh period
        print("refreshToken");
        // refreshToken();
        isTokenOk = true;
        bool subscriptionStatus = await checkSubscribe();

        // TODO: FIRST => check _isSubscriptionEnabled
        _isSubscriptionEnabled = true;

        // TODO: SECOND => check _isWhitelisted
        _isWhitelisted = true;

        // THIRD => check subscription date
        if (subscriptionStatus) {
          _auth = AuthModel(
            address: prefs.getString('userResAddr1') ?? '',
            mobile: prefs.getString('userMobileNo') ?? '',
            email: prefs.getString('userEmail') ?? '',
            sId: prefs.getString('userId') ?? '',
            userName: prefs.getString('userShortName') ?? '',
            fullName: prefs.getString('userFullName') ?? '',
            // TODO: get latest data from querySubscription API
            // TODO: use setBool
            isSubscribed: prefs.getBool('isSubscribed') ?? false,
          );
          // TODO: get latest data from querySubscription API
          // TODO: use setString
          _vipDueDate = prefs.getString('vipDueDate') ?? '';
        } else {
          _auth = AuthModel(
            address: prefs.getString('userResAddr1') ?? '',
            mobile: prefs.getString('userMobileNo') ?? '',
            email: prefs.getString('userEmail') ?? '',
            sId: prefs.getString('userId') ?? '',
            userName: prefs.getString('userShortName') ?? '',
            fullName: prefs.getString('userFullName') ?? '',
            isSubscribed: false,
          );
          _vipDueDate = '';
          prefs.setBool("isSubscribed", false);
          prefs.setString("vipDueDate", '');
        }
      }
    }

    if (isTokenOk) {
      _isAuth = true;
    }
    return isTokenOk;
  }

  /// Check subscription due date when app is opened.
  /// And when accessing Live Video.
  ///
  /// Return 'true' if subscription is within due date.
  /// Return 'false' if subscription is out of due date.
  // TODO: change to return Map<String, dynamic> => isSubscribe, vipDueDate
  // TODO: current condition: vipDueDate is empty
  Future<bool> checkSubscribe() async {
    final prefs = await SharedPreferences.getInstance();
    final SubscriptionServices subscriptionServices = SubscriptionServices();

    String vipDueDate = prefs.getString('vipDueDate') ?? '';

    if (vipDueDate == '') return false;

    if (DateTime.parse(vipDueDate).isAfter(DateTime.now())) {
      try {
        // TODO: NEW API => CHECK RESPONSE FROM BACKEND
        var response = await subscriptionServices.querySubscriptionStatus();
        if (response["status"] == "200") {
          prefs.setBool("isSubscribed", true);
          // prefs.setString("vipDueDate", '');
        }
      } catch (e) {
        print("checkSubscribe fail: ${e.toString()}");
      }
      return true;
    } else {
      return false;
    }
  }
}
