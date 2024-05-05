import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_citizenapp/utils/get_permissions.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../../arguments/bill_payment_checkout_screen_arguments.dart';
import './bill_payment_checkout_screen.dart';
import './bill_payment_scan_screen.dart';
import '../../utils/app_localization.dart';
import '../../utils/general_helper.dart';

class BillPaymentDetailScreen extends StatefulWidget {
  static const String routeName = "bill-payment-detail-screen";

  const BillPaymentDetailScreen({super.key});

  @override
  State<BillPaymentDetailScreen> createState() =>
      _BillPaymentDetailScreenState();
}

class _BillPaymentDetailScreenState extends State<BillPaymentDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  String type = '';
  bool isFirst = true;

  final _billAmountFocusNode = FocusNode();
  final _addressFocusNode = FocusNode();

  final _f1 = FocusNode();
  final _f2 = FocusNode();

  late TextEditingController _billAmountController;
  late TextEditingController _accountNumberController1;
  late TextEditingController _accountNumberController2;

  var maskFormatter1 = MaskTextInputFormatter(
    mask: 'AA',
    filter: {
      "A": RegExp(r'[A-Z, a-z]'),
    },
    type: MaskAutoCompletionType.lazy,
  );

  var maskFormatter2 = MaskTextInputFormatter(
    mask: '######',
    filter: {
      "#": RegExp(r'[0-9]'),
    },
    type: MaskAutoCompletionType.lazy,
  );

  void _handleSubmitUtilitiesForm() {
    if (!_formKey.currentState!.validate()) {
      if (_accountNumberController1.text.isEmpty) {
        Fluttertoast.showToast(msg: "Enter account number");
        return;
      }
      if (_billAmountController.text.isEmpty ||
          _billAmountController.text == "0.00") {
        Fluttertoast.showToast(msg: 'Enter bill amount');
        return;
      }
      return;
    }

    FocusScopeNode currentFocus = FocusScope.of(context);

    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }

    Map map = {
      "Sarawak Energy": "5",
      "Kuching Water Board": "4",
      "Majlis Perbandaran Padawan": '3',
      "Majlis Bandaraya Kuching Selatan": '2',
      "Dewan Bandaraya Kuching Utara": '1',
    };
    var arg = {
      'stateName': map[type],
      'taxCode': _accountNumberController1.value.text,
      'orderAmount': _billAmountController.value.text
    };

    Navigator.pushNamed(
      context,
      BillPaymentCheckoutScreen.routeName,
      arguments: BillPaymentCheckoutScreenArguments(
        map[type],
        arg["taxCode"],
        arg["orderAmount"],
      ),
    );
  }

  /// Submit payment detail for form validation
  /// And navigate to checkout screen
  void _handleSubmitForm() {
    if (!_formKey.currentState!.validate()) {
      if (_accountNumberController1.text.isEmpty ||
          _accountNumberController2.text.isEmpty ||
          _accountNumberController1.text.length != 2 ||
          _accountNumberController2.text.length != 6) {
        Fluttertoast.showToast(
          toastLength: Toast.LENGTH_LONG,
          msg:
              "Account No. must be in the format of AA-XXXXX, where A represents alphabet (A–Z) and X represents integer (0–9)",
        );
        return;
      }
      if (_billAmountController.text.isEmpty ||
          _billAmountController.text == "0.00") {
        Fluttertoast.showToast(
          msg: 'Please fill in an amount',
        );
        return;
      }
      return;
    }

    FocusScopeNode currentFocus = FocusScope.of(context);

    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }

    Map map = {
      "Sarawak Energy": "5",
      "Kuching Water Board": "4",
      "Majlis Perbandaran Padawan": '3',
      "Majlis Bandaraya Kuching Selatan": '2',
      "Dewan Bandaraya Kuching Utara": '1',
    };
    var arg = {
      'stateName': map[type],
      'taxCode': _accountNumberController1.value.text +
          "-" +
          _accountNumberController2.value.text,
      'orderAmount': _billAmountController.value.text
    };

    Navigator.pushNamed(
      context,
      BillPaymentCheckoutScreen.routeName,
      arguments: BillPaymentCheckoutScreenArguments(
        map[type],
        arg["taxCode"],
        arg["orderAmount"],
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _billAmountController = TextEditingController();
    _accountNumberController1 = TextEditingController();
    _accountNumberController2 = TextEditingController();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _addressFocusNode.dispose();
    _billAmountFocusNode.dispose();
    _billAmountController.dispose();
    _accountNumberController1.dispose();
    _accountNumberController2.dispose();

    _f1.dispose();
    _f2.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final paymentDetail =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    type = paymentDetail['text']!;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(paymentDetail['title']!),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Container(
              padding: EdgeInsets.only(
                top: 15.0,
                bottom: 15.0 + MediaQuery.of(context).viewInsets.bottom * 0.2,
                left: 15.0,
                right: 15.0,
              ),
              child: Column(
                children: [
                  const SizedBox(
                    height: 20.0,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: SizedBox(
                            width: 30,
                            height: 100,
                            child: Image.asset(
                              paymentDetail['imageUrl']!,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            paymentDetail['text']!,
                            style: const TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 20.0),
                    child: Text(
                      AppLocalization.of(context)!.translate('please_refer')!,
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ..._accountTextFormFielf(),
                  Container(
                    margin: const EdgeInsets.only(top: 20.0),
                    child: Text(
                      "Successful payment will be updated in your account within 24 hours.",
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  ElevatedButton(
                    onPressed: type == "Kuching Water Board" ||
                            type == "Sarawak Energy"
                        ? _handleSubmitUtilitiesForm
                        : _handleSubmitForm,
                    child: Container(
                      height: screenSize.height * 0.06,
                      width: screenSize.width * 0.7,
                      alignment: Alignment.center,
                      child: Text(
                        AppLocalization.of(context)!.translate('proceed_to')!,
                        style: const TextStyle(
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  TextButton(
                    onPressed: () async {
                      // Council bills cant scan
                      if (type == "Majlis Perbandaran Padawan" ||
                          type == "Majlis Bandaraya Kuching Selatan" ||
                          type == "Dewan Bandaraya Kuching Utara") {
                        Fluttertoast.showToast(
                          msg: 'Coming soon',
                        );
                        return;
                      }
                      final bool cameraPermissionStatus =
                          await GetPermissions.getCameraPermission(context);
                      if (cameraPermissionStatus) {
                        Navigator.of(context).pushNamed(
                          BillPaymentScanScreen.routeName,
                          arguments: paymentDetail,
                        );
                      }
                    },
                    child: Container(
                      height: screenSize.height * 0.06,
                      width: screenSize.width * 0.7,
                      alignment: Alignment.center,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(Icons.qr_code_2_outlined),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "QR Scan",
                            style: TextStyle(
                              fontSize: 18.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _accountTextFormFielf() {
    if (type == "Majlis Perbandaran Padawan" ||
        type == "Majlis Bandaraya Kuching Selatan" ||
        type == "Dewan Bandaraya Kuching Utara") {
      return [
        Container(
          margin: const EdgeInsets.only(top: 15.0),
          alignment: Alignment.centerLeft,
          child: Text(AppLocalization.of(context)!.translate('account_number')!,
              style: const TextStyle(
                fontSize: 18.0,
              )),
        ),
        Container(
            child: Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.characters,
                  style: const TextStyle(fontSize: 20.0),
                  decoration: const InputDecoration(
                    hintText: 'TH',
                  ),
                  focusNode: _f1,
                  inputFormatters: [maskFormatter1],
                  onChanged: (String newVal) {
                    _accountNumberController1.value = TextEditingValue(
                      text: newVal.toUpperCase(),
                      selection: TextSelection.collapsed(
                        offset: newVal.length,
                      ),
                    );
                    if (newVal.length == 2) {
                      _f1.unfocus();
                      FocusScope.of(context).requestFocus(_f2);
                    }
                  },
                  controller: _accountNumberController1,
                  validator: (String? value) {
                    if (value == null || value.isEmpty || value.length != 2) {
                      return "";
                    }
                    return null;
                  },
                ),
              ),
            ),
            const Text(
              " - ",
              style: TextStyle(
                fontSize: 20.0,
              ),
            ),
            Expanded(
              flex: 8,
              child: Container(
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: '123456',
                  ),
                  style: const TextStyle(fontSize: 20.0),
                  focusNode: _f2,
                  inputFormatters: [maskFormatter2],
                  controller: _accountNumberController2,
                  validator: (String? value) {
                    if (value == null || value.isEmpty || value.length != 6) {
                      return AppLocalization.of(context)!
                          .translate('enter_account_number')!;
                    }
                    return null;
                  },
                  onChanged: (String newVal) {
                    _accountNumberController2.value = TextEditingValue(
                      text: newVal.toUpperCase(),
                      selection: TextSelection.collapsed(
                        offset: newVal.length,
                      ),
                    );
                    if (newVal.length == 6) {
                      _f2.unfocus();
                    }
                    if (newVal == '') {
                      _f2.unfocus();
                      FocusScope.of(context).requestFocus(_f1);
                    }
                  },
                ),
              ),
            ),
          ],
        )),
        Container(
          margin: const EdgeInsets.only(top: 15.0),
          alignment: Alignment.centerLeft,
          child: Text(
            AppLocalization.of(context)!.translate('bill_amount')!,
            style: const TextStyle(
              fontSize: 18.0,
            ),
          ),
        ),
        Container(
          child: TextFormField(
            style: const TextStyle(
              fontSize: 20.0,
            ),
            validator: (String? value) {
              if (value == '0.00') {
                return AppLocalization.of(context)!
                    .translate('greater_than_0')!;
              }
              if (value == null || value.isEmpty) {
                return AppLocalization.of(context)!
                    .translate('enter_bill_amount')!;
              }
              return null;
            },
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: false,
            ),
            decoration: const InputDecoration(
              hintText: '0.00',
            ),
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
            ],
            onChanged: (String value) {
              _billAmountController.value = GeneralHelper.formatCurrency(
                value: value,
                controller: _billAmountController,
                isFirst: isFirst,
              );
            },
            controller: _billAmountController,
            focusNode: _billAmountFocusNode,
            onFieldSubmitted: (value) =>
                FocusScope.of(context).requestFocus(_addressFocusNode),
            textInputAction: TextInputAction.next,
          ),
        ),
      ];
    }
    return [
      Container(
        margin: const EdgeInsets.only(top: 5.0),
        child: TextFormField(
          validator: (String? value) {
            if (value == null || value.isEmpty) {
              return AppLocalization.of(context)!
                  .translate('enter_account_number')!;
            }
            return null;
          },
          style: const TextStyle(fontSize: 20.0),
          inputFormatters: [
            FilteringTextInputFormatter.allow(
                RegExp("[a-z,A-Z,0-9]")), // Input limited to a-z, A-Z, 0-9
            LengthLimitingTextInputFormatter(8), // Input length limit
          ],
          decoration: InputDecoration(
            labelText:
                AppLocalization.of(context)!.translate('account_number')!,
            hintText: 'ABCD1234',
          ),
          onChanged: (String value) {
            _accountNumberController1.value = TextEditingValue(
              text: value,
              selection: TextSelection.collapsed(offset: value.length),
            );
          },
          controller: _accountNumberController1,
        ),
      ),
      Container(
        margin: const EdgeInsets.only(top: 5.0),
        child: TextFormField(
          style: const TextStyle(
            fontSize: 20.0,
          ),
          validator: (String? value) {
            if (value == '0.00') {
              return AppLocalization.of(context)!.translate('greater_than_0')!;
            }
            if (value == null || value.isEmpty) {
              return AppLocalization.of(context)!
                  .translate('enter_bill_amount')!;
            }
            return null;
          },
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: false,
          ),
          decoration: InputDecoration(
            labelText: AppLocalization.of(context)!.translate('bill_amount')!,
            hintText: '0.00',
          ),
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
          ],
          onChanged: (String value) {
            _billAmountController.value = GeneralHelper.formatCurrency(
              value: value,
              controller: _billAmountController,
              isFirst: isFirst,
            );
          },
          controller: _billAmountController,
          focusNode: _billAmountFocusNode,
          onFieldSubmitted: (value) =>
              FocusScope.of(context).requestFocus(_addressFocusNode),
          textInputAction: TextInputAction.next,
        ),
      ),
    ];
  }
}
