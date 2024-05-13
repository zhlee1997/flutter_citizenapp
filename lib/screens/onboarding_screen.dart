import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:device_info_plus/device_info_plus.dart';

import './home_screen.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

class OnboardingScreen extends StatefulWidget {
  static const String routeName = "onboarding-screen";

  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool isChecked = false;
  bool isPermissionChecked = false;
  String _url = "";

  Future<void> _handlePermissions(BuildContext context) async {
    Permission photoPermission = Permission.photos;
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt <= 32) {
        photoPermission = Permission.storage;
      } else {
        photoPermission = Permission.photos;
      }
    }
    try {
      // You can request multiple permissions at once.
      // TODO: Open Camera permission
      // TODO: Access to photo gallery permission
      Map<Permission, PermissionStatus> statuses = await [
        Permission.location,
        Permission.microphone,
        Permission.notification,
        Permission.camera,
        photoPermission,
      ].request();
      logger.d("Location permission: ${statuses[Permission.location]}");
      logger.d("Microphone permission: ${statuses[Permission.microphone]}");
      logger.d("Notification permission: ${statuses[Permission.notification]}");
      logger.d("Camera permission: ${statuses[Permission.camera]}");
      logger.d("Photo permission: ${statuses[photoPermission]}");
      Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
    } catch (e) {
      logger.d("handlePermission error: ${e.toString()}");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _url = "assets/disclaimer/security_disclaimer.md";
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return IntroductionScreen(
      pages: listPagesViewModel(screenSize),
      showNextButton: false,
      done: const Text("Done"),
      onDone: isChecked && isPermissionChecked
          ? () async {
              final prefs = await SharedPreferences.getInstance();

              // Permission handler and navigate to homescreen
              await _handlePermissions(context);
              // TODO: shared preferences => isAppFirstStart: true
              prefs.setBool('isAppFirstStart', true);
            }
          : () {
              Fluttertoast.showToast(msg: "Checkbox is required");
            },
    );
  }

  List<PageViewModel> listPagesViewModel(Size screenSize) => [
        PageViewModel(
          title: "Talikhidmat at your fingertips.",
          body:
              "Have easy access to the feedback services provided by Sarawak Government.",
          image: SvgPicture.asset(
            "assets/images/svg/onboarding/talikhidmat_onboard.svg",
            width: screenSize.width * 0.4,
            height: screenSize.width * 0.4,
            semanticsLabel: 'Talikhidmat Onboarding Logo',
          ),
        ),
        PageViewModel(
          title: "Premium app experience with subscriptions.",
          body:
              "Stay in control of what is happening in Kuching, through live streaming provided by us.",
          image: SvgPicture.asset(
            "assets/images/svg/onboarding/subscription_onboard.svg",
            width: screenSize.width * 0.4,
            height: screenSize.width * 0.4,
            semanticsLabel: 'Subcription Onboarding Logo',
          ),
        ),
        PageViewModel(
          title: "Emergency button to safeguard personal security.",
          body:
              "Send emergency request at ease, at anytime and at anywhere in Sarawak.",
          image: SvgPicture.asset(
            "assets/images/svg/onboarding/emergency_onboard.svg",
            width: screenSize.width * 0.4,
            height: screenSize.width * 0.4,
            semanticsLabel: 'Emergency Onboarding Logo',
          ),
        ),
        PageViewModel(
          title: "Pay your bills anytime, anywhere.",
          body:
              "Pay your assessment rate and other utility bills while at home, on holiday - whenever you want to.",
          image: SvgPicture.asset(
            "assets/images/svg/onboarding/bill_payment_onboard.svg",
            width: screenSize.width * 0.4,
            height: screenSize.width * 0.4,
            semanticsLabel: 'Bill Payment Onboarding Logo',
          ),
        ),
        PageViewModel(
          title: "PDPA Consent / Permissions",
          bodyWidget: Column(
            children: [
              Row(
                children: <Widget>[
                  Transform.scale(
                    scale: 1.2,
                    child: Checkbox(
                      value: isChecked, // Set the initial value of the checkbox
                      onChanged: (bool? value) {
                        // Handle checkbox state changes
                        setState(() {
                          isChecked = value ?? false;
                        });
                      },
                      activeColor: Theme.of(context).primaryColor,
                    ),
                  ),
                  Flexible(
                    child: RichText(
                        text: TextSpan(
                      text:
                          "By submitting this, you consent to the terms stated in ",
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'our Personal Data Privacy Statement',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Theme.of(context).primaryColor,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = (() {
                              showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                        content: FutureBuilder(
                                            future: rootBundle.loadString(_url),
                                            builder: (BuildContext context,
                                                AsyncSnapshot<String>
                                                    snapshot) {
                                              if (snapshot.hasData) {
                                                return SizedBox(
                                                  width: double.maxFinite,
                                                  height: double.maxFinite,
                                                  child: Markdown(
                                                    data: snapshot.data ?? "",
                                                  ),
                                                );
                                              }

                                              return const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              );
                                            }),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('OK'),
                                          ),
                                        ],
                                      ));
                            }),
                        ),
                        TextSpan(
                          text: '.',
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        )
                      ],
                    )),
                  ),
                ],
              ),
              SizedBox(
                height: 10.0,
              ),
              Row(
                children: <Widget>[
                  Transform.scale(
                    scale: 1.2,
                    child: Checkbox(
                      value:
                          isPermissionChecked, // Set the initial value of the checkbox
                      onChanged: (bool? value) {
                        // Handle checkbox state changes
                        setState(() {
                          isPermissionChecked = value ?? false;
                        });
                      },
                      activeColor: Theme.of(context).primaryColor,
                    ),
                  ),
                  Flexible(
                    child: RichText(
                        text: TextSpan(
                      text: "Kindly enable the ",
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'required mobile permissions ',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Theme.of(context).primaryColor,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = (() {
                              showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                        title: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              "Permissions",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headlineSmall,
                                            ),
                                            Text(
                                              "Allow permissions for a better experience",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelLarge!
                                                  .copyWith(
                                                    color: Colors.black45,
                                                  ),
                                            ),
                                          ],
                                        ),
                                        content: SizedBox(
                                          height: double.maxFinite,
                                          width: double.maxFinite,
                                          child: ListView(
                                            shrinkWrap: true,
                                            children: ListTile.divideTiles(
                                              context: context,
                                              tiles: [
                                                ListTile(
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                    horizontal: 8.0,
                                                    vertical: 8.0,
                                                  ),
                                                  leading: Icon(Icons
                                                      .camera_alt_outlined),
                                                  title: Text("Camera"),
                                                  subtitle: Text(
                                                    "This permission is required for capturing photos.",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .labelSmall!
                                                        .copyWith(
                                                          color: Colors.black45,
                                                        ),
                                                  ),
                                                ),
                                                ListTile(
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                    horizontal: 8.0,
                                                    vertical: 8.0,
                                                  ),
                                                  leading: Icon(Icons
                                                      .location_on_outlined),
                                                  title: Text("Location"),
                                                  subtitle: Text(
                                                    "This permission is required for capturing locations.",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .labelSmall!
                                                        .copyWith(
                                                          color: Colors.black45,
                                                        ),
                                                  ),
                                                ),
                                                ListTile(
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                    horizontal: 8.0,
                                                    vertical: 8.0,
                                                  ),
                                                  leading: Icon(
                                                      Icons.mic_none_outlined),
                                                  title: Text("Microphone"),
                                                  subtitle: Text(
                                                    "This permission is required for voice recording.",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .labelSmall!
                                                        .copyWith(
                                                          color: Colors.black45,
                                                        ),
                                                  ),
                                                ),
                                                ListTile(
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                    horizontal: 8.0,
                                                    vertical: 8.0,
                                                  ),
                                                  leading: Icon(Icons
                                                      .notifications_on_outlined),
                                                  title: Text("Notification"),
                                                  subtitle: Text(
                                                    "This permission is required for receiving notifications.",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .labelSmall!
                                                        .copyWith(
                                                          color: Colors.black45,
                                                        ),
                                                  ),
                                                ),
                                                ListTile(
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                    horizontal: 8.0,
                                                    vertical: 8.0,
                                                  ),
                                                  leading: Icon(Icons
                                                      .photo_library_outlined),
                                                  title: Text("Photos"),
                                                  subtitle: Text(
                                                    "This permission is required for accessing photo library.",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .labelSmall!
                                                        .copyWith(
                                                          color: Colors.black45,
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ).toList(),
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('OK'),
                                          ),
                                        ],
                                      ));
                            }),
                        ),
                        TextSpan(
                          text: 'for a smoother experience.',
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        )
                      ],
                    )),
                  ),
                ],
              ),
            ],
          ),
          image: SvgPicture.asset(
            "assets/images/svg/onboarding/permission_onboard.svg",
            width: screenSize.width * 0.4,
            height: screenSize.width * 0.4,
            semanticsLabel: 'News Onboarding Logo',
          ),
        )
      ];
}
