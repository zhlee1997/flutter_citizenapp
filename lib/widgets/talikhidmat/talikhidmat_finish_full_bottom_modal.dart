import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../screens/reported_cases/talikhidmat_cases_screen.dart';
import '../../providers/talikhidmat_provider.dart';
import '../../providers/inbox_provider.dart';
import '../../utils/app_localization.dart';

class TalikhidmatFinishFullBottomModal extends StatelessWidget {
  final bool isServices;
  const TalikhidmatFinishFullBottomModal({this.isServices = false, super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8.0),
          color: Theme.of(context).colorScheme.background,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Lottie.asset(
                'assets/animations/lottie_done.json',
                width: screenSize.width * 0.5,
                height: screenSize.width * 0.5,
                repeat: false,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  AppLocalization.of(context)!
                      .translate("your_talikhidmat_feedback_is_submitted")!,
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                height: screenSize.height * 0.075,
              ),
              ElevatedButton(
                onPressed: () {
                  Provider.of<TalikhidmatProvider>(context, listen: false)
                      .resetProvider();
                  Provider.of<InboxProvider>(context, listen: false)
                      .refreshNotificationsProvider();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    TalikhidmatCasesScreen.routeName,
                    (route) => route.isFirst,
                  );
                },
                child: Text(AppLocalization.of(context)!
                    .translate("view_talikhidmat_cases")!),
              ),
              // Navigate to homepage
              TextButton(
                onPressed: () {
                  Provider.of<TalikhidmatProvider>(context, listen: false)
                      .resetProvider();
                  Provider.of<InboxProvider>(context, listen: false)
                      .refreshNotificationsProvider();
                  Navigator.of(context)
                      .popUntil(ModalRoute.withName('home-page-screen'));
                },
                child: Text(isServices
                    ? "Back to services"
                    : AppLocalization.of(context)!
                        .translate("back_to_homepage")!),
              )
            ],
          ),
        ),
      ),
    );
  }
}
