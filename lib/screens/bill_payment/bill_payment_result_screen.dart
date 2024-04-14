import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/bill_payment/bill_payment_result_widget.dart';
import '../transaction/transaction_history_screen.dart';
import '../../arguments/bill_payment_result_screen_arguments.dart';
import '../../utils/app_localization.dart';
import '../../providers/bill_provider.dart';
import '../../providers/inbox_provider.dart';

class BillPaymentResultScreen extends StatelessWidget {
  static const String routeName = "bill-payment-result-screen";

  const BillPaymentResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments
        as BillPaymentResultScreenArguments;
    // determine successful or fail transaction
    // payResult['orderAmt'], payResult['orderDate']
    final bool isSuccessful = args.orderStatus == '1';
    final BillProvider billProvider =
        Provider.of<BillProvider>(context, listen: false);
    final screenSize = MediaQuery.of(context).size;

    if (!isSuccessful) {
      return PopScope(
        canPop: false,
        child: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                  child: Icon(
                    Icons.cancel_sharp,
                    color: Colors.white,
                    size: 70,
                  ),
                ),
                SizedBox(
                  height: screenSize.height * 0.025,
                ),
                Text(
                  AppLocalization.of(context)!.translate('fail_transact')!,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(
                  height: screenSize.height * 0.025,
                ),
                Text(AppLocalization.of(context)!
                        .translate('your_payment_fail')! +
                    ". Please try again."),
                SizedBox(
                  height: screenSize.height * 0.025,
                ),
                SizedBox(
                  width: screenSize.width * 0.7,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context)
                          .popUntil(ModalRoute.withName('home-page-screen'));
                    },
                    child: Text(
                      AppLocalization.of(context)!.translate('done')!,
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Bill Receipt"),
          automaticallyImplyLeading: false,
          centerTitle: true,
        ),
        body: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const BillPaymentResultWidget(),
              const Divider(),
              SizedBox(
                height: screenSize.height * 0.01,
              ),
              const Text("PAYMENT DETAILS"),
              const SizedBox(
                height: 10.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text("Receipt Number"),
                  Text(
                    billProvider.receiptNumber,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 5.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text("Paid Amount"),
                  Text(
                    "RM ${args.orderAmt}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 5.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text("Payment Item"),
                  Text(
                    billProvider.paymentItem,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 5.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text("Payment Date"),
                  Text(
                    // "03 Mar, 2024",
                    args.orderDate ?? "",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 5.0,
              ),
              const Row(
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
              const SizedBox(
                height: 5.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text("Reference Number"),
                  Text(
                    billProvider.referenceNumber.substring(0, 9),
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
                    Provider.of<InboxProvider>(context, listen: false)
                        .refreshCount();
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      TransactionHistoryScreen.routeName,
                      (route) => route.isFirst,
                    );
                  },
                  style: ButtonStyle(
                    side: MaterialStateProperty.all(
                      BorderSide(
                        color: Theme.of(context).primaryColor,
                      ),
                    ), // Set border color
                  ),
                  child: const Text(
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
                    Provider.of<InboxProvider>(context, listen: false)
                        .refreshCount();
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
      ),
    );
  }
}
