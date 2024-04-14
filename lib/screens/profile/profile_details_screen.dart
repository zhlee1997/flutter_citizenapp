import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../models/auth_model.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_localization.dart';
import '../../utils/global_dialog_helper.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/settings_provider.dart';

class ProfileDetailsScreen extends StatefulWidget {
  static const String routeName = 'profile-details-screen';

  const ProfileDetailsScreen({super.key});

  @override
  State<ProfileDetailsScreen> createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen> {
  late TapGestureRecognizer? _tapGestureRecognizer;

  late String _username;
  late String _fullName;
  late bool _isSubscribe;
  String? _emailAddress;
  String? _mobile;
  String? _address;
  String? _profileImage;
  String? _identityNumber;
  late AuthModel _authData;
  String? _vipDueDate;

  /// Launch Sarawak ID Website when tap on 'Sarawak ID' link
  void _handleLaunchWebsite() {
    final Uri uri =
        Uri.parse("https://sarawakid-tnt.sarawak.gov.my/web/ssov1/login/");
    launchUrl(uri);
  }

  // TODO: refresh profile (new Update API)
  Future<void> _refreshProfile() async {
    await GlobalDialogHelper().showAlertDialog(
      context: context,
      yesButtonFunc: () async {
        try {
          Navigator.of(context).pop();
          GlobalDialogHelper().buildCircularProgressWithTextCenter(
              context: context, message: "Refreshing Profile");
          bool success = await Provider.of<AuthProvider>(context, listen: false)
              .updateProfileInfoProvider();
          if (success) {
            Navigator.of(context).pop();
            Fluttertoast.showToast(msg: "Profile refresh successfully");
          } else {
            Navigator.of(context).pop();
            Fluttertoast.showToast(msg: "Unable to refresh profile");
          }
        } catch (e) {
          print("_refreshProfile error: ${e.toString()}");
          Navigator.of(context).pop();
          Fluttertoast.showToast(msg: "Error in refreshing profile");
        }
      },
      title: "Refresh Profile",
      message:
          "Your profile information will be updated to the latest and old info may be replaced. Are you sure to proceed?",
    );
  }

  String formatDate(DateTime date) {
    return DateFormat('dd MMMM yyyy').format(date);
  }

  String returnPackageName(String packageName) {
    switch (packageName) {
      case "option_1":
        return "30-days Premium Subscription";
      case "option_2":
        return "90-days Premium Subscription";
      default:
        return "365-days Premium Subscription";
    }
  }

  Future<void> getSubscriptionPackageOption() async {
    GlobalDialogHelper().buildCircularProgressCenter(context: context);
    try {
      var response =
          await Provider.of<SubscriptionProvider>(context, listen: false)
              .querySubscriptionPackageOptionProvider();
      if (response.isNotEmpty) {
        Navigator.of(context).pop();
        showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: Text("Subscription Info"),
              content: Text(
                  "Your current subscription package is ${returnPackageName(response)}."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        Navigator.of(context).pop();
        Fluttertoast.showToast(msg: "No result");
      }
    } catch (e) {
      Navigator.of(context).pop();
      print("getSubscriptionPackageOption: ${e.toString()}");
    }
  }

  @override
  void initState() {
    _tapGestureRecognizer = TapGestureRecognizer()
      ..onTap = _handleLaunchWebsite;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _authData = Provider.of<AuthProvider>(context).auth;
    _vipDueDate = _authData.vipDueDate ?? '---';
    _username = _authData.userName;
    _fullName = _authData.fullName;
    _isSubscribe = _authData.vipStatus;
    _emailAddress = _authData.email;
    _mobile = _authData.mobile;
    _address = _authData.address;
    _profileImage = _authData.profileImage;
    _identityNumber = _authData.identityNumber;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _tapGestureRecognizer!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text("Profile Details"),
        actions: <Widget>[
          IconButton(
            onPressed: _refreshProfile,
            icon: const Icon(Icons.refresh_outlined),
            tooltip: "Refresh profile",
          )
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            SizedBox(
              // TODO: to make it responsive
              height: 140 + 30,
              child: Stack(
                children: <Widget>[
                  Image.asset(
                    "assets/images/pictures/kuching_city.jpeg",
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.fill,
                    opacity: const AlwaysStoppedAnimation(0.85),
                  ),
                  Positioned(
                    top: 90.0,
                    left: 20.0,
                    right: 20.0,
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(
                        top: 10.0,
                        bottom: 10.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              _profileImage != null && _profileImage!.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(32.5),
                                      child: CachedNetworkImage(
                                        fit: BoxFit.cover,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.18,
                                        height:
                                            MediaQuery.of(context).size.width *
                                                0.18,
                                        placeholder: (BuildContext context,
                                                String url) =>
                                            Container(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                          padding: const EdgeInsets.all(8.0),
                                          child: const CircularProgressIndicator
                                              .adaptive(
                                            strokeWidth: 2.0,
                                          ),
                                        ),
                                        imageUrl: _profileImage!,
                                        errorWidget: (context, url, error) =>
                                            Container(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                          child: const Icon(
                                            Icons.error_outline,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    )
                                  : CircleAvatar(
                                      radius: 32.5,
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      child: const CircleAvatar(
                                        radius: 30,
                                        child: Icon(
                                          Icons.person_outline,
                                          size: 35,
                                        ),
                                      ),
                                    ),
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.star,
                                  color: Colors.white,
                                  size: 12.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _fullName,
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_isSubscribe)
                  GestureDetector(
                    onTap: getSubscriptionPackageOption,
                    child: Lottie.asset(
                      "assets/animations/lottie_premium.json",
                      width: MediaQuery.of(context).size.width * 0.125,
                      height: MediaQuery.of(context).size.width * 0.125,
                      fit: BoxFit.fill,
                    ),
                  )
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            _isSubscribe
                ? Container()
                : ActionChip(
                    side: BorderSide(
                      color: Theme.of(context).primaryColor,
                    ),
                    avatar: Icon(
                      Icons.verified_user,
                      color: Theme.of(context).primaryColor,
                    ),
                    label: Text(
                      "Get Premium",
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.background,
                    onPressed: () {
                      // Navigator.of(context)
                      //     .pushNamed(SubscribeScreen.routeName);
                    },
                  ),
            if (_isSubscribe)
              Container(
                margin: const EdgeInsets.symmetric(
                  vertical: 5.0,
                  horizontal: 10.0,
                ),
                child: ListTile(
                  minVerticalPadding: 15.0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  title: const Text(
                    "Subscription Due Date:",
                  ),
                  subtitle: Container(
                    margin: EdgeInsets.only(
                      top: screenSize.width * 0.015,
                    ),
                    child: Text(
                      _vipDueDate != null
                          ? formatDate(DateTime.parse(_vipDueDate!))
                          : "---",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            Container(
              margin: const EdgeInsets.symmetric(
                vertical: 5.0,
                horizontal: 10.0,
              ),
              child: ListTile(
                minVerticalPadding: 15.0,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                title: const Text(
                  "Sarawak ID:",
                ),
                subtitle: Container(
                  margin: EdgeInsets.only(
                    top: screenSize.width * 0.015,
                  ),
                  child: Text(
                    _username,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(
                vertical: 5.0,
                horizontal: 10.0,
              ),
              child: ListTile(
                minVerticalPadding: 15.0,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                title: const Text(
                  "MyKad Number:",
                ),
                subtitle: Container(
                  margin: EdgeInsets.only(
                    top: screenSize.width * 0.015,
                  ),
                  child: Text(
                    _identityNumber!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(
                vertical: 5.0,
                horizontal: 10.0,
              ),
              child: ListTile(
                minVerticalPadding: 15.0,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                title: Text(
                  "${AppLocalization.of(context)!.translate('email_add')!}:",
                ),
                subtitle: Container(
                  margin: EdgeInsets.only(
                    top: screenSize.width * 0.015,
                  ),
                  child: Text(
                    '$_emailAddress',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(
                vertical: 5.0,
                horizontal: 10.0,
              ),
              child: ListTile(
                minVerticalPadding: 15.0,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                title: Text(
                  "${AppLocalization.of(context)!.translate('mobile_num')!}:",
                ),
                subtitle: Container(
                  margin: EdgeInsets.only(
                    top: screenSize.width * 0.015,
                  ),
                  child: Text(
                    '$_mobile',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(
                vertical: 5.0,
                horizontal: 10.0,
              ),
              child: ListTile(
                minVerticalPadding: 15.0,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                title: Text(
                  "${AppLocalization.of(context)!.translate('address')!}:",
                ),
                subtitle: Container(
                  margin: EdgeInsets.only(
                    top: screenSize.width * 0.015,
                  ),
                  child: Text(
                    '$_address',
                    softWrap: true,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    // text: AppLocalization.of(context)!.translate('to_edit')!,
                    text: "To edit profile, visit ",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                    text: 'Sarawak ID website',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    recognizer: _tapGestureRecognizer,
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Consumer<AuthProvider>(
              builder: (BuildContext ctx, AuthProvider authProvider, child) {
                if (authProvider.isAuth &&
                    authProvider.auth.fullName.isNotEmpty &&
                    authProvider.auth.email!.isNotEmpty) {
                  return TextButton(
                    onPressed: () {
                      GlobalDialogHelper().showAlertDialog(
                        context: context,
                        title:
                            AppLocalization.of(context)!.translate('logout')!,
                        message: AppLocalization.of(context)!
                            .translate('do_you_logout')!,
                        yesButtonFunc: () async {
                          Navigator.of(context).pop();
                          Future.delayed(Duration.zero, () {
                            GlobalDialogHelper()
                                .buildCircularProgressWithTextCenter(
                              context: context,
                              message: AppLocalization.of(context)!
                                  .translate('logging_out')!,
                            );
                            authProvider
                                .signOutProvider(context)
                                .then((bool isLogoutSuccess) async {
                              if (isLogoutSuccess) {
                                // when logout success, set push notification to true (local, back to default)
                                Provider.of<SettingsProvider>(context,
                                        listen: false)
                                    .enablePushNotification();
                                Navigator.of(context).popUntil(
                                    ModalRoute.withName('home-page-screen'));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Container(
                                      padding: const EdgeInsets.all(10.0),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primaryContainer,
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(10.0),
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "Logout successfully",
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: Colors.transparent,
                                    elevation: 0,
                                  ),
                                );
                              } else {
                                Navigator.of(context).pop();
                              }
                            });
                          });
                        },
                      );
                    },
                    child: const Text(
                      "Log Out",
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.red,
                      ),
                    ),
                  );
                } else {
                  return Container();
                }
              },
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
