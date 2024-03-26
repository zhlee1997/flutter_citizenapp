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

  // bool _isSubscriptionEnabled = true;
  // bool get isSubscriptionEnabled => _isSubscriptionEnabled;

  // bool _isWhitelisted = false;
  // bool get isWhitelisted => _isWhitelisted;

  // String? _vipDueDate;
  // String? get vipDueDate => _vipDueDate;

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
        vipStatus: false,
        vipDueDate: '',
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
      if (data['userId'] != null) {
        prefs.setInt(
            "expire", int.parse(data['expire']!) * 1000 + currentMilliSec);
        prefs.setString("userId", data['userId'] ?? '');

        // VIP due date
        // callback response URL will not have "vipDueDate" if "isSubscribed" is false
        // if (data['isSubscribed'] == 'true') {}

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
      await _notificationServices.deleteToken();
      var response = await _authServices.signOut(
        sarawakToken: sarawakToken,
        siocToken: siocToken,
      );
      if (response['status'] == '200') {
        // Provider.of<InboxProvider>(context, listen: false).resetMessageCount();
        prefs.clear();
        // reset the isAppFirstStart after clear all
        prefs.setBool('isAppFirstStart', true);
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

  /// Refresh new token when app is opened.
  /// Using refreshToken API.
  Future<void> refreshTokenProvider() async {
    final prefs = await SharedPreferences.getInstance();
    final storage = new FlutterSecureStorage();

    String? siocToken = await storage.read(key: 'siocToken');
    String? sarawakToken = await storage.read(key: 'sarawakToken');

    var response = await _authServices.refreshToken(
      sarawakToken: sarawakToken,
      siocToken: siocToken,
    );
    if (response['status'] == '200') {
      prefs.setInt(
          "expire", response['data']['expire'] * 1000 + currentMilliSec);
    }
  }

  // http://124.70.29.113:28300/loading.html?sarawakToken=159952acea21cbb45844594aa9ad4485&isSubscribed=false&userId=22569&siocToken=eyJhbGciOiJSUzI1NiJ9.eyJzdWIiOiIyMjU2OSIsInVzZXJJZCI6IjEwMDIwNDU2MDciLCJuYW1lIjoiWmhvbmdMaWFuZ1dhbmciLCJleHAiOjE3MTI1NjI3MjQsImlhdCI6MTcxMTI2NjcyNH0.jx0vxGVxhVShHDsVgaDOPm1Zey_y5OZ9b0pKUK2YfbOvsGNTEH2aKPqp-0z7WmQdNhzCnS07fnJ3YOHmdrOJsCx1rzzw4MPPnn0gD2-N_OBbdTbD21xzacXViANqTsFlhxJYW0py1Q5KMsmuylufHt79w52qWesf8t1g1Rlv8l0&expire=1296000&loginMode=1
  // "isSubscribed" param not used by backend anymore
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
          vipStatus: response['data']['vipStatus'] == "1",
          vipDueDate: response['data']['vipDueDate'] ?? '',
        );
        prefs.setString("userEmail", response['data']['email'] ?? '');
        prefs.setString("userFullName", response['data']['nickName'] ?? '');
        prefs.setString("userId", response['data']['memberId'] ?? '');
        prefs.setString("userMobileNo", response['data']['mobile'] ?? '');
        prefs.setString("userShortName", response['data']['sarawakId'] ?? '');
        prefs.setString("userResAddr1", response['data']['address'] ?? '');
        prefs.setBool("vipStatus", response['data']['vipStatus'] == "1");
        // double assure in case vipDueDate is not insert into prefs in "signInProvider" due to "isSubscribed" == false
        prefs.setString("vipDueDate", response['data']['vipDueDate'] ?? '');

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
          vipStatus: false,
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

  /// Get user information after subscription payment.
  /// Using queryUserInfo API.
  ///
  /// Return 'true' if query API is successful.
  /// Return 'false' if query API is failed.
  Future<bool> queryUserInfoAfterSubscriptionProvider() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      String memberId = prefs.getString('userId') ?? '';
      var response = await _authServices.queryUserInfo(memberId);
      if (response['status'] == '200') {
        _auth = AuthModel(
          address: prefs.getString('userResAddr1') ?? '',
          mobile: prefs.getString('userMobileNo') ?? '',
          email: prefs.getString('userEmail') ?? '',
          sId: prefs.getString('userId') ?? '',
          userName: prefs.getString('userShortName') ?? '',
          fullName: prefs.getString('userFullName') ?? '',
          vipStatus: response['data']['vipStatus'] == "1",
          vipDueDate: response['data']['vipDueDate'] ?? '',
        );
        prefs.setBool("vipStatus", response['data']['vipStatus'] == "1");
        prefs.setString("vipDueDate", response['data']['vipDueDate'] ?? '');
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('queryUserInfoAfterSubscriptionProvider fail: ${e.toString()}');
      throw e;
    }
  }

  /// Check expiry of token when app is opened.
  ///
  /// Return 'true' if does not exceeds valid refresh period.
  /// And refresh new token.
  /// Return 'false' if exceeds valid refresh period.
  /// And sign out.
  Future<bool> checkIsAuthAndSubscribeOverdue(BuildContext context) async {
    bool isTokenOk = false;
    final prefs = await SharedPreferences.getInstance();
    final storage = new FlutterSecureStorage();

    String? siocToken = await storage.read(key: 'siocToken');
    String? sarawakToken = await storage.read(key: 'sarawakToken');
    int? expire = prefs.getInt('expire');

    print("siocTokenLocal: $siocToken");
    print("sarawakTokenLocal: $sarawakToken");
    print("expireLocal: $expire");

    if (expire != null &&
        !expire.isNaN &&
        siocToken != null &&
        siocToken.isNotEmpty &&
        sarawakToken != null &&
        sarawakToken.isNotEmpty) {
      if (currentMilliSec > expire) {
        print("Sign out due to exceeds valid refresh period");
        signOutProvider(context);
      } else {
        // If within valid refresh period, then refresh token (everytime open app)
        // TODO: refresh token
        // refreshTokenProvider();
        isTokenOk = true;
        bool subscriptionOverdueStatus = await checkSubscribeOverdue();

        // TODO: FIRST => check _isSubscriptionEnabled
        // _isSubscriptionEnabled = true;

        // TODO: SECOND => check _isWhitelisted
        // _isWhitelisted = true;

        // THIRD => check subscription date
        if (subscriptionOverdueStatus) {
          // within due date
          _auth = AuthModel(
              address: prefs.getString('userResAddr1') ?? '',
              mobile: prefs.getString('userMobileNo') ?? '',
              email: prefs.getString('userEmail') ?? '',
              sId: prefs.getString('userId') ?? '',
              userName: prefs.getString('userShortName') ?? '',
              fullName: prefs.getString('userFullName') ?? '',
              vipStatus: prefs.getBool('vipStatus') ?? false,
              vipDueDate: prefs.getString('vipDueDate') ?? '');
        } else {
          // out of due date (expired)
          prefs.setBool("vipStatus", false);
          prefs.setString("vipDueDate", '');
          _auth = AuthModel(
            address: prefs.getString('userResAddr1') ?? '',
            mobile: prefs.getString('userMobileNo') ?? '',
            email: prefs.getString('userEmail') ?? '',
            sId: prefs.getString('userId') ?? '',
            userName: prefs.getString('userShortName') ?? '',
            fullName: prefs.getString('userFullName') ?? '',
            vipStatus: false,
            vipDueDate: '',
          );
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
  Future<bool> checkSubscribeOverdue() async {
    final prefs = await SharedPreferences.getInstance();
    String? vipDueDate = prefs.getString('vipDueDate');

    if (vipDueDate == '' || vipDueDate!.isEmpty) return false;

    if (DateTime.parse(vipDueDate).isAfter(DateTime.now())) {
      return true;
    } else {
      return false;
    }
  }
}
