import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import './case_detail_bottom_modal.dart';
import './emergency_case_bottom_modal.dart';
import '../../utils/app_localization.dart';
import '../../utils/global_dialog_helper.dart';
import '../../providers/talikhidmat_provider.dart';
import '../../providers/emergency_provider.dart';

class CaseCard extends StatelessWidget {
  final String caseId;
  final String caseNo;
  final String caseDate;
  final String caseStatus;
  final String caseCategory;
  final int caseType;

  const CaseCard({
    required this.caseId,
    required this.caseNo,
    required this.caseDate,
    required this.caseStatus,
    required this.caseCategory,
    required this.caseType,
    super.key,
  });

  /// Displays details of Talikhidmat case when tapping on the card
  /// Using bottom modal
  void showCaseBottomModal(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      builder: (_) => FutureBuilder(
        future:
            Provider.of<TalikhidmatProvider>(ctx, listen: false).setCaseDetail(
          caseId,
          caseStatus,
        ),
        builder: (_, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            if (snapshot.hasError) {
              return Container(
                child: GlobalDialogHelper().buildCenterAPIError(
                  ctx,
                  message:
                      AppLocalization.of(ctx)!.translate('could_not_network')!,
                ),
              );
            }
            return CaseDetailBottomModal(
              caseStatus: caseStatus,
            );
          }
        },
      ),
    );
  }

  /// Displays details of emergency case when tapping on the card
  /// Using bottom modal
  void showEmergencyCaseBottomModal(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      builder: (_) => FutureBuilder(
        future:
            Provider.of<EmergencyProvider>(ctx, listen: false).setCaseDetail(
          caseId,
          caseStatus,
        ),
        builder: (_, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            // when reponse return 300
            Fluttertoast.showToast(msg: snapshot.error.toString());
            return Container();
          } else {
            return const EmergencyCaseBottomModal();
            // return Container();
          }
        },
      ),
    );
  }

  /// Displays case status such as 'New', 'Pending' and 'Resolved'
  ///
  /// Receives [caseCategory] as the case category code
  /// Returns case status
  String handleCaseCategory(String caseCategory) {
    String status;
    switch (caseCategory) {
      case "1":
        status = "Complaint";
        break;
      case "2":
        status = "Request for Service";
        break;
      case "3":
        status = "Compliment";
        break;
      case "4":
        status = "Enquiry";
        break;
      default:
        status = "Suggestion";
    }
    return status;
  }

  /// Displays case status such as 'New', 'Pending' and 'Resolved'
  ///
  /// Receives [caseCategory] as the case category code
  /// Returns case status
  String handleEmergencyCaseCategory(String caseCategory) {
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

  Color handleBorderColor(String caseStatus) {
    switch (caseStatus) {
      case "0":
        return Colors.red.shade100;
      case "1":
        return Colors.yellow.shade100;
      default:
        return Colors.green.shade100;
    }
  }

  Icon handleStatusIcon(String caseStatus) {
    switch (caseStatus) {
      case "0":
        return Icon(
          Icons.new_releases_outlined,
          color: Colors.red,
        );
      case "1":
        return Icon(
          Icons.pending_actions_outlined,
          color: Colors.yellow,
        );
      default:
        return Icon(
          Icons.done_outline_rounded,
          color: Colors.green,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    DateFormat dateFormat = DateFormat('dd MMM');

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
        border: Border.all(
          color: handleBorderColor(caseStatus),
        ),
      ),
      margin: const EdgeInsets.symmetric(
        vertical: 5.0,
        horizontal: 5.0,
      ),
      // elevation: 5.0,
      child: ListTile(
        onTap: () => caseType == 1
            ? showCaseBottomModal(context)
            : showEmergencyCaseBottomModal(context),
        leading: handleStatusIcon(caseStatus),
        title: SizedBox(
          width: 200,
          child: Text(
            caseType == 1
                ? handleCaseCategory(caseCategory)
                : handleEmergencyCaseCategory(caseCategory),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(fontWeight: FontWeight.w500),
          ),
        ),
        subtitle: Text(
          caseNo,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: Text(
          dateFormat.format(DateTime.parse(caseDate)),
          style: TextStyle(
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }
}
