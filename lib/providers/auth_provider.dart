import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import "../models/auth_model.dart";
import "../services/auth_services.dart";
import "../providers/inbox_provider.dart";
import '../utils/app_localization.dart';
import "../utils/general_helper.dart";

class AuthProvider with ChangeNotifier {
  AuthServices _authServices = AuthServices();

  int currentMilliSec = DateTime.now().millisecondsSinceEpoch;

  bool _isAuth = false;
  bool get isAuth => _isAuth;

  AuthModel? _auth;
  AuthModel? get auth => _auth;

  void removeAuthByForce() {
    _isAuth = false;
    _auth = null;
  }

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
        await prefs.setInt(
            'expire', int.parse(data['expire']!) * 1000 + currentMilliSec);
        await prefs.setString('userId', data['userId'] ?? '');

        // VIP due date
        // callback response URL will not have "vipDueDate" if "isSubscribed" is false
        // if (data['isSubscribed'] == 'true') {}

        await storage.write(
          key: 'siocToken',
          value: data['siocToken'] ?? '',
        );
        await storage.write(
          key: 'sarawakToken',
          value: data['sarawakToken'] ?? '',
        );
        return data;
      } else {
        // to ensure login atomicity when login failed
        await prefs.remove('expire');
        await prefs.remove('userId');
        await storage.delete(key: 'siocToken');
        await storage.delete(key: 'sarawakToken');
        _auth = null;
        return null;
      }
    } catch (e) {
      // to ensure login atomicity when login failed
      await prefs.remove('expire');
      await prefs.remove('userId');
      await storage.delete(key: 'siocToken');
      await storage.delete(key: 'sarawakToken');
      _auth = null;
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
      var response = await _authServices.signOut(
        sarawakToken: sarawakToken,
        siocToken: siocToken,
      );
      if (response['status'] == '200') {
        Provider.of<InboxProvider>(context, listen: false).resetMessageCount();
        prefs.clear();
        // reset the isAppFirstStart after clear all
        prefs.setBool('isAppFirstStart', true);
        await storage.deleteAll();
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
      storage.write(
        key: 'siocToken',
        value: response['data']['siocToken'] ?? '',
      );
      storage.write(
        key: 'sarawakToken',
        value: response['data']['sarawakToken'] ?? '',
      );
    }
  }

  // http://124.70.29.113:28300/loading.html?sarawakToken=159952acea21cbb45844594aa9ad4485&isSubscribed=false&userId=22569&siocToken=eyJhbGciOiJSUzI1NiJ9.eyJzdWIiOiIyMjU2OSIsInVzZXJJZCI6IjEwMDIwNDU2MDciLCJuYW1lIjoiWmhvbmdMaWFuZ1dhbmciLCJleHAiOjE3MTI1NjI3MjQsImlhdCI6MTcxMTI2NjcyNH0.jx0vxGVxhVShHDsVgaDOPm1Zey_y5OZ9b0pKUK2YfbOvsGNTEH2aKPqp-0z7WmQdNhzCnS07fnJ3YOHmdrOJsCx1rzzw4MPPnn0gD2-N_OBbdTbD21xzacXViANqTsFlhxJYW0py1Q5KMsmuylufHt79w52qWesf8t1g1Rlv8l0&expire=1296000&loginMode=1
  // TO DEV: "isSubscribed" param not used by backend anymore
  Future<bool> queryLoginUserInfo(String userId, bool isSubscribed) async {
    final prefs = await SharedPreferences.getInstance();
    final storage = new FlutterSecureStorage();

    try {
      var response = await _authServices.queryUserInfo(userId);
      // to handle 40101 error from backend
      String status = response['status'].toString();

      if (status == '200') {
        // User Information
        _auth = AuthModel(
          address: response['data']['address'] ?? '',
          mobile: response['data']['mobile'] ?? '',
          email: response['data']['email'] ?? '',
          profileImage: GeneralHelper.flavorFormatImageUrl(
              response['data']['facePhoto'] ?? ''),
          identityNumber: response['data']['ic'] ?? '',
          sId: response['data']['memberId'] ?? '',
          userName: response['data']['sarawakId'] ?? '',
          fullName: response['data']['nickName'] ?? '',
          vipStatus: response['data']['vipStatus'] == "1",
          vipDueDate: response['data']['vipDueDate'] ?? '',
        );
        prefs.setString("userEmail", response['data']['email'] ?? '');
        prefs.setString(
          "profileImage",
          GeneralHelper.flavorFormatImageUrl(
              response['data']['facePhoto'] ?? ''),
        );
        prefs.setString("identityNumber", response['data']['ic'] ?? '');
        prefs.setString("userFullName", response['data']['nickName'] ?? '');
        prefs.setString("userId", response['data']['memberId'] ?? '');
        prefs.setString("userMobileNo", response['data']['mobile'] ?? '');
        prefs.setString("userShortName", response['data']['sarawakId'] ?? '');
        prefs.setString("userResAddr1", response['data']['address'] ?? '');
        prefs.setBool("vipStatus", response['data']['vipStatus'] == "1");
        // double assure in case vipDueDate is not insert into prefs in "signInProvider" due to "isSubscribed" == false
        prefs.setString("vipDueDate", response['data']['vipDueDate'] ?? '');

        _isAuth = true;
        notifyListeners();
        return true;
      } else {
        // to ensure login atomicity when login failed
        await prefs.remove('expire');
        await prefs.remove('userId');
        await storage.delete(key: 'siocToken');
        await storage.delete(key: 'sarawakToken');
        _auth = null;
        _isAuth = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      // to ensure login atomicity when login failed
      await prefs.remove('expire');
      await prefs.remove('userId');
      await storage.delete(key: 'siocToken');
      await storage.delete(key: 'sarawakToken');
      _auth = null;
      _isAuth = false;
      notifyListeners();
      print('queryLoginUserInfo fail: ${e.toString()}');
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
          profileImage: prefs.getString('profileImage') ?? '',
          identityNumber: prefs.getString('identityNumber') ?? '',
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

    String? address = prefs.getString('userResAddr1');
    String? mobile = prefs.getString('userMobileNo');
    String? email = prefs.getString('userEmail');
    String? profileImage = prefs.getString('profileImage');
    String? identityNumber = prefs.getString('identityNumber');
    String? sId = prefs.getString('userId');
    String? userName = prefs.getString('userShortName');
    String? fullName = prefs.getString('userFullName');
    bool? vipStatus = prefs.getBool('vipStatus');
    String? vipDueDate = prefs.getString('vipDueDate');

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
        if (sId != null && userName != null && fullName != null) {
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
              address: address,
              mobile: mobile,
              email: email,
              profileImage:
                  GeneralHelper.flavorFormatImageUrl(profileImage ?? ""),
              identityNumber: identityNumber,
              sId: sId,
              userName: userName,
              fullName: fullName,
              vipStatus: vipStatus ?? false,
              vipDueDate: vipDueDate,
            );
          } else {
            // out of due date (subscription expired)
            _auth = AuthModel(
              address: address,
              mobile: mobile,
              email: email,
              profileImage:
                  GeneralHelper.flavorFormatImageUrl(profileImage ?? ''),
              identityNumber: identityNumber,
              sId: sId,
              userName: userName,
              fullName: fullName,
              vipStatus: false,
              vipDueDate: null,
            );
            prefs.setBool("vipStatus", false);
            prefs.setString("vipDueDate", '');
          }
        } else {
          print("Sign out due to SarawakID or name is empty");
          // to ensure login atomicity when login failed
          await prefs.remove('expire');
          await prefs.remove('userId');
          await storage.delete(key: 'siocToken');
          await storage.delete(key: 'sarawakToken');
          _isAuth = false;
          _auth = null;
          isTokenOk = false;
        }
      }
    } else {
      print("Sign out due to siocToken or sarawakToken is empty");
      // to ensure login atomicity when login failed
      await prefs.remove('expire');
      await prefs.remove('userId');
      await storage.delete(key: 'siocToken');
      await storage.delete(key: 'sarawakToken');
      _isAuth = false;
      _auth = null;
      isTokenOk = false;
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

  Future<bool> updateProfileInfoProvider() async {
    final storage = new FlutterSecureStorage();
    final prefs = await SharedPreferences.getInstance();

    String? sarawakToken = await storage.read(key: 'sarawakToken');
    String memberId = prefs.getString('userId') ?? '';
    String sarawakId = prefs.getString('userShortName') ?? '';
    String ic = prefs.getString('identityNumber') ?? '';

    try {
      var response = await _authServices.updateProfileInfo(
        sarawakToken: sarawakToken,
        memberId: memberId,
        sarawakId: sarawakId,
        ic: ic,
      );
      if (response["status"] == "200") {
        var refreshToken = response["data"]["refToken"] as String?;
        if (refreshToken != sarawakToken) {
          storage.write(
            key: 'sarawakToken',
            value: refreshToken ?? '',
          );
          print("refreshToken success. Able to update from SarawakID");
        } else {
          print("refreshToken similar. Unable to update from SarawakID");
        }

        _auth = AuthModel(
          address: response['data']['address'] ?? '',
          mobile: response['data']['mobile'] ?? '',
          email: response['data']['email'] ?? '',
          profileImage: GeneralHelper.flavorFormatImageUrl(
              response['data']['facePhoto'] ?? ''),
          identityNumber: response['data']['ic'] ?? '',
          sId: response['data']['memberId'] ?? '',
          userName: response['data']['sarawakId'] ?? '',
          fullName: response['data']['nickName'] ?? '',
          vipStatus: response['data']['vipStatus'] == "1",
          vipDueDate: response['data']['vipDueDate'] ?? '',
        );
        prefs.setString("userEmail", response['data']['email'] ?? '');
        prefs.setString(
          "profileImage",
          GeneralHelper.flavorFormatImageUrl(
              response['data']['facePhoto'] ?? ''),
        );
        prefs.setString("identityNumber", response['data']['ic'] ?? '');
        prefs.setString("userFullName", response['data']['nickName'] ?? '');
        prefs.setString("userId", response['data']['memberId'] ?? '');
        prefs.setString("userMobileNo", response['data']['mobile'] ?? '');
        prefs.setString("userShortName", response['data']['sarawakId'] ?? '');
        prefs.setString("userResAddr1", response['data']['address'] ?? '');
        prefs.setBool("vipStatus", response['data']['vipStatus'] == "1");
        prefs.setString("vipDueDate", response['data']['vipDueDate'] ?? '');

        notifyListeners();
        return true;
      }
    } catch (e) {
      print('updateProfileInfoProvider fail: ${e.toString()}');
      throw e;
    }
    return false;
  }
}
