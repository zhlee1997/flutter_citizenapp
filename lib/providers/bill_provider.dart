import 'package:flutter/material.dart';

class BillProvider with ChangeNotifier {
  late String _paymentItem;
  String get paymentItem => _paymentItem;

  // use pay_id from payment/orderForm/create/confrim
  late String _receiptNumber;
  String get receiptNumber => _receiptNumber;

  // use order_id from payment/orderForm/createBySelective
  late String _referenceNumber;
  String get referenceNumber => _referenceNumber;

  // set paymentItem
  void setPaymentItem(String item) {
    _paymentItem = item;
  }

  // set receiptNumber
  void setReceiptNumber(String number) {
    _receiptNumber = number;
  }

  // set referenceNumber
  void setReferenceNumber(String number) {
    _referenceNumber = number;
  }
}
