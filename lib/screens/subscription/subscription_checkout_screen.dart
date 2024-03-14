import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter_citizenapp/screens/subscription/subscription_result_screen.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../arguments/subscription_checkout_screen.dart';
import '../../services/subscription_services.dart';
import '../../providers/subscription_provider.dart';
import '../../utils/app_localization.dart';
import '../../utils/global_dialog_helper.dart';
import '../../utils/general_helper.dart';

class SubscriptionCheckoutScreen extends StatefulWidget {
  static const String routeName = 'subscription-checkout-screen';

  const SubscriptionCheckoutScreen({super.key});

  @override
  State<SubscriptionCheckoutScreen> createState() =>
      _SubscriptionCheckoutScreenState();
}

class _SubscriptionCheckoutScreenState
    extends State<SubscriptionCheckoutScreen> {
  // TODO: Invoke S Pay SDK (Android & iOS)
  static const platform = MethodChannel('com.sma.citizen_mobile/main');
  bool isChecked = false;
  String option = "";
  final Map data = {};

  final SubscriptionServices _subscriptionServices = SubscriptionServices();

  /// Create and confirm order when paying through S Pay Global
  /// To get encrypted data from SIOC Backend
  /// Using createOrder and confirmOrder API
  Future<void> orderRequest(
      BuildContext context, double subscriptionPrice) async {
    final subscriptionProvider =
        Provider.of<SubscriptionProvider>(context, listen: false);
    try {
      // TODO: Subscription Provider (for onData in HomePage)
      subscriptionProvider.changeIsSubscription(true);

      data['goodsType'] = '2';
      data['goodsName'] = 'Member';
      data['goodsCode'] = 'V001';
      data['goodsCnt'] = '1';
      data['orderAmount'] = subscriptionPrice.toString();
      data['orderDescription'] = 'Subscription Member';
      data['option'] = option;
      data['subscribeId'] = subscriptionProvider.subscribeId;

      await _subscriptionServices
          .createSubcriptionOrder(data)
          .then((response) async {
        if (response['status'] == '200') {
          await _subscriptionServices.confirmSubscriptionOrder({
            "orderCodes": response['data'],
            "payType": "1"
          }).then((res) async {
            if (res['status'] == '200') {
              await jumpPay(res['data'], context);
            } else {
              // TODO: Subscription Provider
              subscriptionProvider.changeIsSubscription(false);
              Navigator.of(context).pop(true);
              Fluttertoast.showToast(
                msg: AppLocalization.of(context)!.translate('payment_failed')!,
              );
              print('confirmOrder fail');
            }
          });
        } else {
          // TODO: Subscription Provider
          subscriptionProvider.changeIsSubscription(false);
          Navigator.of(context).pop(true);
          Fluttertoast.showToast(
            msg: AppLocalization.of(context)!.translate('payment_failed')!,
          );
          print('createOrder fail');
        }
      });
    } catch (e) {
      // TODO: Subscription Provider
      subscriptionProvider.changeIsSubscription(false);
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
    final subscriptionProvider =
        Provider.of<SubscriptionProvider>(context, listen: false);
    try {
      if (encryptionData.isEmpty) {
        Fluttertoast.showToast(
          msg: AppLocalization.of(context)!.translate('payment_failed')!,
        );
        return;
      }
      Navigator.of(context).pop(true);
      // TODO: Invoke S Pay SDK (Android & iOS)
      if (Platform.isAndroid) {
        // encrypted data from backend
        var sendMap = <String, dynamic>{'dataString': encryptionData};
        await platform.invokeMethod('spayPlaceOrder', sendMap);
      } else if (Platform.isIOS) {
        var sendMap = <String, dynamic>{'dataString': encryptionData};
        await platform.invokeMethod('spayPlaceOrder', sendMap);
      }
    } catch (e) {
      // TODO
      subscriptionProvider.changeIsSubscription(false);
      Navigator.of(context).pop(true);
      Fluttertoast.showToast(
        msg: AppLocalization.of(context)!.translate('payment_failed')!,
      );
      print('jumpPay fail');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final args = ModalRoute.of(context)!.settings.arguments
        as SubscriptionCheckoutScreenArguments;

    String returnPackageName(int selectedPackage) {
      switch (selectedPackage) {
        case 0:
          option = "option_1";
          return "1-month Premium Subscripion";
        case 1:
          option = "option_2";
          return "3-month Premium Subscripion";
        default:
          option = "option_3";
          return "12-month Premium Subscripion";
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment Checkout"),
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Container(
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
                    borderRadius: const BorderRadius.all(Radius.circular(10.0)),
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
                        const Text(
                          "Payment Item",
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          returnPackageName(args.selectedPackage),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        const Text(
                          "Payment Amount",
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          "RM ${args.selectedPrice}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        const Text(
                          "Payment Method",
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
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
                    vertical: 30.0,
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
                ),
              ],
            ),
            Column(
              children: <Widget>[
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
                        // TODO: skip this for demo, navigate to Result screen
                        orderRequest(context, args.selectedPrice);
                        // TODO: temp navigation
                        // Navigator.of(context).pushNamedAndRemoveUntil(
                        //   SubscriptionResultScreen.routeName,
                        //   (route) => route.isFirst,
                        // ); // is used to keep only the first route (the HomeScreen));
                      } else {
                        Navigator.of(context).pop();
                        Fluttertoast.showToast(
                          msg: AppLocalization.of(context)!
                              .translate('please_install_spay')!,
                        );
                      }
                    },
                  ),
                ),
                Container(
                  width: screenSize.width * 0.8,
                  margin: const EdgeInsets.only(
                    top: 15.0,
                  ),
                  child: Text(
                    "Note: This will open the S Pay Global app. Please make sure the app is installed and have sufficient amount in the wallet",
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
