import 'package:flutter/material.dart';

import '../../widgets/bill_payment/bill_payment_result_widget.dart';

class BillPaymentResultScreen extends StatelessWidget {
  static const String routeName = "bill-payment-result-screen";

  const BillPaymentResultScreen({super.key});

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
            const BillPaymentResultWidget(),
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
                  "Assessment Rate - DBKU",
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
            SizedBox(
              height: screenSize.height * 0.025,
            ),
            SizedBox(
              width: screenSize.width * 0.7,
              child: OutlinedButton(
                onPressed: () {
                  // Navigator.of(context).pushNamedAndRemoveUntil(
                  //   SubscriptionChooseScreen.routeName,
                  //   (route) => route.isFirst,
                  // );
                },
                style: ButtonStyle(
                  side: MaterialStateProperty.all(
                    BorderSide(
                      color: Theme.of(context).primaryColor,
                    ),
                  ), // Set border color
                ),
                child: Text(
                  "View transactions",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              width: screenSize.width * 0.7,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context)
                      .popUntil(ModalRoute.withName('home-page-screen'));
                },
                child: const Text(
                  "Back to home",
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
}
