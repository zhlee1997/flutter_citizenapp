import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import './bill_payment_checkout_screen.dart';
import '../../widgets/bill_payment/qr_scanner_overlay.dart';

class BillPaymentScanScreen extends StatefulWidget {
  const BillPaymentScanScreen({super.key});
  static const String routeName = 'bill-payment-scan-screen';

  @override
  State<BillPaymentScanScreen> createState() => _BillPaymentScanScreenState();
}

class _BillPaymentScanScreenState extends State<BillPaymentScanScreen> {
  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [BarcodeFormat.qrCode],
  );

  void onDetect(
    BarcodeCapture barcodeCapture,
    Map<String, String> paymentDetail,
    BuildContext context,
  ) {
    print("QR detected: ${barcodeCapture.raw}");
    var biller = paymentDetail["text"];

    final String code = barcodeCapture.barcodes.first.rawValue ?? '';

    if (code.isNotEmpty) {
      if (code.startsWith("SARAWAKPAYBILLS")) {
        List<String> semiColonSplit = code.split(";");
        var billerReceipt = semiColonSplit[1].split(":")[1].trim();
        print(semiColonSplit.toString());

        if (biller != billerReceipt) {
          Fluttertoast.showToast(
            msg: 'Incorrect biller. Please try again.',
          );
          return;
        }

        var accountNumber = semiColonSplit[3].split(":")[1];
        print(accountNumber);
        var totalDue = semiColonSplit[7].split(":")[1].trim();
        print(totalDue);

        if (accountNumber.isNotEmpty && totalDue.isNotEmpty) {
          Map map = {"Kuching Water Board": '4', "Sarawak Energy": '5'};
          var arg = {
            'stateName': map[biller],
            'taxCode': accountNumber,
            'orderAmount': totalDue
          };
          //
          controller.dispose();
          Navigator.pushReplacementNamed(
            context,
            BillPaymentCheckoutScreen.routeName,
            arguments: arg,
          );
        }
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller.start();
  }

  @override
  Widget build(BuildContext context) {
    final paymentDetail =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    final scanWindow = Rect.fromCenter(
      center: MediaQuery.sizeOf(context).center(Offset.zero),
      width: 200,
      height: 200,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Bill Scan')),
      body: MobileScanner(
        onDetect: (BarcodeCapture capture) =>
            onDetect(capture, paymentDetail, context),
        fit: BoxFit.contain,
        scanWindow: scanWindow,
        controller: controller,
        overlay: QRScannerOverlay(
          overlayColour: Colors.black.withOpacity(0.4),
        ),
        // errorBuilder: (context, error, child) {
        //   return ScannerErrorWidget(error: error);
        // },
      ),
    );
  }
}
