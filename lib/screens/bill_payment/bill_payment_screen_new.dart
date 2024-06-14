import 'dart:io';

import 'package:flutter/material.dart';

import '../../widgets/bill_payment/payment_logo.dart';
import '../../screens/bill_payment/bill_payment_detail_screen.dart';
import '../../utils/app_localization.dart';

class BillPaymentScreenNew extends StatelessWidget {
  static const routeName = 'bill-payment-screen-new';

  const BillPaymentScreenNew({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalization.of(context)!.translate('bill_payment')!),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ListTile(
              leading: Icon(
                Icons.electric_bolt_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text("Sarawak Energy"),
              trailing: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 15.0,
                color: Theme.of(context).colorScheme.primary,
              ),
              onTap: () => Navigator.of(context).pushNamed(
                BillPaymentDetailScreen.routeName,
                arguments: {
                  'title': "Other Utilities",
                  'imageUrl': 'assets/images/icon/sarawak-energy.png',
                  'text': 'Sarawak Energy',
                },
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.water_drop_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text("Kuching Water Board"),
              trailing: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 15.0,
                color: Theme.of(context).colorScheme.primary,
              ),
              onTap: () => Navigator.of(context).pushNamed(
                BillPaymentDetailScreen.routeName,
                arguments: {
                  'title': "Other Utilities",
                  'imageUrl': 'assets/images/icon/kwb.png',
                  'text': 'Kuching Water Board',
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
