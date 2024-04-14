import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../utils/app_localization.dart';
import '../../models/inbox_model.dart';
import '../../services/inbox_services.dart';
import '../../widgets/notifications/inbox_cell.dart';

class NotificationsDetailScreen extends StatefulWidget {
  static const String routeName = "notifications-detail-screen";

  const NotificationsDetailScreen({super.key});

  @override
  State<NotificationsDetailScreen> createState() =>
      _NotificationsDetailScreenState();
}

class _NotificationsDetailScreenState extends State<NotificationsDetailScreen> {
  bool isLoading = true;
  bool isError = false;
  late String id;
  InboxModel? _inbox;
  Map<String, dynamic>? _msgContext;

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  /// Get inbox detail when screen first renders
  /// using getMsgById API
  Future<void> loadInboxDetail() async {
    var response = await InboxServices().getMsgById(id);
    if (response['status'] == '200') {
      if (response['data']['msgContext'] != null) {
        setStateIfMounted(() {
          _inbox = InboxModel.fromJson(response['data']);
          _msgContext = json.decode(response['data']['msgContext']);
        });
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback(
      (_) {
        id = ModalRoute.of(context)!.settings.arguments.toString();
        loadInboxDetail();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalization.of(context)!.translate('inbox_detail')!),
      ),
      body: _inbox == null ? Container() : getBodyWidget(screenSize),
    );
  }

  /// Display inbox detail when a message is selected
  ///
  /// Returns the widget of inbox detail
  Widget getBodyWidget(Size screenSize) {
    // Talikhidmat Case is created
    if (_inbox!.msgType == '1') {
      return SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: 15,
          right: 15,
          top: 15,
          bottom: 50,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _inbox!.msgTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(
              height: screenSize.height * 0.05,
            ),
            Text(
              _msgContext!["content"] ?? "",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            InboxCell(
              label: "Reported Date:",
              value: _msgContext!["reportedDate"] ?? "",
            ),
            InboxCell(
              label: "Reported By:",
              value: _inbox!.rcvLoginName,
              isSpaced: false,
            ),
            InboxCell(
              label: "Case Description:",
              value: "\n${_msgContext!["caseDescription"]}",
              isSpaced: false,
            ),
            SizedBox(
              height: screenSize.height * 0.05,
            ),
            Text(
              "${_msgContext!["greetings"] ?? ""}",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      );
    }

    // Emergency Case is accepted
    if (_inbox!.msgType == '2') {
      return SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: 15,
          right: 15,
          top: 15,
          bottom: 50,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _inbox!.msgTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(
              height: screenSize.height * 0.05,
            ),
            Text(
              _msgContext!["content"] ?? "",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            InboxCell(
              label: "Reported Date:",
              value: _msgContext!["reportedDate"] ?? "",
            ),
            InboxCell(
              label: "Reported By:",
              value: _inbox!.rcvLoginName,
              isSpaced: false,
            ),
            InboxCell(
              label: "Case Description:",
              value: "\n${_msgContext!["caseDescription"]}",
              isSpaced: false,
            ),
            SizedBox(
              height: screenSize.height * 0.05,
            ),
            Text(
              "${_msgContext!["greetings"] ?? ""}",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      );
    }

    // Emergency Case is solved
    if (_inbox!.msgType == '3') {
      return SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: 15,
          right: 15,
          top: 15,
          bottom: 50,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _inbox!.msgTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(
              height: screenSize.height * 0.05,
            ),
            Text(
              _msgContext!["content"] ?? "",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            InboxCell(
              label: "Case No.:",
              value: _inbox!.rcvId,
            ),
            InboxCell(
              label: "Reported Date:",
              value: _msgContext!["reportedDate"] ?? "",
              isSpaced: false,
            ),
            InboxCell(
              label: "Reported By:",
              value: _inbox!.rcvLoginName,
              isSpaced: false,
            ),
            SizedBox(
              height: screenSize.height * 0.05,
            ),
            Text(
              "${_msgContext!["greetings"] ?? ""}",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      );
    }

    // Assessment rate payment
    if (_inbox!.msgType == '4') {
      String price = double.parse(_msgContext!["amount"]).toStringAsFixed(2);

      return SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: 15,
          right: 15,
          top: 15,
          bottom: 50,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _inbox!.msgTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(
              height: screenSize.height * 0.05,
            ),
            InboxCell(
              label: "Sarawak ID:",
              value: _inbox!.rcvSarawakId,
              isSpaced: false,
            ),
            InboxCell(
              label: "Full Name:",
              value: _inbox!.rcvLoginName,
              isSpaced: false,
            ),
            InboxCell(
              label: "Transaction No.:",
              value: _msgContext!["transactionNo"] ?? "",
              isSpaced: false,
            ),
            InboxCell(
              label: "Transaction Time:",
              value: _msgContext!["transactionTime"] ?? "",
              isSpaced: false,
            ),
            InboxCell(
              label: "Amount (RM):",
              value: price,
              isSpaced: false,
            ),
            SizedBox(
              height: screenSize.height * 0.05,
            ),
            Text(
              "${_msgContext!["greetings"] ?? ""}",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      );
    }

    // Subscription payment
    if (_inbox!.msgType == '5') {
      String price = double.parse(_msgContext!["amount"]).toStringAsFixed(2);

      return SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: 15,
          right: 15,
          top: 15,
          bottom: 50,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _inbox!.msgTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(
              height: screenSize.height * 0.05,
            ),
            InboxCell(
              label: "Sarawak ID:",
              value: _inbox!.rcvSarawakId,
              isSpaced: false,
            ),
            InboxCell(
              label: "Full Name:",
              value: _inbox!.rcvLoginName,
              isSpaced: false,
            ),
            InboxCell(
              label: "Transaction No.:",
              value: _msgContext!["transactionNo"] ?? "",
              isSpaced: false,
            ),
            InboxCell(
              label: "Transaction Time:",
              value: _msgContext!["transactionTime"] ?? "",
              isSpaced: false,
            ),
            InboxCell(
              label: "Amount (RM):",
              value: price,
              isSpaced: false,
            ),
            InboxCell(
              label: "Subscription Period:",
              value: _msgContext!["subscriptionPeriod"] ?? "",
              isSpaced: false,
            ),
            SizedBox(
              height: screenSize.height * 0.05,
            ),
            Text(
              "${_msgContext!["greetings"] ?? ""}",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      );
    }

    // Emergency Case is created
    if (_inbox!.msgType == '6') {
      return SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: 15,
          right: 15,
          top: 15,
          bottom: 50,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _inbox!.msgTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(
              height: screenSize.height * 0.05,
            ),
            Text(
              _msgContext!["content"] ?? "",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            InboxCell(
              label: "Reported Date:",
              value: _msgContext!["reportedDate"] ?? "",
            ),
            InboxCell(
              label: "Reported By:",
              value: _inbox!.rcvLoginName,
              isSpaced: false,
            ),
            InboxCell(
              label: "Case Description:",
              value: "\n${_msgContext!["caseDescription"]}",
              isSpaced: false,
            ),
            SizedBox(
              height: screenSize.height * 0.05,
            ),
            Text(
              "${_msgContext!["greetings"] ?? ""}",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      );
    }

    return Container();
  }
}
