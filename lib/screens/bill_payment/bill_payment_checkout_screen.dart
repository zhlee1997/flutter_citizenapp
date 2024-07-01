import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:slide_to_act/slide_to_act.dart';

import '../../providers/bill_provider.dart';
import '../../arguments/bill_payment_checkout_screen_arguments.dart';
import '../../utils/app_localization.dart';
import '../../utils/global_dialog_helper.dart';
import '../../utils/general_helper.dart';
import '../../services/bill_services.dart';
import '../../widgets/bill_payment/bill_payment_install_spay_bottom_modal.dart';
import '../bill_payment/bill_payment_due_screen.dart';

class BillPaymentCheckoutScreen extends StatefulWidget {
  static const String routeName = 'bill-payment-checkout-screen';

  const BillPaymentCheckoutScreen({super.key});

  @override
  State<BillPaymentCheckoutScreen> createState() =>
      _BillPaymentCheckoutScreenState();
}

class _BillPaymentCheckoutScreenState extends State<BillPaymentCheckoutScreen> {
  bool isChecked = false;
  final Map data = {};

  final BillServices _billServices = BillServices();

  static const platform = MethodChannel('com.sma.citizen_mobile/main');

  Future<void> showNeedInstallSPayBottomModal() async {
    await showModalBottomSheet(
      context: context,
      builder: (_) => const BillPaymentInstallSPayBottomModal(),
    );
  }

  /// Create and confirm order when paying through S Pay Global
  /// To get encrypted data from SIOC Backend
  /// Using createOrder and confirmOrder API
  Future<void> orderRequest(
    BuildContext context,
    BillPaymentCheckoutScreenArguments billPaymentCheckoutScreenArguments,
  ) async {
    try {
      if (billPaymentCheckoutScreenArguments.stateName == "4" ||
          billPaymentCheckoutScreenArguments.stateName == "5") {
        data['goodsName'] = "Utilities";
        // 3. 水电费
        data['goodsType'] = "3";
        // WE001. 水电 (Water&Elec)
        data['goodsCode'] = "WE001";
      }
      data["stateName"] = billPaymentCheckoutScreenArguments.stateName;
      data["orderAmount"] = billPaymentCheckoutScreenArguments.orderAmount;
      data["taxCode"] = billPaymentCheckoutScreenArguments.taxCode;
      data['goodsType'] = '1';
      data['goodsName'] = 'Assessment Rate';
      data['goodsCode'] = 'T001';
      data['goodsCnt'] = '1';
      data['orderDescription'] = 'Bill Payment';

      await _billServices.createBillOrder(data).then((response) async {
        if (response['status'] == '200') {
          // GET THE ORDER_ID FROM RESPONSE
          String orderId = response["data"];
          Provider.of<BillProvider>(context, listen: false)
              .setReferenceNumber(orderId);

          // obtain encrypted payment data API
          await _billServices.confirmBillOrder({
            "orderCodes": orderId,
            "payType": "1",
          }).then((res) async {
            // GET THE PAY_ID FROM RES
            String payId = res["message"];
            Provider.of<BillProvider>(context, listen: false)
                .setReceiptNumber(payId);

            if (res["status"] == '200') {
              await jumpPay(res['data'], context);
            } else {
              Navigator.of(context).pop(true);
              Fluttertoast.showToast(
                msg: AppLocalization.of(context)!.translate('payment_failed')!,
              );
              print('confirmBillOrder fail');
            }
          });
        } else {
          Navigator.of(context).pop(true);
          Fluttertoast.showToast(
            msg: AppLocalization.of(context)!.translate('payment_failed')!,
          );
          print('createBillOrder fail');
        }
      });
    } catch (e) {
      Navigator.of(context).pop(true);
      Fluttertoast.showToast(
        msg: AppLocalization.of(context)!.translate('payment_failed')!,
      );
      print('orderRequest fail');
    }
  }

  /// Calls the native methods of SPay SDK when encryption data is received
  /// And launch the SPay Mobile App for payment integration
  ///
  /// Receives [encryptionData] as the encrypted string from SIOC Backend
  /// Which will be sent to SPay Mobile App for subsequent payment
  Future<void> jumpPay(String encryptionData, BuildContext context) async {
    try {
      if (encryptionData.isEmpty) {
        Fluttertoast.showToast(
          msg: AppLocalization.of(context)!.translate('payment_failed')!,
        );
        return;
      }
      Navigator.of(context).pop(true);
      if (Platform.isAndroid) {
        var sendMap = <String, dynamic>{'dataString': encryptionData};
        await platform.invokeMethod('spayPlaceOrder', sendMap);
      } else if (Platform.isIOS) {
        var sendMap = <String, dynamic>{'dataString': encryptionData};
        await platform.invokeMethod('spayPlaceOrder', sendMap);
      }
    } catch (e) {
      Navigator.of(context).pop(true);
      Fluttertoast.showToast(
        msg: AppLocalization.of(context)!.translate('payment_failed')!,
      );
      print('jumpPay fail');
    }
  }

  String returnBillName(String stateName) {
    String temp;
    switch (stateName) {
      case "1":
        temp = "Assessment Rate - DBKU";
        Provider.of<BillProvider>(context, listen: false).setPaymentItem(temp);
        return temp;
      case "2":
        temp = "Assessment Rate - MBKS";
        Provider.of<BillProvider>(context, listen: false).setPaymentItem(temp);
        return temp;
      case "3":
        temp = "Assessment Rate - MPP";
        Provider.of<BillProvider>(context, listen: false).setPaymentItem(temp);
        return temp;
      case "4":
        temp = "Water Utility - KWB";
        Provider.of<BillProvider>(context, listen: false).setPaymentItem(temp);
        return temp;
      default:
        temp = "Electricity Utility - SESCO";
        Provider.of<BillProvider>(context, listen: false).setPaymentItem(temp);
        return temp;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final args = ModalRoute.of(context)!.settings.arguments
        as BillPaymentCheckoutScreenArguments;

    double formattedString = double.parse(args.orderAmount!);

    return Scaffold(
      appBar: AppBar(
        title: Text("Payment Checkout"),
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Container(
                    width: screenSize.width * 0.8,
                    margin: const EdgeInsets.symmetric(
                      vertical: 20.0,
                    ),
                    child: Text(
                      "Kindly check and verify the information below before proceed with payment",
                      style: TextStyle(
                        fontSize: 15.0,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  Container(
                    width: screenSize.width * 0.8,
                    padding: const EdgeInsets.all(15.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(10.0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 3,
                          blurRadius: 3,
                          offset:
                              const Offset(0, 4), // changes position of shadow
                        ),
                      ],
                    ),
                    child: DottedBorder(
                      color: Colors.grey.shade500,
                      strokeWidth: 1.0,
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text("Payment Item"),
                          Text(
                            returnBillName(args.stateName!),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
                          const SizedBox(
                            height: 15.0,
                          ),
                          const Text("Payment Account"),
                          Text(
                            args.taxCode!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
                          const SizedBox(
                            height: 15.0,
                          ),
                          const Text("Payment Amount"),
                          Text(
                            "RM ${formattedString.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
                          const SizedBox(
                            height: 15.0,
                          ),
                          const Text("Payment Method"),
                          const Text(
                            "S Pay Global",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                      left: screenSize.width * 0.07,
                      right: screenSize.width * 0.07,
                    ),
                    margin: const EdgeInsets.symmetric(
                      vertical: 20.0,
                    ),
                    child: Row(
                      children: <Widget>[
                        Transform.scale(
                          scale: 1.2,
                          child: Checkbox(
                            value:
                                isChecked, // Set the initial value of the checkbox
                            onChanged: (bool? value) {
                              // Handle checkbox state changes
                              setState(() {
                                isChecked = value ?? false;
                              });
                            },
                            activeColor: Theme.of(context).primaryColor,
                          ),
                        ),
                        const Flexible(
                          child: Text(
                              "I confirm that the information provided is valid and accurate."),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              Column(
                children: <Widget>[
                  Container(
                    width: screenSize.width * 0.8,
                    margin: const EdgeInsets.only(
                      bottom: 30.0,
                    ),
                    padding: const EdgeInsets.all(15.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(10.0)),
                    ),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            CircleAvatar(
                              backgroundColor:
                                  Theme.of(context).colorScheme.background,
                              radius: 16.0,
                              child: Icon(
                                Icons.tips_and_updates,
                                size: 18.0,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(
                              width: 10.0,
                            ),
                            const Text(
                              "Note",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 5.0,
                        ),
                        const Text(
                          "You are about to open the S Pay Global app. Please make sure the app is installed and have sufficient amount in the wallet.",
                          style: TextStyle(
                            fontSize: 13.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: screenSize.width * 0.8,
                    child: SlideAction(
                      height: 50,
                      innerColor: isChecked ? Colors.deepOrange : Colors.grey,
                      outerColor:
                          isChecked ? Colors.deepOrange[200] : Colors.grey[200],
                      sliderButtonIcon: Image.asset(
                        'assets/images/icon/spay-global.png',
                        width: 28,
                        height: 28,
                        fit: BoxFit.cover,
                      ),
                      text: "Slide to Pay",
                      textStyle: TextStyle(
                        color: isChecked ? Colors.white : Colors.black26,
                        fontSize: 18.0,
                      ),
                      sliderRotate: true,
                      enabled: isChecked,
                      elevation: 8.0,
                      onSubmit: () async {
                        // TODO: call subscription create/confirm API
                        // TODO: deeplink to S Pay Global for payment
                        // TODO: Android & iOS S PAY GLOBAL SDK
                        bool isAppInstalled =
                            await GeneralHelper.checkAppInstalled(
                          iOSPackageName: 'sarawakpay://merchantappscheme',
                          androidPackageName: 'my.gov.sarawak.paybills',
                        );
                        if (isAppInstalled) {
                          GlobalDialogHelper()
                              .buildCircularProgressWithTextCenter(
                            context: context,
                            message: AppLocalization.of(context)!
                                .translate('payment_in_progress')!,
                          );
                          orderRequest(context, args);
                        } else {
                          // Navigator.of(context).pop();
                          showNeedInstallSPayBottomModal();
                          // Fluttertoast.showToast(
                          //   msg: AppLocalization.of(context)!
                          //       .translate('please_install_spay')!,
                          // );
                        }
                      },
                    ),
                  ),
                  SizedBox(
                    height: screenSize.height * 0.05,
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
