import 'package:flutter/material.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import '../../providers/language_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../utils/app_localization.dart';
import '../../utils/global_dialog_helper.dart';
import '../../widgets/transaction/transaction_detail_bottom_modal.dart';

class TransactionHistoryScreen extends StatefulWidget {
  static const String routeName = "transaction-history-screen";

  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  double counter = 0;
  DateTime _dateTime = DateTime.now();
  String startTime = '';
  String endTime = '';
  bool _isLoading = false;

  // Define the date format
  DateFormat dateFormat = DateFormat('dd MMM yyyy HH:mm:ss');

  Future<void> handleTransactionDetailBottomModal({
    required String orderNo,
    required String taxCode,
    required String type,
    required String date,
  }) async {
    await showModalBottomSheet(
      context: context,
      builder: (_) => TransactionDetailBottomModal(
        orderNo: orderNo,
        taxCode: taxCode,
        type: type,
        date: date,
      ),
    );
  }

  /// Get the monthly transaction list when screen first renders
  /// Or when changing to different months
  /// Using queryOrder API
  ///
  /// Return response object from API
  Future<dynamic> getTransactionList(BuildContext context) async {
    try {
      setState(() {
        _isLoading = true;
      });
      final prefs = await SharedPreferences.getInstance();
      var userId = prefs.getString('userId');
      var map = {
        'memberId': userId,
        'orderStatus': '2',
        'startTime': startTime,
        'endTime': endTime
      };
      var response =
          await Provider.of<TransactionProvider>(context, listen: false)
              .queryTransactionProvider(map, context);
      if (response != null) {
        setState(() {
          _isLoading = false;
        });
        return response;
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Fluttertoast.showToast(
        msg: AppLocalization.of(context)!.translate('no_transactions')!,
      );
      print('getTransactionList failed');
      throw e;
    }
  }

  /// Get the first and last day of month
  /// Which are required for queryOrder API
  ///
  /// Receives [dateTime] as the current datetime
  void getDateFirstAndLastDate(DateTime dateTime) {
    var year = dateTime.year;
    var month = dateTime.month;

    String curMounth = month >= 10 ? month.toString() : '0' + month.toString();
    startTime = year.toString() + "-" + curMounth + '-01 00:00:00';

    DateTime curMounthFirstDay = DateTime(year, month, 1, 0, 0, 0);
    DateTime lastMouthFirstDay;
    if (month == 12) {
      lastMouthFirstDay = DateTime(year + 1, 1, 1, 0, 0, 0);
    } else {
      lastMouthFirstDay = DateTime(year, month + 1, 1, 0, 0, 0);
    }
    var difference = lastMouthFirstDay.difference(curMounthFirstDay);
    var days = difference.inDays;
    //double days = (lastMouthFirstDay.millisecond -curMounthFirstDay.millisecond)/(1000*60*60*24);
    endTime =
        year.toString() + "-" + curMounth + "-" + days.toString() + ' 23:59:59';
  }

  @override
  void initState() {
    super.initState();
    getDateFirstAndLastDate(_dateTime);
    getTransactionList(context);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Transaction History"),
        actions: <Widget>[
          IconButton(
            color: Theme.of(context).colorScheme.primary,
            onPressed: () {
              showMonthYearPicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(DateTime.now().year - 1),
                lastDate: DateTime(DateTime.now().year + 1),
                locale: Locale(
                  Provider.of<LanguageProvider>(context, listen: false)
                      .locale
                      .languageCode,
                ),
              ).then((DateTime? date) {
                if (date != null) {
                  getDateFirstAndLastDate(date);
                  getTransactionList(context);
                  setState(() {
                    _dateTime = date;
                  });
                }
              });
            },
            icon: const Icon(Icons.filter_alt_outlined),
          )
        ],
      ),
      body: Consumer<TransactionProvider>(
        builder: (_, TransactionProvider transactionProvider, __) {
          if (_isLoading) {
            return Center(
              child: GlobalDialogHelper().showLoadingSpinner(),
            );
          }
          if (transactionProvider.list.isEmpty) {
            return Center(
              child: GlobalDialogHelper().buildCenterNoData(
                context,
                message: AppLocalization.of(context)!.translate('no_tran_his')!,
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: transactionProvider.list.length,
            itemBuilder: (((_, index) {
              return ListTile(
                onTap: () => handleTransactionDetailBottomModal(
                  orderNo: transactionProvider.list[index]['orderNo'],
                  taxCode: transactionProvider.list[index]['taxCode'],
                  // option => 30-days/90-days
                  // type => 2: Assessment rate, 1: Subscription
                  type: transactionProvider.list[index]['option'] ??
                      transactionProvider.list[index]['type'],
                  date: dateFormat.format(DateTime.parse(
                      transactionProvider.list[index]['createTime'])),
                ),
                title: Text(
                  transactionProvider.list[index]['description'],
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    dateFormat.format(DateTime.parse(
                        transactionProvider.list[index]['createTime'])),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
                trailing: Text(
                  "-RM ${transactionProvider.list[index]['amount']}",
                  style: const TextStyle(
                    color: Colors.red,
                  ),
                ),
              );
            })),
          );
        },
      ),
    );
  }
}
