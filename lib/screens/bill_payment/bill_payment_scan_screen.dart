import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';

import './bill_payment_checkout_screen.dart';

class BillPaymentScanScreen extends StatelessWidget {
  const BillPaymentScanScreen({super.key});
  static const String routeName = 'bill-payment-scan-screen';

  @override
  Widget build(BuildContext context) {
    final paymentDetail =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;

    return Scaffold(
      appBar: AppBar(title: const Text('QR Scanner')),
      // body: MobileScanner(
      //     // allowDuplicates: false,
      //     onDetect: (BarcodeCapture capture) {
      //   print("QR detected");
      //   print(capture.raw);
      //   var biller = paymentDetail["text"];

      //   if (capture.raw != null) {
      //     if (capture.raw!.startsWith("SARAWAKPAYBILLS")) {
      //       List<String> semiColonSplit = capture.raw!.split(";");
      //       var billerReceipt = semiColonSplit[1].split(":")[1].trim();
      //       print(semiColonSplit.toString());

      //       if (biller != billerReceipt) {
      //         Fluttertoast.showToast(
      //           msg: 'Incorrect biller. Please try again.',
      //         );
      //         return;
      //       }

      //       var accountNumber = semiColonSplit[3].split(":")[1];
      //       print(accountNumber);
      //       var totalDue = semiColonSplit[7].split(":")[1].trim();
      //       print(totalDue);

      //       if (accountNumber.isNotEmpty && totalDue.isNotEmpty) {
      //         Map map = {"Kuching Water Board": '4', "Sarawak Energy": '5'};
      //         var arg = {
      //           'stateName': map[biller],
      //           'taxCode': accountNumber,
      //           'orderAmount': totalDue
      //         };
      //         Navigator.pushReplacementNamed(
      //           context,
      //           BillPaymentCheckoutScreen.routeName,
      //           arguments: arg,
      //         );
      //       }
      //     }
      //   }
      // }),
    );
  }
}
