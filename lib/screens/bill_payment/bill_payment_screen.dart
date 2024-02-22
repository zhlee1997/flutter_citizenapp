import 'dart:io';

import 'package:flutter/material.dart';

import '../../widgets/bill_payment/payment_logo.dart';
import '../../utils/app_localization.dart';

class BillPaymentScreen extends StatelessWidget {
  static const routeName = 'bill-payment-screen';

  const BillPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalization.of(context)!.translate('bill_payment')!),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.all(20.0),
              child: Text(
                AppLocalization.of(context)!.translate('assessment_rate')!,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            Container(
              child: GridView(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(
                  horizontal: Platform.isIOS ? 15.0 : 10.0,
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.5 / 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                children: <Widget>[
                  PaymentLogo(
                    AppLocalization.of(context)!.translate('assessment_rate')!,
                    'MPP',
                    'assets/images/icon/mpp.png',
                  ),
                  PaymentLogo(
                    AppLocalization.of(context)!.translate('assessment_rate')!,
                    'MBKS',
                    'assets/images/icon/mbks.png',
                  ),
                  PaymentLogo(
                    AppLocalization.of(context)!.translate('assessment_rate')!,
                    'DBKU',
                    'assets/images/icon/dbku.png',
                  ),
                ],
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.all(20.0),
              child: Text(
                "Utilities",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            Container(
              child: GridView(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(
                  horizontal: Platform.isIOS ? 15.0 : 10.0,
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.5 / 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                children: <Widget>[
                  PaymentLogo(
                    "Utilities",
                    'KWB',
                    'assets/images/icon/kwb.png',
                  ),
                  PaymentLogo(
                    "Utilities",
                    'SESCO',
                    'assets/images/icon/sarawak-energy.png',
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
