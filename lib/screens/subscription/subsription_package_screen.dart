import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../widgets/subscription/subscription_benefit_card.dart';
import '../../widgets/subscription/subscription_price_card.dart';
import '../../screens/subscription/subscription_checkout_screen.dart';

class SubscriptionPackageScreen extends StatefulWidget {
  static const String routeName = 'subscription-package-screen';

  const SubscriptionPackageScreen({super.key});

  @override
  State<SubscriptionPackageScreen> createState() =>
      _SubscriptionPackageScreenState();
}

class _SubscriptionPackageScreenState extends State<SubscriptionPackageScreen> {
  bool isChecked = false;
  String _url = "";

  void _handleNavigateToPaymentCheckoutScreen() =>
      Navigator.of(context).pushNamed(SubscriptionCheckoutScreen.routeName);

  // TODO: GET PACKAGE PRICE API
  Future<void> _getPackagePrice() async {}

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _url = "assets/disclaimer/security_disclaimer.md";
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Subscribe Now"),
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenSize.width * 0.05,
              vertical: screenSize.width * 0.02,
            ),
            child: const Text(
              "Get Premium access to all features, including the live city view in Kuching",
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(
              left: screenSize.width * 0.05,
              right: screenSize.width * 0.05,
            ),
            child: const Text(
              "This subscription grant you special access to the in-depth experience of the Kuching city in your mobile. All the benefits of the Premium access are listed below:",
              style: TextStyle(
                fontSize: 16.0,
                height: 1.5,
              ),
            ),
          ),
          const SubscriptionBenefitCard(
            contents: <String>[
              "Access to city view in live",
              "Improving camera experience",
              "Guaranteed privacy protection"
            ],
          ),
          const SubscriptionPriceCard(),
          const SizedBox(
            height: 15,
          ),
          SizedBox(
            width: screenSize.width * 0.9,
            height: Platform.isIOS
                ? screenSize.height * 0.05
                : screenSize.height * 0.05,
            child: ElevatedButton(
              onPressed: isChecked
                  ? () => _handleNavigateToPaymentCheckoutScreen()
                  : null,
              child: Text(
                "Continue",
                style: TextStyle(
                  letterSpacing: 1.0,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            padding: EdgeInsets.only(
              left: screenSize.width * 0.05,
              right: screenSize.width * 0.05,
            ),
            child: Row(
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
                    text: "By accepting this, I agree to the ",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                          text: 'Security Disclaimer',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Theme.of(context).primaryColor,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = (() {
                              showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                        title:
                                            const Text('Security Disclaimer'),
                                        content: FutureBuilder(
                                            future: rootBundle.loadString(_url),
                                            builder: (BuildContext context,
                                                AsyncSnapshot<String>
                                                    snapshot) {
                                              if (snapshot.hasData) {
                                                return Markdown(
                                                    data: snapshot.data ?? "");
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
                            }))
                    ],
                  )
                      // overflow: TextOverflow.ellipsis,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}