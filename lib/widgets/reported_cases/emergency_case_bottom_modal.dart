import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.only(
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
                padding: const EdgeInsets.all(10.0),
                physics: const AlwaysScrollableScrollPhysics(),
                children: <Widget>[
                  CaseDetailBottomBar(
                    label: AppLocalization.of(context)!.translate('case_id')!,
                    value:
                        caseData.reportedCaseDetail!.eventId!.substring(0, 10),
                  ),
                  CaseDetailBottomBar(
                    label: AppLocalization.of(context)!.translate('case_s')!,
                    value: handleCaseStatus(
                      caseData.reportedCaseDetail!.eventStatus != null
                          ? caseData.reportedCaseDetail!.eventStatus!
                          : "",
                      context,
                    ),
                  ),
                  CaseDetailBottomBar(
                    label: AppLocalization.of(context)!.translate('date_sub')!,
                    value: caseData.reportedCaseDetail!.createTime ?? "",
                  ),
                  CaseDetailBottomBar(
                    label: AppLocalization.of(context)!.translate('case_loca')!,
                    value:
                        '${AppLocalization.of(context)!.translate('latitude')!}: ${caseData.reportedCaseDetail!.eventLatitude ?? ""}\n${AppLocalization.of(context)!.translate('longitude')!}: ${caseData.reportedCaseDetail!.eventLongitude ?? ""}',
                  ),
                  CaseDetailBottomBar(
                    label: AppLocalization.of(context)!.translate('request_d')!,
                    value: caseData.reportedCaseDetail!.eventDesc ?? "",
                  ),
                  // TODO: Emergency -> show recording player
                  const SizedBox(
                    height: 15.0,
                  ),
                  // TODO: temp condition
                  if (!caseData.reportCaseAttachmentList.isNotEmpty)
                    OutlinedButton.icon(
                      onPressed: () => handleEmergencyFullBottomModal(
                        context,
                        // TODO: temp wav URL, to get from backend
                        "http://124.70.29.113:9000/picture/picture_1711006188820.wav",
                        // caseData.reportCaseAttachmentList[0].attFilePath,
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
}
