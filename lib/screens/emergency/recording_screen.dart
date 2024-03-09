import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:lottie/lottie.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:provider/provider.dart';

import '../../providers/emergency_provider.dart';

class RecordingScreen extends StatefulWidget {
  static const String routeName = "recording-screen";

  const RecordingScreen({super.key});

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  late AudioRecorder audioRecorder;
  late AudioPlayer audioPlayer;
  bool isRecording = false;
  String audioPath = "";

  late var arguments;

  late StopWatchTimer _stopWatchTimer;
  late StopWatchTimer _stopWatchRecordingTimer;

  Future<void> _uploadRecording() async {
    // TODO: upload the multipart file to Upload API, set the res URL to provider
    // TODO: set a timeout for upload, if hit show upload timeout message

    // Provider
    Provider.of<EmergencyProvider>(context, listen: false)
        .setAudioPath(audioPath);
    Provider.of<EmergencyProvider>(context, listen: false)
        .setCategoryAndYourself(category: 7, yourself: true);
    Provider.of<EmergencyProvider>(context, listen: false).setOtherText(null);

    // pop() the screen and currentStep +1 to go next step
    arguments['handleNextProceed']();
  }

  Future<void> _resetRecording() async {
    audioPlayer.stop();
    String patho = "";
    try {
      Directory? appDir = await getExternalStorageDirectory();
      String jrecord = 'Audiorecords';
      String dato = "${DateTime.now().millisecondsSinceEpoch.toString()}.wav";
      Directory appDirec = Directory("${appDir?.path}/$jrecord/");
      if (await appDirec.exists()) {
        appDirec.deleteSync(recursive: true);
        setState(() {
          audioPath = "";
        });
        _stopWatchTimer.onResetTimer();
        _stopWatchRecordingTimer.onResetTimer();
      }
    } catch (e) {
      print("Error in remove recording");
    }
  }

  Future<void> _startRecording() async {
    String patho = "";
    try {
      Directory? appDir = await getExternalStorageDirectory();
      String jrecord = 'Audiorecords';
      String dato = "${DateTime.now().millisecondsSinceEpoch.toString()}.wav";
      Directory appDirec = Directory("${appDir?.path}/$jrecord/");
      if (await appDirec.exists()) {
        patho = "${appDirec.path}$dato";
        print("path for file11 ${patho}");
      } else {
        appDirec.create(recursive: true);
        patho = "${appDirec.path}$dato";
        print("path for file22 ${patho}");
      }

      if (await audioRecorder.hasPermission()) {
        await audioRecorder.start(const RecordConfig(), path: patho);
        setState(() {
          isRecording = true;
        });
      }
    } catch (e) {
      print("Error in start recording: ${e.toString()}");
    }
  }

  Future<void> _stopRecording() async {
    try {
      String? path = await audioRecorder.stop();
      setState(() {
        isRecording = false;
        audioPath = path ?? "";
      });
    } catch (e) {
      print("Error in stop recording: ${e.toString()}");
    }
  }

  Future<void> _playRecording() async {
    try {
      print("upload audio file: $audioPath");
      Source urlSource = UrlSource(audioPath);
      await audioPlayer.play(urlSource);
    } catch (e) {
      print("Error in play recording: ${e.toString()}");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    audioRecorder = AudioRecorder();
    audioPlayer = AudioPlayer();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      arguments = ModalRoute.of(context)!.settings.arguments;
    });

    _stopWatchTimer = StopWatchTimer(
      mode: StopWatchMode.countDown,
      presetMillisecond: StopWatchTimer.getMilliSecFromSecond(5),
      onEnded: () async {
        // start recording
        print("Start Recording");
        await _startRecording();
        // stop this timer and display/replace the next timer and start
        _stopWatchTimer.onStopTimer();
        _stopWatchRecordingTimer.onStartTimer();
        print("Ended _stopWatchTimer");
      },
    );

    _stopWatchRecordingTimer = StopWatchTimer(
      mode: StopWatchMode.countDown,
      presetMillisecond: StopWatchTimer.getMilliSecFromSecond(10),
      onEnded: () async {
        await _stopRecording();
        _stopWatchRecordingTimer.onStopTimer();
        print('Ended _stopWatchRecordingTimer');
      },
    );
  }

  @override
  void dispose() async {
    // TODO: implement dispose
    super.dispose();
    await audioRecorder.dispose();
    await audioPlayer.dispose();
    await _stopWatchTimer.dispose();
    await _stopWatchRecordingTimer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Voice Recorder"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            /// Display every second.
            if (_stopWatchTimer.isRunning)
              StreamBuilder<int>(
                stream: _stopWatchTimer.secondTime,
                initialData: _stopWatchTimer.secondTime.value,
                builder: (context, snap) {
                  final value = snap.data;
                  print('Listen every second. $value');
                  return Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            'Recording starts in',
                            style: TextStyle(
                              fontSize: 17,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            value.toString(),
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            "seconds",
                            style: TextStyle(
                              fontSize: 17,
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            if (_stopWatchRecordingTimer.isRunning)
              StreamBuilder<int>(
                stream: _stopWatchRecordingTimer.secondTime,
                initialData: _stopWatchRecordingTimer.secondTime.value,
                builder: (context, snap) {
                  final value = snap.data;
                  print('Listen every second. $value');
                  return Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            'Recording ends in',
                            style: TextStyle(
                              fontSize: 17,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            value.toString(),
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            "seconds",
                            style: TextStyle(
                              fontSize: 17,
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            if (!isRecording && audioPath.isEmpty && !_stopWatchTimer.isRunning)
              _returnStartRecordWidget(),
            if (isRecording) ..._returnRecordingWidget(screenSize),
            if (!isRecording && audioPath.isNotEmpty)
              ..._returnFinishRecordWidget(screenSize)
          ],
        ),
      ),
    );
  }

  Widget _returnStartRecordWidget() {
    return ElevatedButton.icon(
      icon: const Icon(Icons.play_arrow),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(
            Theme.of(context).colorScheme.secondary),
      ),
      onPressed: () {
        _stopWatchTimer.onStartTimer();
        setState(() {});
      },
      label: const Text(
        "Start Recording",
        style: TextStyle(
          fontSize: 18.0,
        ),
      ),
    );
  }

  List<Widget> _returnRecordingWidget(Size screenSize) {
    return [
      Column(
        children: <Widget>[
          const Text("Recording in progress"),
          Lottie.asset(
            'assets/animations/lottie_recorder.json',
            width: screenSize.height * 0.35,
            height: screenSize.height * 0.35,
            fit: BoxFit.fill,
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.stop),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
                  Theme.of(context).colorScheme.secondary),
            ),
            onPressed: () {
              _stopRecording();
              _stopWatchRecordingTimer.onStopTimer();
            },
            label: const Text(
              "Stop Recording",
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
          )
        ],
      ),
    ];
  }

  List<Widget> _returnFinishRecordWidget(Size screenSize) {
    return [
      Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Recorded Audio File: $audioPath",
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            height: screenSize.width * 0.05,
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.send),
            onPressed: _uploadRecording,
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
                  Theme.of(context).colorScheme.secondary),
            ),
            label: const Text(
              "Upload To Continue",
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
          ),
          SizedBox(
            height: screenSize.width * 0.05,
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.play_arrow),
            onPressed: _playRecording,
            label: const Text(
              "Play Recording",
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
          ),
          SizedBox(
            height: screenSize.width * 0.05,
          ),
          Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Colors.red,
              ),
            ),
            child: OutlinedButton.icon(
              icon: const Icon(Icons.replay_rounded),
              onPressed: _resetRecording,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                  color: Colors.red,
                ),
              ),
              label: const Text(
                "Reset Recording",
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
            ),
          ),
        ],
      )
    ];
  }
}
