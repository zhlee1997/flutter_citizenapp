import 'package:flutter/material.dart';

import '../../utils/app_localization.dart';
import '../services/transaction_services.dart';

class TransactionProvider with ChangeNotifier {
  final TrasactionServices trasactionServices = TrasactionServices();
  double counter = 0;
  Map mapKeys = {
    "5": "SESCO",
    "4": "KWB",
    "3": "MPP",
    "2": "MBKS",
    "1": "DBKU"
  };

  List<Map> _list = [];
  List<Map> get list => _list;

  /// Get transaction list when accessing My Transaction
  /// Using queryOrder API
  ///
  /// Receives [map] as the query parameters, such as
  /// memberId, orderStatus, startTime, endTime
  /// Returns transaction [Response] data from API
  Future<dynamic> queryTransactionProvider(map, BuildContext context) async {
    String handleTitle(
      String goodsCode,
      String stateName,
    ) {
      if (goodsCode == "V001") {
        return AppLocalization.of(context)!.translate('subscription_1')!;
      } else {
        if (stateName == "1" || stateName == "2" || stateName == "3") {
          return (mapKeys[stateName] +
              " ${AppLocalization.of(context)!.translate('assessment_rate')!}");
        } else {
          return (mapKeys[stateName] + " Utilities");
        }
      }
    }

    var response = await trasactionServices.queryTransaction(map);

    if (response['status'] == '200') {
      _list.clear();
      counter = 0;
      if (response['data'] != null && response['data'].length > 0) {
        for (var item in response['data']) {
          counter += item['orderAmount'];
          //2: Assessment rate, 1: Subscription
          String type = item['goodsCode'] == 'T001' ? '2' : '1';
          // TODO: temp, lack of stateName
          String title =
              handleTitle(item['goodsCode'], item['stateName'] ?? "");
          // String title = handleTitle(item['goodsCode'], item['stateName']);
          var money = item['orderAmount'];
          _list.add({
            'createTime': item['createTime'],
            'type': type,
            'description': title,
            'amount': money,
            'orderNo': item['outTradeNo'],
            // TODO: temp, lack of taxCode
            'taxCode': item['taxCode'] ?? ""
            // 'taxCode': item['taxCode']
          });
        }
      }
      notifyListeners();
    }
    return response;
  }
}
