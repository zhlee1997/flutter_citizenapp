import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../screens/reported_cases/emergency_cases_screen.dart';
import '../../providers/emergency_provider.dart';
import '../../providers/inbox_provider.dart';

class EmergencyFinishFullBottomModal extends StatelessWidget {
  final bool isServices;
  const EmergencyFinishFullBottomModal({this.isServices = false, super.key});

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
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Your emergency request is submitted successfully.\nYou can check status below or in your profile.",
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                height: screenSize.height * 0.075,
              ),
              ElevatedButton(
                onPressed: () {
                  Provider.of<EmergencyProvider>(context, listen: false)
                      .resetProvider();
                  Provider.of<InboxProvider>(context, listen: false)
                      .refreshNotificationsProvider();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    EmergencyCasesScreen.routeName,
                    (route) => route.isFirst,
                  );
                },
                child: const Text("View emergency cases"),
              ),
              // Navigate to homepage
              TextButton(
                onPressed: () {
                  Provider.of<EmergencyProvider>(context, listen: false)
                      .resetProvider();
                  Provider.of<InboxProvider>(context, listen: false)
                      .refreshNotificationsProvider();
                  Navigator.of(context)
                      .popUntil(ModalRoute.withName('home-page-screen'));
                },
                child:
                    Text(isServices ? "Back to services" : "Back to homepage"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
