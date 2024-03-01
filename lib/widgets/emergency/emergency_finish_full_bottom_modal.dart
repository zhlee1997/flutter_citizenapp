import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class EmergencyFinishFullBottomModal extends StatelessWidget {
  const EmergencyFinishFullBottomModal({super.key});

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
                  "Your emergency request is submitted successfully.",
                  textAlign: TextAlign.center,
                )),
            const Text("The SIOC Team will contact you shortly."),
            SizedBox(
              height: screenSize.height * 0.1,
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to Reported Cases - Emergency List Screen
              },
              child: const Text("View details"),
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
