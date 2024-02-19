import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../widgets/emergency/circular_progress_button.dart';
import '../../widgets/emergency/emergency_audio_player.dart';

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
  bool _isRecorded = false;

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

  void saveRecording() {
    _timerCountDown?.cancel(); // Stop the timer
    setState(() {
      _isRecorded = true;
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
      child: Stack(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 15,
              ),
              if (_countdown == 10) ...returnIntro(screenSize),
              if (_countdown < 10 && !_isRecorded)
                Column(
                  children: <Widget>[
                    Text("Recording In Progress"),
                    Lottie.asset(
                      'assets/animations/lottie_recorder.json',
                      width: screenSize.height * 0.35,
                      height: screenSize.height * 0.35,
                      fit: BoxFit.fill,
                    ),
                  ],
                ),
              if (!_isRecorded)
                Container(
                  margin: const EdgeInsets.only(
                    bottom: 10.0,
                  ),
                  child: Text(
                    "$_countdown SECONDS",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if (!_isRecorded)
                CircularProgressButton(
                  startCountdown: () => startCountdown(),
                  resetCountdown: () => resetCountdown(),
                  saveRecording: () => saveRecording(),
                ),
              if (_countdown < 10 && _isRecorded) ...returnAudioPlayer(),
            ],
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: 60,
                height: 5,
                decoration: const BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> returnAudioPlayer() => [
        Text(
          "Please check your recording before you submit",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        SizedBox(
          height: 10.0,
        ),
        const EmergencyAudioPlayer(),
        SizedBox(
          height: 10.0,
        ),
        Container(
          margin: EdgeInsets.only(
            top: 20.0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: Colors.red,
                  ),
                ),
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: Colors.red,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 30.0,
                    ),
                  ),
                  onPressed: () {},
                  icon: Icon(
                    Icons.replay,
                    size: 28,
                  ),
                  label: Text(
                    "Reset",
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: Colors.red,
                  ),
                ),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(
                      horizontal: 30.0,
                    ), // Adjust the value as needed
                  ),
                  onPressed: () {
                    widget.handleNextProceed();
                  },
                  icon: Icon(
                    Icons.send,
                    size: 28,
                    color: Colors.white,
                  ),
                  label: Text(
                    "Submit",
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            ],
          ),
        )
      ];

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
            bottom: 5.0,
          ),
          child: const Text(
            "HOLD TO RECORD",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(
            bottom: 15.0,
          ),
          child: const Text(
            "Activate Emergency SOS by holding down the designated button to record audio, capture location, and initiate assistance in case of an emergency.",
            textAlign: TextAlign.center,
          ),
        ),
      ];
}

     // Load a Lottie file from your assets
              // isRecorded
              //     ? widget.childWidget
              //     : Lottie.asset('assets/animations/lottie_recorder.json'),

// CircularProgressButton(),

// GestureDetector(
              //   onTap: () {
              //     print("tap");
              //   },
              //   onTapUp: (_) {
              //     setState(() {
              //       _position = 6;
              //     });
              //   },
              //   onTapDown: (_) {
              //     setState(() {
              //       _position = 0;
              //     });
              //   },
              //   onTapCancel: () {
              //     setState(() {
              //       _position = 6;
              //     });
              //   },
              //   child: SizedBox(
              //     height: _height + _shadowHeight,
              //     width: 250,
              //     child: Stack(
              //       children: [
              //         Positioned(
              //           bottom: 0,
              //           child: Container(
              //             height: _height,
              //             width: 250,
              //             decoration: const BoxDecoration(
              //               color: Colors.grey,
              //               borderRadius: BorderRadius.all(
              //                 Radius.circular(16),
              //               ),
              //             ),
              //           ),
              //         ),
              //         AnimatedPositioned(
              //           curve: Curves.easeIn,
              //           bottom: _position,
              //           duration: const Duration(milliseconds: 70),
              //           child: Container(
              //             height: _height,
              //             width: 250,
              //             decoration: const BoxDecoration(
              //               color: Colors.red,
              //               borderRadius: BorderRadius.all(
              //                 Radius.circular(16),
              //               ),
              //             ),
              //             child: const Center(
              //               child: Text(
              //                 'HOLD TO TALK',
              //                 style: TextStyle(
              //                   color: Colors.white,
              //                   fontSize: 22,
              //                 ),
              //               ),
              //             ),
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),