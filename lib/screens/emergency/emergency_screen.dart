import 'package:flutter/material.dart';
import "package:fluttertoast/fluttertoast.dart";
import 'package:provider/provider.dart';

import "./confirm_screen.dart";
import "./location_screen.dart";
import "./report_screen.dart";

import "../../widgets/emergency/voice_note_bottom_modal.dart";
import "../../widgets/emergency/emergency_audio_player.dart";
import "../../widgets/emergency/emergency_bottom_modal.dart";
import "../../widgets/emergency/other_emergency_bottom_modal.dart";
import "../../widgets/emergency/emergency_finish_full_bottom_modal.dart";
import '../../services/event_services.dart';
import '../../providers/emergency_provider.dart';
import '../../utils/global_dialog_helper.dart';
import '../../utils/app_localization.dart';

class EmergencyScreen extends StatefulWidget {
  static const routeName = 'emergency-screen';

  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  int currentStep = 0;
  List<Map> _audioAttachCreate = [];

  final EventServices _eventServices = EventServices();
  static final _formKey = GlobalKey<FormState>();

  Future<void> _handleVoiceNoteBottomModal() async {
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return VoiceNoteBottomModal(
          childWidget: const EmergencyAudioPlayer(
            audioWavHttpURL: "",
          ),
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
          formKey: _formKey,
        );
      },
    );
  }

  void handleProceedNext() {
    Navigator.of(context).pop();
    setState(() => currentStep += 1);
  }

  /// Determine the type of description message based on selected case
  /// The description message will be submitted via sendRequest()
  ///
  /// Returns description message
  String returnRemarksInText(int categoryIndex) {
    if (categoryIndex == 0) {
      return 'You reported Harassment';
    } else if (categoryIndex == 1) {
      return 'You reported Fire/Rescue';
    } else if (categoryIndex == 2) {
      return 'You reported Traffic Accident/Injuries';
    } else if (categoryIndex == 3) {
      return 'You reported Theft/Robbery';
    } else if (categoryIndex == 4) {
      return 'You reported Physical Violence';
    } else if (categoryIndex == 5) {
      return Provider.of<EmergencyProvider>(context).otherText ?? "No remarks";
    } else {
      return "You submitted Voice Recording";
    }
  }

  Future<void> submitCase() async {
    // TODO: API Lack of "Voice Recording" category
    // eventLongitude, eventLatitude, eventLocation
    // TODO: Lack of eventAudioURL
    // TODO: Lack of eventYourself
    // TODO: attachment API

    final GlobalDialogHelper globalDialogHelper = GlobalDialogHelper();
    final EmergencyProvider emergencyProvider =
        Provider.of<EmergencyProvider>(context, listen: false);
    Map<String, dynamic> paramater = {
      'eventUrgency': '2',
      'eventType': '2',
      'eventTargetUrgent': emergencyProvider.category.toString(),
      'eventLatitude': emergencyProvider.latitude.toString(),
      'eventLongitude': emergencyProvider.longitude.toString(),
      // TODO: New field for emergency (address) => API
      'eventLocation': emergencyProvider.address.toString(),
      'eventDesc': returnRemarksInText(emergencyProvider.category),
    };

    try {
      globalDialogHelper.buildCircularProgressWithTextCenter(
        context: context,
        message: "Submitting",
      );
      var response = await _eventServices.create(paramater);
      if (response["status"] == "500") {
        // dismiss the dialog after submit fail (reached daily limit)
        Navigator.of(context).pop();
        await GlobalDialogHelper().showAlertDialogWithSingleButton(
          context: context,
          title: "Submit Fail",
          message: response["message"],
        );
        return;
      }
      if (response["status"] == "200") {
        String? eventId = response["data"];
        if (eventId != null) {
          if (emergencyProvider.audioPath.isNotEmpty) {
            // Upload Attachment => API
            _audioAttachCreate.insert(0, {
              "eventId": eventId,
              "attFileName": emergencyProvider.audioName,
              "attFileType": '1',
              "attFileSuffix": emergencyProvider.audioSuffix,
              "attFilePath": emergencyProvider.audioPath,
            });
            await _eventServices.attachmentCreate(_audioAttachCreate);
          }
        }

        // dismiss the dialog after submit success
        Navigator.of(context).pop();
        await showModalBottomSheet(
          barrierColor: Theme.of(context).colorScheme.onInverseSurface,
          useSafeArea: true,
          enableDrag: false,
          isScrollControlled: true,
          context: context,
          builder: (BuildContext context) {
            return const EmergencyFinishFullBottomModal();
          },
        );
      }
    } catch (e) {
      // dismiss the dialog
      Navigator.of(context).pop();
      Fluttertoast.showToast(msg: "Submit failed. Please try again");
      print("submit emergency failed: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final EmergencyProvider emergencyProvider =
        Provider.of<EmergencyProvider>(context, listen: false);

    return PopScope(
      canPop: !(emergencyProvider.category != -1),
      onPopInvoked: (bool didPop) async {
        if (didPop) {
          return;
        }
        await GlobalDialogHelper().showAlertDialog(
          context: context,
          yesButtonFunc: () {
            emergencyProvider.resetProvider();
            Navigator.of(context)
                .popUntil(ModalRoute.withName('home-page-screen'));
          },
          title: AppLocalization.of(context)!.translate('warning')!,
          message: AppLocalization.of(context)!.translate('do_you_discard')!,
        );
      },
      child: Scaffold(
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
            // physics: const NeverScrollableScrollPhysics(),
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
                        child: const Text('BACK'),
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
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text("SUBMIT"),
                            SizedBox(
                              width: 10.0,
                            ),
                            Icon(Icons.send)
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
            onStepContinue: () async {
              bool isLastStep =
                  currentStep == getSteps(context, screenSize).length - 1;
              if (isLastStep) {
                // submit emergency case
                submitCase();
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
        // Step(
        //   isActive: currentStep >= 1,
        //   state: currentStep > 1 ? StepState.complete : StepState.indexed,
        //   title: Text(
        //     "Location",
        //     style: TextStyle(
        //       color: currentStep >= 1 ? Colors.red : null,
        //       fontSize: Theme.of(context).textTheme.labelSmall!.fontSize,
        //     ),
        //   ),
        //   content: const LocationScreen(),
        // ),
        Step(
          isActive: currentStep >= 1,
          state: currentStep > 1 ? StepState.complete : StepState.indexed,
          title: Text(
            "Confirm",
            style: Theme.of(context).textTheme.labelSmall,
          ),
          content: const ConfirmScreen(),
        ),
      ];
}
