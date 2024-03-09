import 'package:flutter/material.dart';

class BillPaymentDetailScreen extends StatefulWidget {
  static const String routeName = "bill-payment-detail-screen";

  const BillPaymentDetailScreen({super.key});

  @override
  State<BillPaymentDetailScreen> createState() =>
      _BillPaymentDetailScreenState();
}

class _BillPaymentDetailScreenState extends State<BillPaymentDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final paymentDetail =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(paymentDetail['title']!),
      ),
      body: Container(),
    );
  }
}
