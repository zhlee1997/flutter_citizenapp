import 'dart:async';

import 'package:flutter/material.dart';

import '../../widgets/emergency/emergency_audio_player.dart';
import '../../screens/emergency/recording_screen.dart';
import './recording_bottom_modal.dart';
import '../../utils/app_localization.dart';

class VoiceNoteBottomModal extends StatefulWidget {
  final Widget childWidget;
  final VoidCallback handleNextProceed;

  const VoiceNoteBottomModal({
    required this.childWidget,
    required this.handleNextProceed,
    super.key,
  });

  @override
  State<VoiceNoteBottomModal> createState() => _VoiceNoteBottomModalState();
}

class _VoiceNoteBottomModalState extends State<VoiceNoteBottomModal> {
  Timer? _timerCountDown;
  int _countdown = 10;

  void startCountdown() {
    _timerCountDown?.cancel(); // Cancel previous timer if any
    _timerCountDown = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          _timerCountDown?.cancel(); // Stop the timer when countdown reaches 0
        }
      });
      print(_countdown);
    });
  }

  void resetCountdown() {
    _timerCountDown?.cancel(); // Stop the timer
    if (_countdown != 0) {
      setState(() {
        _countdown = 10; // Reset the countdown to 10 seconds
      });
    }
  }

  Future<void> saveRecording() async {
    _timerCountDown?.cancel(); // Stop the timer
    Navigator.of(context).pop();

    await showDialog(
        context: context,
        builder: (context) {
          Future.delayed(const Duration(seconds: 3), () {
            Navigator.of(context).pop(true);
            showModalBottomSheet(
                context: context,
                builder: (ctx) {
                  return const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[],
                  );
                });
          });
          return Dialog(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20.0),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          "Uploading audio...",
                          softWrap: true,
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        });
  }

  @override
  void dispose() {
    _timerCountDown?.cancel();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            height: 5,
          ),
          if (_countdown == 10) ...returnIntro(screenSize),
          SizedBox(
            width: screenSize.width * 0.9,
            child: ElevatedButton(
              onPressed: () {
                // Dismiss bottom modal sheet
                Navigator.of(context).pop();
                // Navigator.of(context).pushNamed(
                //   RecordingScreen.routeName,
                //   arguments: {
                //     'handleNextProceed': widget.handleNextProceed,
                //   },
                // );
                showModalBottomSheet(
                  isDismissible: false,
                  enableDrag: false,
                  context: context,
                  builder: (_) {
                    return RecordingBottomModal(
                      handleProceedNext: widget.handleNextProceed,
                    );
                  },
                );
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                    Theme.of(context).colorScheme.secondary),
              ),
              child: Text(
                AppLocalization.of(context)!.translate('i_understand')!,
                style: const TextStyle(
                  fontSize: 18.0,
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(
              vertical: 10.0,
            ),
            child: Text(
              AppLocalization.of(context)!.translate('each_recording_session')!,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> returnIntro(Size screenSize) => [
        ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: Image.asset(
            "assets/images/pictures/emergency/voice_illustration.jpeg",
            fit: BoxFit.cover,
            height: screenSize.height * 0.2,
            width: screenSize.width * 0.9,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(
            top: 10.0,
            // bottom: 5.0,
          ),
          child: Text(
            AppLocalization.of(context)!.translate('voice_recording')!,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            AppLocalization.of(context)!
                .translate('request_and_activate_emergency')!,
            textAlign: TextAlign.center,
          ),
        ),
      ];
}
