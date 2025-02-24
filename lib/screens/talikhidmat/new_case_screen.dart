import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fluttertoast/fluttertoast.dart';

import './report_screen.dart';
import './location_screen.dart';
import './confirm_screen.dart';
import '../../providers/location_provider.dart';
import '../../providers/talikhidmat_provider.dart';
import '../../utils/global_dialog_helper.dart';
import '../../utils/app_localization.dart';
import '../../services/event_services.dart';
import '../../widgets/talikhidmat/talikhidmat_finish_full_bottom_modal.dart';

class NewCaseScreen extends StatefulWidget {
  static const routeName = 'new-case-screen';

  const NewCaseScreen({super.key});

  @override
  State<NewCaseScreen> createState() => _NewCaseScreenState();
}

class _NewCaseScreenState extends State<NewCaseScreen> {
  int currentStep = 0;
  String _category = "1";
  String _message = "";
  // To submit attachments => API
  List<Map> _imagesAttachCreate = [];

  late TalikhidmatProvider _talikhidmatProvider;
  final EventServices _eventServices = EventServices();
  static final _formKey = GlobalKey<FormState>();

  void handleSetCategoryCallback(String? value) {
    setState(() {
      _category = value!;
    });
    print(_category);
  }

  void handleSetMessageCallback(String value) {
    setState(() {
      _message = value;
    });
    print(_message);
  }

  Future<void> submitCase(bool isServices) async {
    // category
    // eventLongitude, eventLatitude, eventLocation
    // message
    // attachments (another api, in http link)

    final GlobalDialogHelper globalDialogHelper = GlobalDialogHelper();
    final TalikhidmatProvider talikhidmatProvider =
        Provider.of<TalikhidmatProvider>(context, listen: false);
    Map<String, dynamic> paramater = {
      'eventUrgency': '1',
      'eventType': talikhidmatProvider.category,
      'eventLatitude': talikhidmatProvider.latitude,
      'eventLongitude': talikhidmatProvider.longitude,
      'eventLocation': talikhidmatProvider.address,
      'eventDesc': talikhidmatProvider.message,
    };

    try {
      globalDialogHelper.buildCircularProgressWithTextCenter(
        context: context,
        message: AppLocalization.of(context)!.translate('submitting')!,
      );
      // Submit Case => API
      var response = await _eventServices.create(paramater);
      if (response["status"] == "200") {
        // after submit case, submit images => API
        String? eventId = response["data"];

        if (eventId != null) {
          if (talikhidmatProvider.attachments.isNotEmpty) {
            // Upload Attachment => API
            talikhidmatProvider.attachments.forEach((element) {
              _imagesAttachCreate.insert(0, {
                "eventId": eventId,
                "attFileName": element['fileName'],
                "attFileType": '1',
                "attFileSuffix": element['fileSuffix'],
                "attFilePath": element['filePath']
              });
            });
            await _eventServices.attachmentCreate(_imagesAttachCreate);
          }

          // dismiss the dialog
          Navigator.of(context).pop();
          await showModalBottomSheet(
            barrierColor: Theme.of(context).colorScheme.onInverseSurface,
            useSafeArea: true,
            enableDrag: false,
            isScrollControlled: true,
            context: context,
            builder: (BuildContext context) {
              return TalikhidmatFinishFullBottomModal(isServices: isServices);
            },
          );
        }
      }
    } catch (e) {
      // dismiss the dialog
      Navigator.of(context).pop();
      Fluttertoast.showToast(msg: "Submit failed. Please try again");
      print("submit emergency failed: ${e.toString()}");
    }
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    _talikhidmatProvider = Provider.of<TalikhidmatProvider>(context);

    // final Position? position =
    //     Provider.of<LocationProvider>(context).currentLocation;
    // if (position != null) {
    //   print('latitude: ${position.latitude}');
    //   print('longitude: ${position.longitude}');
    // }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;

    return PopScope(
      canPop: !(_message.isNotEmpty ||
          _talikhidmatProvider.message.isNotEmpty ||
          _talikhidmatProvider.attachments.isNotEmpty),
      onPopInvoked: (bool didPop) async {
        if (didPop) {
          return;
        }
        await GlobalDialogHelper().showAlertDialog(
          context: context,
          yesButtonFunc: () {
            Provider.of<TalikhidmatProvider>(context, listen: false)
                .resetProvider();
            Navigator.of(context)
                .popUntil(ModalRoute.withName('home-page-screen'));
          },
          title: AppLocalization.of(context)!.translate('warning')!,
          message: AppLocalization.of(context)!.translate('do_you_discard')!,
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Submit Feedback'),
        ),
        body: Stepper(
          type: StepperType.horizontal,
          steps: getSteps(context, screenSize),
          currentStep: currentStep,
          controlsBuilder: (BuildContext ctx, ControlsDetails details) {
            if (details.currentStep == 0) {
              return OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                onPressed: details.onStepContinue,
                child: Text(AppLocalization.of(context)!.translate('proceed')!),
              );
            } else {
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
                      child:
                          Text(AppLocalization.of(context)!.translate('back')!),
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
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(AppLocalization.of(context)!
                                    .translate('submit')!),
                                const SizedBox(
                                  width: 10.0,
                                ),
                                const Icon(Icons.send)
                              ],
                            )
                          : Text(AppLocalization.of(context)!
                              .translate('proceed')!),
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
              // submit talikhidmat case
              submitCase(arguments["isServices"] ?? false);
            } else {
              if (currentStep == 0) {
                if (!_formKey.currentState!.validate()) {
                  return;
                }
                Provider.of<TalikhidmatProvider>(context, listen: false)
                    .setCategoryAndMessage(
                  category: _category,
                  message: _message,
                );
              }
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
            AppLocalization.of(context)!.translate('feedback')!,
            style: TextStyle(
              color: currentStep >= 0
                  ? Theme.of(context).colorScheme.primary
                  : null,
              fontSize: Theme.of(context).textTheme.labelSmall!.fontSize,
            ),
          ),
          content: ReportScreen(
            category: _category,
            categoryCallback: handleSetCategoryCallback,
            messageCallback: handleSetMessageCallback,
            formKey: _formKey,
          ),
        ),
        Step(
          isActive: currentStep >= 1,
          state: currentStep > 1 ? StepState.complete : StepState.indexed,
          title: Text(
            AppLocalization.of(context)!.translate('location')!,
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
            AppLocalization.of(context)!.translate('confirm')!,
            style: Theme.of(context).textTheme.labelSmall,
          ),
          content: const ConfirmScreen(),
        ),
      ];
}
