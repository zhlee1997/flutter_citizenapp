import 'package:flutter/material.dart';

import '../../widgets/subscription/subscription_result_widget.dart';
import './subscription_choose_screen.dart';

class SubscriptionResultScreen extends StatelessWidget {
  static const String routeName = 'subscribe-result-screen';

  const SubscriptionResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text("Receipt"),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SubscriptionResultWidget(),
            Divider(),
            SizedBox(
              height: screenSize.height * 0.01,
            ),
            Text("PAYMENT DETAILS"),
            SizedBox(
              height: 10.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("Receipt Number"),
                Text(
                  "64953501",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
            SizedBox(
              height: 5.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("Paid Amount"),
                Text(
                  "RM 136.75",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
            SizedBox(
              height: 5.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("Payment Item"),
                Text(
                  "1-month Subscripion",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
            SizedBox(
              height: 5.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("Payment Date"),
                Text(
                  "03 Mar, 2024",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
            SizedBox(
              height: 5.0,
            ),
            Row(
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
            SizedBox(
              height: 5.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("Reference Number"),
                Text(
                  "20240303094410103",
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
                "You are now a Premium member!",
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
            // SizedBox(
            //   height: screenSize.height * 0.025,
            // ),
            // Container(
            //   width: screenSize.width * 0.7,
            //   child: OutlinedButton(
            //     onPressed: () {
            //       Navigator.of(context).pushNamedAndRemoveUntil(
            //         SubscriptionChooseScreen.routeName,
            //         (route) => route.isFirst,
            //       );
            //     },
            //     style: ButtonStyle(
            //       side: MaterialStateProperty.all(
            //         BorderSide(
            //           color: Theme.of(context).primaryColor,
            //         ),
            //       ), // Set border color
            //     ),
            //     child: Text(
            //       "Watch now",
            //       style: TextStyle(
            //         fontSize: 18,
            //       ),
            //     ),
            //   ),
            // ),
            // const SizedBox(
            //   height: 10,
            // ),
            // Container(
            //   width: screenSize.width * 0.7,
            //   // height: screenSize.height * 0.075,
            //   child: OutlinedButton(
            //     onPressed: () {
            //       Navigator.of(context)
            //           .popUntil(ModalRoute.withName('home-page-screen'));
            //     },
            //     child: Text(
            //       "Back to home",
            //       style: TextStyle(
            //         fontSize: 18,
            //       ),
            //     ),
            //   ),
            // )
          ],
        ),
      ),
    );
  }
}
