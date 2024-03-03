import 'package:flutter/material.dart';

import 'package:introduction_screen/introduction_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './home_screen.dart';

class OnboardingScreen extends StatelessWidget {
  static const String routeName = "onboarding-screen";

  const OnboardingScreen({super.key});

  Future<void> _handlePermissions(BuildContext context) async {
    // You can request multiple permissions at once.
    // TODO: Push Notification permission
    // TODO: Open Camera permission
    // TODO: Access to photo gallery permission
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.microphone,
    ].request();
    print("Location permission: ${statuses[Permission.location]}");
    print("Microphone permission: ${statuses[Permission.microphone]}");
    Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return IntroductionScreen(
      pages: listPagesViewModel(screenSize),
      showNextButton: false,
      done: const Text("Done"),
      onDone: () async {
        final prefs = await SharedPreferences.getInstance();

        // Permission handler and navigate to homescreen
        _handlePermissions(context);
        // TODO: shared preferences => isAppFirstStart: true
        prefs.setBool('isAppFirstStart', true);
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
          title: "Unlock the full experience.",
          body:
              "Press 'Done' and grant necessary permissions to enhance your app journey!",
          image: SvgPicture.asset(
            "assets/images/svg/onboarding/permission_onboard.svg",
            width: screenSize.width * 0.4,
            height: screenSize.width * 0.4,
            semanticsLabel: 'News Onboarding Logo',
          ),
        )
      ];
}
