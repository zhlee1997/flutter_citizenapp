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
              margin: const EdgeInsets.all(10.0),
              child: Text(
                AppLocalization.of(context)!.translate('assessment_rate')!,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            GridView(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(
                horizontal: Platform.isIOS ? 15.0 : 10.0,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1 / 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              children: <Widget>[
                PaymentLogo(
                  AppLocalization.of(context)!.translate('assessment_rate')!,
                  'Majlis Perbandaran Padawan',
                  'assets/images/icon/mpp.png',
                ),
                PaymentLogo(
                  AppLocalization.of(context)!.translate('assessment_rate')!,
                  'Majlis Bandaraya Kuching Selatan',
                  'assets/images/icon/mbks.png',
                ),
                PaymentLogo(
                  AppLocalization.of(context)!.translate('assessment_rate')!,
                  'Dewan Bandaraya Kuching Utara',
                  'assets/images/icon/dbku.png',
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Divider(),
            ),
            Container(
              margin: const EdgeInsets.all(10.0),
              child: Text(
                "Utilities",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            GridView(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(
                horizontal: Platform.isIOS ? 15.0 : 10.0,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1 / 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              children: const <Widget>[
                PaymentLogo(
                  "Utilities",
                  'Kuching Water Board',
                  'assets/images/icon/kwb.png',
                ),
                PaymentLogo(
                  "Utilities",
                  'Sarawak Energy',
                  'assets/images/icon/sarawak-energy.png',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
