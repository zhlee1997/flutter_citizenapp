import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './case_detail_bottom_bar.dart';
import './case_detail_attachments.dart';
import '../../providers/talikhidmat_provider.dart';
import '../../utils/app_localization.dart';

class CaseDetailBottomModal extends StatefulWidget {
  final String caseStatus;

  const CaseDetailBottomModal({required this.caseStatus, super.key});

  @override
  State<CaseDetailBottomModal> createState() => _CaseDetailBottomModalState();
}

class _CaseDetailBottomModalState extends State<CaseDetailBottomModal> {
  /// Displays case status such as 'New', 'Pending' and 'Resolved'
  ///
  /// Receives [caseStatus] as the case status code
  /// Returns case status
  String handleCaseStatus(String caseStatus) {
    String status;
    switch (caseStatus) {
      case "0":
        status = AppLocalization.of(context)!.translate('new')!;
        break;
      case "1":
        status = AppLocalization.of(context)!.translate('pending')!;
        break;
      case "2":
        status = AppLocalization.of(context)!.translate('resolved')!;
        break;
      default:
        status = '';
    }
    return status;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Column(
      children: <Widget>[
        GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Container(
            height: Platform.isIOS
                ? screenSize.height * 0.06
                : screenSize.height * 0.06,
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 10,
              bottom: 10,
              left: 25,
              right: 25,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      AppLocalization.of(context)!.translate('case_d')!,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    const Icon(
                      Icons.arrow_drop_down_circle_outlined,
                      size: 20.0,
                      color: Colors.white,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Consumer<TalikhidmatProvider>(
            builder: (_, TalikhidmatProvider caseData, __) {
              return ListView(
                padding: const EdgeInsets.all(10.0),
                children: <Widget>[
                  CaseDetailBottomBar(
                    label: AppLocalization.of(context)!.translate('case_id')!,
                    value: caseData.reportedCaseDetail!.talikhidmatCaseId ?? "",
                  ),
                  CaseDetailBottomBar(
                    label: AppLocalization.of(context)!.translate('case_s')!,
                    value: handleCaseStatus(
                        caseData.reportedCaseDetail!.eventStatus != null
                            ? caseData.reportedCaseDetail!.eventStatus!
                            : ""),
                  ),
                  CaseDetailBottomBar(
                    label: AppLocalization.of(context)!.translate('date_sub')!,
                    value: caseData.reportedCaseDetail!.createTime ?? "",
                  ),
                  CaseDetailBottomBar(
                    label: AppLocalization.of(context)!.translate('case_loca')!,
                    value: caseData.reportedCaseDetail!.eventLocation != ""
                        ? caseData.reportedCaseDetail!.eventLocation ?? ""
                        : '${AppLocalization.of(context)!.translate('latitude')!}: ${caseData.reportedCaseDetail!.eventLatitude ?? ""}\n${AppLocalization.of(context)!.translate('longitude')!}: ${caseData.reportedCaseDetail!.eventLatitude ?? ""}',
                  ),
                  CaseDetailBottomBar(
                    label: AppLocalization.of(context)!.translate('request_d')!,
                    value: caseData.reportedCaseDetail!.eventDesc ?? "",
                  ),
                  CaseDetailAttachments(
                    imageList: caseData.reportCaseAttachmentList,
                  ),
                  const SizedBox(
                    height: 50,
                  )
                ],
              );
            },
          ),
        )
      ],
    );
  }
}
