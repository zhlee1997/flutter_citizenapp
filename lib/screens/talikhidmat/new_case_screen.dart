import 'package:flutter/material.dart';

import './report_screen.dart';
import './location_screen.dart';
import './confirm_screen.dart';

class NewCaseScreen extends StatefulWidget {
  static const routeName = 'new-case-screen';

  const NewCaseScreen({super.key});

  @override
  State<NewCaseScreen> createState() => _NewCaseScreenState();
}

class _NewCaseScreenState extends State<NewCaseScreen> {
  int currentStep = 0;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('Submit Feedback'),
      ),
      body: Stepper(
        physics: const NeverScrollableScrollPhysics(),
        type: StepperType.horizontal,
        steps: getSteps(context, screenSize),
        currentStep: currentStep,
        controlsBuilder: (BuildContext ctx, ControlsDetails details) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              SizedBox(
                width: screenSize.width * 0.4,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  onPressed: details.onStepCancel,
                  child: const Text('CANCEL'),
                ),
              ),
              SizedBox(
                width: screenSize.width * 0.4,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  onPressed: details.onStepContinue,
                  child: currentStep == 2
                      ? const Text("SUBMIT")
                      : const Text('PROCEED'),
                ),
              ),
            ],
          );
        },
        onStepContinue: () {
          bool isLastStep =
              currentStep == getSteps(context, screenSize).length - 1;
          if (isLastStep) {
            print("Completed");
          } else {
            setState(() => currentStep += 1);
          }
        },
        onStepCancel: () {
          bool isFirstStep = currentStep == 0;
          if (isFirstStep) {
            print("First");
          } else {
            setState(() => currentStep -= 1);
          }
        },
        onStepTapped: null,
      ),
    );
  }

  List<Step> getSteps(BuildContext context, Size screenSize) => [
        Step(
          isActive: currentStep >= 0,
          state: currentStep > 0 ? StepState.complete : StepState.indexed,
          title: Text(
            "Report",
            style: TextStyle(
              color: currentStep >= 0
                  ? Theme.of(context).colorScheme.primary
                  : null,
              fontSize: Theme.of(context).textTheme.labelSmall!.fontSize,
            ),
          ),
          content: const ReportScreen(),
        ),
        Step(
          isActive: currentStep >= 1,
          state: currentStep > 1 ? StepState.complete : StepState.indexed,
          title: Text(
            "Location",
            style: TextStyle(
              color: currentStep >= 1
                  ? Theme.of(context).colorScheme.primary
                  : null,
              fontSize: Theme.of(context).textTheme.labelSmall!.fontSize,
            ),
          ),
          content: const LocationScreen(),
        ),
        Step(
          isActive: currentStep >= 2,
          state: currentStep > 2 ? StepState.complete : StepState.indexed,
          title: Text(
            "Confirm",
            style: Theme.of(context).textTheme.labelSmall,
          ),
          content: const ConfirmScreen(),
        ),
      ];
}
