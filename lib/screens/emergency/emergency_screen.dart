import 'package:flutter/material.dart';
import "package:flutter_citizenapp/screens/emergency/confirm_screen.dart";

import "./location_screen.dart";
import "./report_screen.dart";

import "../../widgets/emergency/voice_note_bottom_modal.dart";
import "../../widgets/emergency/emergency_audio_player.dart";
import "../../widgets/emergency/emergency_bottom_modal.dart";
import "../../widgets/emergency/other_emergency_bottom_modal.dart";

class EmergencyScreen extends StatefulWidget {
  static const routeName = 'emergency-screen';

  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  int currentStep = 0;

  Future<void> _handleVoiceNoteBottomModal() async {
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return VoiceNoteBottomModal(
          childWidget: const EmergencyAudioPlayer(),
          handleNextProceed: handleProceedNext,
        );
      },
    );
  }

  Future<void> _handleEmergencyBottomModal(int index) async {
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return EmergencyBottomModal(
          handleProceedNext: handleProceedNext,
          category: index,
        );
      },
    );
  }

  Future<void> _handleOtherEmergencyBottomModal() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return OtherEmergencyBottomModal(
          handleProceedNext: handleProceedNext,
        );
      },
    );
  }

  void handleProceedNext() {
    Navigator.of(context).pop();
    setState(() => currentStep += 1);
  }

  // callback
  // void handleProceedNextWOPop({
  //   required String address,
  //   required double latitude,
  //   required double longitude,
  // }) {
  //   Provider.of<EmergencyProvider>(context).setAddressAndLocation(
  //     address: address,
  //     latitide: latitude,
  //     longitude: longitude,
  //   );
  //   setState(() => currentStep += 1);
  // }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Emergency Request"),
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Colors.red,
          ),
        ),
        child: Stepper(
          physics: const NeverScrollableScrollPhysics(),
          type: StepperType.horizontal,
          steps: getSteps(context, screenSize),
          currentStep: currentStep,
          controlsBuilder: (BuildContext ctx, ControlsDetails details) {
            if (details.currentStep == 0) {
              return Container();
            } else {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  SizedBox(
                    width: screenSize.width * 0.4,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Colors.red,
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
                        side: const BorderSide(
                          color: Colors.red,
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
            }
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
                color: currentStep >= 0 ? Colors.red : null,
                fontSize: Theme.of(context).textTheme.labelSmall!.fontSize,
              ),
            ),
            content: ReportScreen(
              handleVoiceNoteBottomModal: _handleVoiceNoteBottomModal,
              handleEmergencyBottomModal: _handleEmergencyBottomModal,
              handleOtherEmergencyBottomModal: _handleOtherEmergencyBottomModal,
            )),
        Step(
          isActive: currentStep >= 1,
          state: currentStep > 1 ? StepState.complete : StepState.indexed,
          title: Text(
            "Location",
            style: TextStyle(
              color: currentStep >= 1 ? Colors.red : null,
              fontSize: Theme.of(context).textTheme.labelSmall!.fontSize,
            ),
          ),
          content: const LocationScreen(
              // handleProceedNextWOPop: handleProceedNextWOPop,
              ),
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
