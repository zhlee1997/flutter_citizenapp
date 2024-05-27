import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../transaction/transaction_history_screen.dart';

class BillPaymentDueScreen extends StatelessWidget {
  static const String routeName = "bill-payment-due-screen";

  const BillPaymentDueScreen({super.key});

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
                "Pending Transaction",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(
                height: screenSize.height * 0.05,
              ),
              SizedBox(
                width: screenSize.width * 0.8,
                child: Text(
                  "Something went wrong.\nDon't worries! The payment takes 24 hours to process automatically. You may check the payment status below or later.",
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
                    TransactionHistoryScreen.routeName,
                    (route) => route.isFirst,
                  ),
                  child: const Text(
                    "View transactions",
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
