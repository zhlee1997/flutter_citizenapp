// You can pass any object to the arguments parameter.
// In this example, create a class that contains both
// a customizable title and message.
class BillPaymentCheckoutScreenArguments {
  final String? stateName;
  final String? taxCode;
  final String? orderAmount;

  BillPaymentCheckoutScreenArguments(
    this.stateName,
    this.taxCode,
    this.orderAmount,
  );
}
