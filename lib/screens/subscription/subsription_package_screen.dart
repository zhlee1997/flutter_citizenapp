import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:shimmer/shimmer.dart';

import '../../widgets/subscription/subscription_benefit_card.dart';
import '../../widgets/subscription/subscription_price_card.dart';
import '../../screens/subscription/subscription_checkout_screen.dart';
import '../../arguments/subscription_checkout_screen.dart';
import '../../services/subscription_services.dart';

class SubscriptionPackageScreen extends StatefulWidget {
  static const String routeName = 'subscription-package-screen';

  const SubscriptionPackageScreen({super.key});

  @override
  State<SubscriptionPackageScreen> createState() =>
      _SubscriptionPackageScreenState();
}

class _SubscriptionPackageScreenState extends State<SubscriptionPackageScreen> {
  bool priceShimmer = false;
  bool isChecked = false;
  String _url = "";

  double oneMonthPrice = 0.00;
  double threeMonthPrice = 0.00;
  double twelveMonthPrice = 0.00;
  int selectedPackage = 0;
  double selectedPrice = 0.00;

  final SubscriptionServices _subscriptionServices = SubscriptionServices();

  void _handleNavigateToPaymentCheckoutScreen() =>
      Navigator.of(context).pushNamed(
        SubscriptionCheckoutScreen.routeName,
        arguments:
            SubscriptionCheckoutScreenArguments(selectedPackage, selectedPrice),
      );

  void handleSelectPackage(int index, double price) {
    setState(() {
      selectedPackage = index;
      selectedPrice = price;
    });
  }

  // TODO: GET PACKAGE PRICE API
  Future<void> _getPackagePrice() async {
    setState(() {
      priceShimmer = true;
    });
    try {
      var response =
          await _subscriptionServices.queryPackageAndSubscriptionEnable();
      if (response["status"] == "200") {
        List subscribeList = response["data"] as List;
        List filteredList = subscribeList
            .where((element) => element["subscribeCode"] == "Default")
            .toList();
        setState(() {
          oneMonthPrice = filteredList[0]["option_1"];
          threeMonthPrice = filteredList[0]["option_2"];
          twelveMonthPrice = filteredList[0]["option_3"];
          // First render set price
          selectedPrice = oneMonthPrice;
          priceShimmer = false;
        });
      }
    } catch (e) {
      print("getPackagePrice fail: ${e.toString()}");
      // TODO: current condition is error 502
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _url = "assets/disclaimer/security_disclaimer.md";
    _getPackagePrice();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Subscribe Now"),
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.width * 0.05,
                vertical: screenSize.width * 0.02,
              ),
              child: Text(
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
              child: Text(
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
            priceShimmer
                ? Shimmer.fromColors(
                    baseColor: Colors.white,
                    highlightColor: Colors.transparent,
                    child: SubscriptionPriceCard(
                      oneMonthPrice: 0,
                      threeMonthPrice: 0,
                      twelveMonthPrice: 0,
                      handleSelectPackage: (p0, p1) {},
                    ),
                  )
                : SubscriptionPriceCard(
                    oneMonthPrice: oneMonthPrice,
                    threeMonthPrice: threeMonthPrice,
                    twelveMonthPrice: twelveMonthPrice,
                    handleSelectPackage: handleSelectPackage,
                  ),
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
                child: const Text(
                  "Continue",
                  style: TextStyle(
                    letterSpacing: 1.0,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(
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
                      text: "By submitting this, you agree to the ",
                      style: const TextStyle(
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
                                          content: FutureBuilder(
                                              future:
                                                  rootBundle.loadString(_url),
                                              builder: (BuildContext context,
                                                  AsyncSnapshot<String>
                                                      snapshot) {
                                                if (snapshot.hasData) {
                                                  return Markdown(
                                                    data: snapshot.data ?? "",
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
                              }))
                      ],
                    )),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
