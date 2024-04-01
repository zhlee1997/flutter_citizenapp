import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:provider/provider.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';

import '../../utils/global_dialog_helper.dart';
import '../../services/upload_services.dart';
import '../../providers/emergency_provider.dart';
import '../../providers/location_provider.dart';
import '../../utils/app_localization.dart';

class RecordingBottomModal extends StatefulWidget {
  final VoidCallback handleProceedNext;
  const RecordingBottomModal({
    required this.handleProceedNext,
    super.key,
  });

  @override
  State<RecordingBottomModal> createState() => _RecordingBottomModalState();
}

class _RecordingBottomModalState extends State<RecordingBottomModal> {
  late RecorderController recorderController; // Initialise
  bool isRecording = false;
  bool permission = false;
  String _address = "";
  double _latitude = 0;
  double _longitude = 0;

  late StopWatchTimer _stopWatchTimer;
  late StopWatchTimer _stopWatchRecordingTimer;

  Future<void> startRecording() async {
    try {
      await recorderController.record(
          // path: 'path',
          ); // Record (path is optional)
    } catch (e) {
      print("startRecording error: ${e.toString()}");
    }
  }

  Future<bool> checkPermission() async {
    final hasPermission = await recorderController
        .checkPermission(); // Check mic permission (also called during record)
    print("mic permission: $hasPermission");
    return hasPermission;
  }

  Future<void> stopRecordingAndProceed() async {
    final path =
        await recorderController.stop(); // Stop recording and get the path
    print("audio path: $path");
    if (path != null) {
      // close the voice recording bottom modal
      // Navigator.of(context).pop();
      await _uploadRecording(path);
    }
    // pop() the screen and currentStep +1 to go next step
    widget.handleProceedNext();
  }

  Future<void> _uploadRecording(String audioPath) async {
    // TODO: upload the multipart file to Upload API, set the res URL to provider
    // TODO: set a timeout for upload, if hit show upload timeout message
    String path = audioPath;
    String name = path.substring(path.lastIndexOf("/") + 1, path.length);
    String type = name.substring(name.lastIndexOf(".") + 1, name.length);
    File audioFile = File(audioPath);

    double audioByte = audioFile.lengthSync() / (1024 * 1024);
    print('audioSize: $audioByte');

    GlobalDialogHelper().buildCircularProgressWithTextCenter(
      context: context,
      message: "Uploading Audio",
    );

    Uint8List uint8listAudio =
        Uint8List.fromList(File(audioPath).readAsBytesSync());

    try {
      var response = await UploadServices().uploadAudioFile(
        uint8listAudio,
        type,
        name,
      );
      if (response["status"] == '200') {
        Navigator.of(context).pop();
        // Provider
        Provider.of<EmergencyProvider>(context, listen: false).setAudioPath(
          audioPath: response["data"]["filePath"],
          audioName: response["data"]["fileName"],
          audioSuffix: response["data"]["fileSuffix"],
        );
        // voice note category => 6
        // Emergency provider => yourself: true
        Provider.of<EmergencyProvider>(context, listen: false)
            .setCategoryAndYourself(
          category: 6,
          yourself: true,
        );
        Provider.of<EmergencyProvider>(context, listen: false)
            .setOtherText(null);
      }
    } catch (e) {
      print("_uploadRecording error: ${e.toString()}");
      // Navigator.of(context).pop();
      Fluttertoast.showToast(
        msg: AppLocalization.of(context)!.translate('upload_fail')!,
      );
    }
  }

  /// Perform geocoding from coordinates to get address
  ///
  /// Receives [latitude] and [longitude] as the latitude and longitude
  Future<void> _geocodeAddress(double latitude, double longitude) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latitude, longitude);
    String name = placemarks[0].name != '' ? '${placemarks[0].name}, ' : '';
    String subLocal =
        placemarks[0].subLocality != '' ? '${placemarks[0].subLocality}, ' : '';
    String thoroughfare = placemarks[0].thoroughfare != '' && Platform.isAndroid
        ? '${placemarks[0].thoroughfare}, '
        : '';
    _address =
        '$name$thoroughfare$subLocal${placemarks[0].locality}, ${placemarks[0].administrativeArea}, ${placemarks[0].postalCode}';
    if (mounted) {
      Provider.of<EmergencyProvider>(context, listen: false)
          .setAddressAndLocation(
        address: _address,
        latitide: latitude,
        longitude: longitude,
      );
      setState(() {});
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    recorderController = RecorderController();
    _stopWatchTimer = StopWatchTimer(
      mode: StopWatchMode.countDown,
      presetMillisecond: StopWatchTimer.getMilliSecFromSecond(2),
      onEnded: () async {
        // start recording
        setState(() {
          isRecording = true;
        });
        await startRecording();
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
        await stopRecordingAndProceed();
        _stopWatchRecordingTimer.onStopTimer();
        print('Ended _stopWatchRecordingTimer');
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      permission = await checkPermission();
    });
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    final LocationProvider locationProvider =
        Provider.of<LocationProvider>(context);
    if (locationProvider.currentLocation != null) {
      _latitude = locationProvider.currentLocation!.latitude;
      _longitude = locationProvider.currentLocation!.longitude;
      _geocodeAddress(_latitude, _longitude);
    } else {
      // no location permission (just in case)
      // because emergency cannot access if no location permission
      _latitude = 1.576472;
      _longitude = 110.345828;
      _geocodeAddress(_latitude, _longitude);
    }
  }

  @override
  void dispose() async {
    // TODO: implement dispose
    super.dispose();
    recorderController.dispose(); // Dispose controller
    await _stopWatchTimer.dispose();
    await _stopWatchRecordingTimer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Container(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Voice Recording",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton.filledTonal(
                  onPressed: () async {
                    await recorderController.pause(); // Pause recording
                    Navigator.of(context).pop();
                  },
                  icon: Icon(Icons.close_outlined),
                )
              ],
            ),
            SizedBox(
              height: 10,
            ),
            if (!isRecording)
              SizedBox(
                width: screenSize.width * 0.9,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  onPressed: _stopWatchTimer.isRunning
                      ? null
                      : () {
                          if (permission) {
                            _stopWatchTimer.onStartTimer();
                            setState(() {});
                          } else {
                            // TODO: show permission message, request for message
                          }
                        },
                  child: _stopWatchTimer.isRunning
                      ? SizedBox(
                          width: screenSize.width * 0.05,
                          height: screenSize.width * 0.05,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                          ),
                        )
                      : Text("START RECORDING"),
                ),
              ),
            if (isRecording)
              Row(
                children: <Widget>[
                  Flexible(
                    flex: 4,
                    child: AudioWaveforms(
                      size: Size(screenSize.width, screenSize.height * 0.1),
                      recorderController: recorderController,
                      waveStyle: WaveStyle(
                          showDurationLabel: true,
                          spacing: 8.0,
                          showBottom: false,
                          extendWaveform: true,
                          showMiddleLine: false,
                          gradient: ui.Gradient.linear(
                            const Offset(70, 50),
                            Offset(MediaQuery.of(context).size.width / 2, 0),
                            [Colors.red, Colors.green],
                          )),
                    ),
                  ),
                  Expanded(
                    child: IconButton.filled(
                      onPressed: () async {
                        await stopRecordingAndProceed();
                      },
                      icon: Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              ),
          ],
        ));
  }
}
