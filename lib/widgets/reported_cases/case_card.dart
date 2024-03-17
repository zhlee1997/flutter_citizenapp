import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  final int caseType;

  const CaseCard({
    required this.caseId,
    required this.caseNo,
    required this.caseDate,
    required this.caseStatus,
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
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
          } else {
            return const EmergencyCaseBottomModal();
          }
        },
      ),
    );
  }

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
        status = AppLocalization.of(context)!.translate('new')!;
    }
    return status;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        vertical: 5.0,
        horizontal: 5.0,
      ),
      elevation: 5.0,
      child: ListTile(
        onTap: () => caseType == 1
            ? showCaseBottomModal(context)
            : showEmergencyCaseBottomModal(context),
        title: Row(
          children: [
            SizedBox(
              width: 200,
              child: Text(
                caseNo,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
        subtitle: Text(
          caseDate,
          style: Theme.of(context).textTheme.labelSmall,
        ),
        trailing: Text(
          handleCaseStatus(caseStatus, context),
          style: TextStyle(
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }
}
