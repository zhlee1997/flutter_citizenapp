import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:lottie/lottie.dart';

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

  Future<void> _uploadRecording() async {
    // TODO: upload the multipart file to Upload API, set the res URL to provider
    // TODO: set a timeout for upload, if hit show upload timeout message

    // pop() the screen and currentStep +1 to go next step
    arguments['handleNextProceed']();
  }

  Future<void> _resetRecording() async {
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
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    audioRecorder.dispose();
    audioPlayer.dispose();
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
            if (isRecording) ..._returnRecordingWidget(screenSize),
            if (!isRecording && audioPath.isEmpty) _returnStartRecordWidget(),
            if (!isRecording && audioPath.isNotEmpty)
              ..._returnFinishRecordWidget(screenSize)
          ],
        ),
      ),
    );
  }

  Widget _returnStartRecordWidget() {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(
            Theme.of(context).colorScheme.secondary),
      ),
      onPressed: _startRecording,
      child: const Text(
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
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
                  Theme.of(context).colorScheme.secondary),
            ),
            onPressed: _stopRecording,
            child: const Text(
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
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Recorded Audio File: /storage/emulated/0/Android/data/com.sioc.sma.flutter_citizenapp/files/Audiorecords/1708930554043.wav",
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            height: screenSize.width * 0.05,
          ),
          ElevatedButton(
            onPressed: _uploadRecording,
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
                  Theme.of(context).colorScheme.secondary),
            ),
            child: const Text(
              "Upload & Continue",
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
          ),
          SizedBox(
            height: screenSize.width * 0.05,
          ),
          ElevatedButton(
            onPressed: _playRecording,
            child: const Text(
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
            child: OutlinedButton(
              onPressed: _resetRecording,
              style: ElevatedButton.styleFrom(
                side: const BorderSide(
                  color: Colors.red,
                ),
              ),
              child: const Text(
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
