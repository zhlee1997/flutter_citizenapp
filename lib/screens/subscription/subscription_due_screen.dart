import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../profile/profile_details_screen.dart';

class SubscriptionDueScreen extends StatelessWidget {
  static const String routeName = "subscription-due-screen";

  const SubscriptionDueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SvgPicture.asset(
                "assets/images/svg/undraw_pending_payment.svg",
                width: screenSize.width * 0.4,
                height: screenSize.width * 0.4,
                semanticsLabel: 'Talikhidmat Onboarding Logo',
              ),
              SizedBox(
                height: screenSize.height * 0.05,
              ),
              Text(
                "Pending Subscription",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(
                height: screenSize.height * 0.05,
              ),
              SizedBox(
                width: screenSize.width * 0.8,
                child: Text(
                  "Something went wrong.\nDon't worries! The payment takes 24 hours to process automatically. You may check the subscription status below by refreshing the user profile or later.",
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                height: screenSize.height * 0.05,
              ),
              SizedBox(
                width: screenSize.width * 0.7,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.of(context).pushNamedAndRemoveUntil(
                    ProfileDetailsScreen.routeName,
                    (route) => route.isFirst,
                  ),
                  child: const Text(
                    "Refresh profile",
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                width: screenSize.width * 0.7,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context)
                      .popUntil(ModalRoute.withName('home-page-screen')),
                  child: const Text(
                    "Back to home",
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
