import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/subscription/subscription_result_widget.dart';
import './subscription_choose_screen.dart';
import '../../arguments/subscription_result_screen_arguments.dart';
import '../../utils/app_localization.dart';
import '../../providers/subscription_provider.dart';

class SubscriptionResultScreen extends StatelessWidget {
  static const String routeName = 'subscribe-result-screen';

  const SubscriptionResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments
        as SubscriptionResultScreenArguments;
    // determine successful or fail transaction
    // payResult['orderAmt'], payResult['orderDate']
    final bool isSuccessful = args.orderStatus == '1';
    final SubscriptionProvider subscriptionProvider =
        Provider.of<SubscriptionProvider>(context, listen: false);
    final screenSize = MediaQuery.of(context).size;

    if (!isSuccessful) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                ),
                child: Icon(
                  Icons.cancel_sharp,
                  color: Colors.white,
                  size: 70,
                ),
              ),
              SizedBox(
                height: screenSize.height * 0.025,
              ),
              Text(
                "Failed Subscription",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(
                height: screenSize.height * 0.025,
              ),
              Text(
                "Your subscription was unsuccessful.\nPlease try again.",
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: screenSize.height * 0.025,
              ),
              SizedBox(
                width: screenSize.width * 0.7,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .popUntil(ModalRoute.withName('home-page-screen'));
                  },
                  child: Text(
                    AppLocalization.of(context)!.translate('done')!,
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Subscription Receipt"),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SubscriptionResultWidget(),
            const Divider(),
            SizedBox(
              height: screenSize.height * 0.01,
            ),
            const Text("PAYMENT DETAILS"),
            const SizedBox(
              height: 10.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("Receipt Number"),
                Text(
                  subscriptionProvider.receiptNumber,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 5.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text("Paid Amount"),
                Text(
                  "RM ${args.orderAmt}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 5.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("Payment Item"),
                Text(
                  subscriptionProvider.paymentItem,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 5.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text("Payment Date"),
                Text(
                  // "03 Mar, 2024",
                  args.orderDate ?? "",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 5.0,
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("Payment Method"),
                Text(
                  "S Pay Global",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 5.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("Reference Number"),
                Text(
                  subscriptionProvider.referenceNumber.substring(0, 9),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
            SizedBox(
              height: screenSize.height * 0.03,
            ),
            MaterialBanner(
              elevation: 5.0,
              leading: Icon(Icons.wallet_membership_outlined),
              content: Text(
                "You are now a Premium member! Would you like to?",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context)
                        .popUntil(ModalRoute.withName('home-page-screen'));
                  },
                  child: Text(
                    "Back to home",
                    style: TextStyle(
                      fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      SubscriptionChooseScreen.routeName,
                      (route) => route.isFirst,
                    );
                  },
                  child: Text(
                    "Watch now",
                    style: TextStyle(
                      fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
