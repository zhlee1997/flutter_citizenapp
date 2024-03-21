import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../screens/reported_cases/talikhidmat_cases_screen.dart';
import '../../providers/talikhidmat_provider.dart';

class TalikhidmatFinishFullBottomModal extends StatelessWidget {
  const TalikhidmatFinishFullBottomModal({super.key});

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
                  "Your Talikhidmat feedback is submitted successfully.\nThe SIOC Team will process your feedback soon.",
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
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    TalikhidmatCasesScreen.routeName,
                    (route) => route.isFirst,
                  );
                },
                child: const Text("View Talikhidmat cases"),
              ),
              // Navigate to homepage
              TextButton(
                onPressed: () {
                  Provider.of<TalikhidmatProvider>(context, listen: false)
                      .resetProvider();
                  Navigator.of(context)
                      .popUntil(ModalRoute.withName('home-page-screen'));
                },
                child: const Text("Back to homepage"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
