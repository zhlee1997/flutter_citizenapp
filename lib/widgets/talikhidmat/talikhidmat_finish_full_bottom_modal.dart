import 'package:flutter/material.dart';
import 'package:flutter_citizenapp/screens/reported_cases/talikhidmat_cases_screen.dart';
import 'package:lottie/lottie.dart';

class TalikhidmatFinishFullBottomModal extends StatelessWidget {
  const TalikhidmatFinishFullBottomModal({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
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
                Navigator.of(context).pushNamedAndRemoveUntil(
                  TalikhidmatCasesScreen.routeName,
                  (route) => route.isFirst,
                );
              },
              child: const Text("View reported cases"),
            ),
            // Navigate to homepage
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .popUntil(ModalRoute.withName('home-page-screen'));
              },
              child: const Text("Back to homepage"),
            )
          ],
        ),
      ),
    );
  }
}
