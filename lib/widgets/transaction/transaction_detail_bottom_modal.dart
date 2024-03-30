import 'package:flutter/material.dart';

import '../../utils/app_localization.dart';

class TransactionDetailBottomModal extends StatelessWidget {
  final String orderNo;
  final String taxCode;
  final String type;
  final String date;

  const TransactionDetailBottomModal({
    required this.orderNo,
    required this.taxCode,
    required this.type,
    required this.date,
    super.key,
  });

  String handleType(BuildContext context) {
    switch (type) {
      case "option_1":
        return "Subscription Package: 1-month Subscription";
      case "option_2":
        return "Subscription Package: 3-month Subscription";
      case "option_3":
        return "Subscription Package: 12-month Subscription";
      default:
        return "${AppLocalization.of(context)!.translate('account_number')!}: $taxCode";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalization.of(context)!.translate('transaction_d')!,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton.filledTonal(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.clear_outlined),
              )
            ],
          ),
          const SizedBox(height: 10.0),
          Text(
            '${AppLocalization.of(context)!.translate('transaction_n')!}: $orderNo',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 5.0),
          Text(
            handleType(context),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 5.0),
          Text(
            'Date: $date',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
