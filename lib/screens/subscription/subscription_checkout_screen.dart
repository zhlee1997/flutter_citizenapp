import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:slide_to_act/slide_to_act.dart';

import '../../utils/app_localization.dart';

class SubscriptionCheckoutScreen extends StatelessWidget {
  static const String routeName = 'subscription-checkout-screen';

  const SubscriptionCheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment Checkout"),
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Container(
        alignment: Alignment.center,
        child: Column(
          children: <Widget>[
            Container(
              width: screenSize.width * 0.8,
              margin: const EdgeInsets.symmetric(
                vertical: 10.0,
              ),
              child: Text(
                "Note: Reminder to check and verify the payment details before making payment",
                style: TextStyle(
                  fontSize: 15.0,
                  color: Colors.grey[600],
                ),
              ),
            ),
            Container(
              width: screenSize.width * 0.8,
              padding: const EdgeInsets.all(15.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 3,
                    blurRadius: 3,
                    offset: const Offset(0, 4), // changes position of shadow
                  ),
                ],
              ),
              child: DottedBorder(
                color: Colors.grey.shade500,
                strokeWidth: 1.0,
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      child: const Text(
                        "Person Name",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17.0,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    const Text(
                      "Steven Bong",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17.0,
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    const Text(
                      "Sarawak ID",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17.0,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    const Text(
                      "12322398938",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17.0,
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    const Text(
                      "Payment Item",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17.0,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    const Text(
                      "3-month Premium Subscription",
                      style: TextStyle(
                        fontSize: 17.0,
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    const Text(
                      "Payment Amount",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17.0,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    const Text(
                      "RM 8.97",
                      style: TextStyle(
                        fontSize: 17.0,
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    const Text(
                      "Payment Method",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17.0,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    const Text(
                      "S Pay Global",
                      style: TextStyle(
                        fontSize: 17.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            SizedBox(
              width: screenSize.width * 0.8,
              child: SlideAction(
                height: 50,
                innerColor: Colors.deepOrange,
                outerColor: Colors.deepOrange[200],
                sliderButtonIcon: Image.asset(
                  'assets/images/icon/spay-global.png',
                  width: 28,
                  height: 28,
                  fit: BoxFit.cover,
                ),
                text: "Slide to Pay",
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                ),
                sliderRotate: true,
                onSubmit: () {
                  // deeplink to S Pay Global for payment
                },
              ),
            ),
            Container(
              width: screenSize.width * 0.8,
              margin: const EdgeInsets.only(
                top: 15.0,
              ),
              child: Text(
                "Note: This will open the S Pay Global app. Please make sure the app is installed and have sufficient amount in the wallet",
                style: TextStyle(
                  fontSize: 12.0,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
