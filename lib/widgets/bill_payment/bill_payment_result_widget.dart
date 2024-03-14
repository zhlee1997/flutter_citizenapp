import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class BillPaymentResultWidget extends StatelessWidget {
  const BillPaymentResultWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Column(
      children: <Widget>[
        Lottie.asset(
          'assets/animations/lottie_done.json',
          width: screenSize.width * 0.5,
          height: screenSize.width * 0.5,
          repeat: false,
        ),
        Text(
          "Thank you!",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Text(
          "We have received your payment.",
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(
          height: 10.0,
        ),
        const Text(
          "Your payment will be reflected within 1 hour.",
          style: TextStyle(
            color: Colors.black54,
          ),
        )
      ],
    );
  }
}
