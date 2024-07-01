import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../utils/app_localization.dart';
import '../../providers/emergency_provider.dart';
import './case_detail_bottom_bar.dart';
import './emergency_recording_full_bottom_modal.dart';

class EmergencyCaseBottomModal extends StatelessWidget {
  const EmergencyCaseBottomModal({super.key});

  /// Displays case status such as 'New', 'Pending' and 'Resolved'
  ///
  /// Receives [caseStatus] as the case status code
  /// Returns case status
  String handleCaseStatus(
    String caseStatus,
    BuildContext context,
  ) {
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

  Future<void> handleEmergencyFullBottomModal(
    BuildContext context,
    String audioWavHttpURL,
  ) async {
    await showModalBottomSheet(
      barrierColor: Theme.of(context).colorScheme.onInverseSurface,
      useSafeArea: true,
      enableDrag: false,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return EmergencyRecordingFullBottomModal(
          audioWavHttpURL: audioWavHttpURL,
        );
      },
    );
  }

  String formatEmergencyCaseCategory(String caseCategory) {
    String status;
    switch (caseCategory) {
      case "0":
        status = "Harassment";
        break;
      case "1":
        status = "Fire/Rescue";
        break;
      case "2":
        status = "Traffic Accident/Injuries";
        break;
      case "3":
        status = "Theft/Robbery";
        break;
      case "4":
        status = "Physical Violence";
      case "5":
        status = "Others";
      default:
        status = "Voice Recording";
    }
    return status;
  }

  String formatDateTime(String dateTime) {
    if (dateTime.isNotEmpty) {
      final DateFormat formatter = DateFormat("dd MMMM yyyy, hh:mma");
      final String formattedDate = formatter.format(DateTime.parse(dateTime));
      return formattedDate;
    }
    return dateTime;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Column(
      children: <Widget>[
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            height: screenSize.height * 0.06,
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 10,
              bottom: 10,
              left: 25,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
            ),
            child: Row(
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
          ),
        ),
        Expanded(
          child: Consumer<EmergencyProvider>(
            builder: (_, caseData, __) {
              return ListView(
                padding: const EdgeInsets.all(15.0),
                physics: const AlwaysScrollableScrollPhysics(),
                children: <Widget>[
                  buildCaseStatusContainer(
                      caseData.reportedCaseDetail!.eventStatus!),
                  CaseDetailBottomBar(
                    label: AppLocalization.of(context)!.translate('case_n')!,
                    value: caseData.reportedCaseDetail!.eventCode!,
                  ),
                  // CaseDetailBottomBar(
                  //   label: AppLocalization.of(context)!.translate('case_s')!,
                  //   value: handleCaseStatus(
                  //     caseData.reportedCaseDetail!.eventStatus != null
                  //         ? caseData.reportedCaseDetail!.eventStatus!
                  //         : "",
                  //     context,
                  //   ),
                  // ),
                  CaseDetailBottomBar(
                    label: AppLocalization.of(context)!.translate('case_loca')!,
                    value:
                        '${AppLocalization.of(context)!.translate('latitude')!}: ${caseData.reportedCaseDetail!.eventLatitude ?? ""}\n${AppLocalization.of(context)!.translate('longitude')!}: ${caseData.reportedCaseDetail!.eventLongitude ?? ""}',
                  ),
                  CaseDetailBottomBar(
                    label: AppLocalization.of(context)!
                        .translate('case_category')!,
                    value: formatEmergencyCaseCategory(
                        caseData.reportedCaseDetail!.eventTargetUrgent ?? ""),
                  ),
                  CaseDetailBottomBar(
                    label:
                        AppLocalization.of(context)!.translate('case_message')!,
                    value: caseData.reportedCaseDetail!.eventDesc ?? "",
                  ),
                  // Add in eventNeedHelp field
                  CaseDetailBottomBar(
                    label: "Is It Yourself?",
                    value: caseData.reportedCaseDetail!.eventNeedHelp == "1"
                        ? "Yes"
                        : "No",
                  ),
                  CaseDetailBottomBar(
                    label: AppLocalization.of(context)!.translate('date_sub')!,
                    value: formatDateTime(
                        caseData.reportedCaseDetail!.createTime ?? ""),
                  ),
                  // Emergency -> show recording player
                  const SizedBox(
                    height: 15.0,
                  ),
                  if (caseData.reportCaseAttachmentList.isNotEmpty)
                    OutlinedButton.icon(
                      onPressed: () => handleEmergencyFullBottomModal(
                        context,
                        caseData.reportCaseAttachmentList[0].attFilePath,
                      ),
                      icon: const Icon(Icons.file_present_outlined),
                      label: Text("Recording File"),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
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

  Widget buildCaseStatusContainer(String caseStatus) {
    switch (caseStatus) {
      case "0":
        return Container(
          padding: const EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            color: Colors.red[100],
            borderRadius: const BorderRadius.all(Radius.circular(5.0)),
          ),
          child: Text(
            "NEW",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red[800],
            ),
          ),
        );
      case "1":
        return Container(
          padding: const EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            color: Colors.yellow[100],
            borderRadius: const BorderRadius.all(Radius.circular(5.0)),
          ),
          child: Text(
            "PENDING",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.yellow[800],
            ),
          ),
        );
      default:
        return Container(
          padding: const EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            color: Colors.green[100],
            borderRadius: const BorderRadius.all(Radius.circular(5.0)),
          ),
          child: Text(
            "RESOLVED",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green[800],
            ),
          ),
        );
    }
  }
}
