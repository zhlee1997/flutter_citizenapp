import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';

import '../../arguments/subscription_video_screen_arguments.dart';
import '../../providers/cctv_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../models/cctv_model.dart';
import '../../utils/app_localization.dart';
import '../../utils/global_dialog_helper.dart';
import '../../screens/subscription/subscription_video_screen.dart';
import '../../screens/subscription/subscription_video_screen_ls.dart';

class MapBottomSheetWidget extends StatefulWidget {
  final String cctvLatitude;
  final String cctvLongitude;

  const MapBottomSheetWidget({
    required this.cctvLatitude,
    required this.cctvLongitude,
    super.key,
  });

  @override
  State<MapBottomSheetWidget> createState() => _MapBottomSheetWidgetState();
}

class _MapBottomSheetWidgetState extends State<MapBottomSheetWidget> {
  Uint8List? imageByteData;

  late CCTVProvider cctvProvider;
  late SubscriptionProvider subscriptionProvider;
  late Timer timer;

  double _endLatitude = 0;
  double _endLongitude = 0;
  String _distanceInBetween = "";

  Future<Uint8List?> _loadNetworkImage(String path) async {
    final completer = Completer<ImageInfo>();
    var img = NetworkImage(path);
    img.resolve(const ImageConfiguration()).addListener(
        ImageStreamListener((info, _) => completer.complete(info)));

    final imageInfo = await completer.future;
    final byteData =
        await imageInfo.image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  Future<void> _loadWatermark() async {
    timer = Timer(const Duration(seconds: 7), () {
      Fluttertoast.showToast(
        msg: "Still loading... Please wait",
        toastLength: Toast.LENGTH_LONG,
        timeInSecForIosWeb: 5,
      );
    });
    try {
      imageByteData = await _loadNetworkImage(cctvProvider.imageUrl)
          .timeout(const Duration(seconds: 12));
    } on TimeoutException catch (e) {
      print('Image Timeout');
      print(e.toString());
    } catch (e) {
      print(e.toString());
    }
    if (imageByteData != null) {
      timer.cancel();
      Fluttertoast.cancel();
    } else {
      // no image byte data
    }
  }

  // Use geolocator service to calculate the distance
  String getDistanceFromCoordinates(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    double distanceBetween = Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
    distanceBetween = distanceBetween / 1000;
    return distanceBetween.toStringAsFixed(1);
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    subscriptionProvider =
        Provider.of<SubscriptionProvider>(context, listen: false);
    cctvProvider = Provider.of<CCTVProvider>(context, listen: false);
    LocationProvider locationProvider = Provider.of<LocationProvider>(context);
    if (locationProvider.currentLocation != null) {
      _endLatitude = locationProvider.currentLocation!.latitude;
      _endLongitude = locationProvider.currentLocation!.longitude;
      _distanceInBetween = getDistanceFromCoordinates(
        double.parse(widget.cctvLatitude),
        double.parse(widget.cctvLongitude),
        _endLatitude,
        _endLongitude,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final CCTVModelDetail? cctvDetail = cctvProvider.cctvModelDetail;

    // if imageUrl is empty, show default SIOC Logo
    if (cctvProvider.imageUrl.isEmpty) {
      return SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Image.asset(
              "assets/images/icon/sioc.png",
              width: double.infinity,
              height: screenSize.height * 0.25,
              fit: BoxFit.fill,
            ),
            Container(
              margin: const EdgeInsets.only(
                top: 20.0,
                left: 20.0,
                right: 20.0,
                bottom: 10.0,
              ),
              // width: double.infinity,
              child: Text(
                cctvDetail!.location,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(
                left: 20.0,
                right: 20.0,
                bottom: 5.0,
              ),
              // width: double.infinity,
              child: Text(
                cctvDetail.name,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              width: screenSize.width * 0.9,
              child: ElevatedButton(
                onPressed: cctvDetail!.liveUrl.contains("get live url is fail")
                    ? null
                    : () async {
                        timer.cancel();
                        Fluttertoast.cancel();
                        Navigator.of(context).pop();
                        Navigator.pushNamed(
                          context,
                          SubscriptionVideoScreen.routeName,
                          arguments: SubscriptionVideoScreenArguments(
                            cctvDetail.id,
                            cctvDetail.liveUrl,
                            cctvDetail.name,
                            cctvDetail.location,
                            _distanceInBetween,
                            widget.cctvLatitude,
                            widget.cctvLongitude,
                          ),
                        );
                      },
                style: cctvDetail!.liveUrl.contains("get live url is fail")
                    ? null
                    : ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            Theme.of(context).colorScheme.secondary),
                      ),
                child: Text(
                  AppLocalization.of(context)!.translate('play_now')!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Text(
              "Each video session is ${subscriptionProvider.playbackDuration} minutes",
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const SizedBox(
              height: 20.0,
            )
          ],
        ),
      );
    }

    return FutureBuilder(
      future: _loadWatermark(),
      builder: (_, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  width: double.infinity,
                  height: screenSize.height * 0.25,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const CircularProgressIndicator(),
                      const SizedBox(
                        height: 20,
                      ),
                      RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: "Loading image...",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(
                    top: 20.0,
                    left: 20.0,
                    right: 20.0,
                    bottom: 10.0,
                  ),
                  // width: double.infinity,
                  child: Text(
                    cctvDetail!.location,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(
                    left: 20.0,
                    right: 20.0,
                    bottom: 5.0,
                  ),
                  // width: double.infinity,
                  child: Text(
                    cctvDetail.name,
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  width: screenSize.width * 0.9,
                  // height: screenSize.height * 0.06,
                  child: ElevatedButton(
                    onPressed: () async {
                      timer.cancel();
                      Fluttertoast.cancel();
                      Navigator.of(context).pop();
                      Navigator.pushNamed(
                        context,
                        SubscriptionVideoScreen.routeName,
                        arguments: SubscriptionVideoScreenArguments(
                            cctvDetail.id,
                            cctvDetail.liveUrl,
                            cctvDetail.name,
                            cctvDetail.location,
                            _distanceInBetween,
                            widget.cctvLatitude,
                            widget.cctvLongitude),
                      );
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          Theme.of(context).colorScheme.secondary),
                    ),
                    child: Text(
                      AppLocalization.of(context)!.translate('play_now')!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Text(
                  "Each video session is ${subscriptionProvider.playbackDuration} minutes",
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(
                  height: 20.0,
                ),
              ],
            ),
          );
        } else {
          // if null (timer reached), still can play video button
          if (imageByteData == null) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Center(
                    child: SizedBox(
                      width: double.infinity,
                      height: screenSize.height * 0.25,
                      child: Center(
                        child: Text(
                          "Camera image not available",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                      top: 20.0,
                      left: 20.0,
                      right: 20.0,
                      bottom: 10.0,
                    ),
                    // width: double.infinity,
                    child: Text(
                      cctvDetail!.location,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                      left: 20.0,
                      right: 20.0,
                      bottom: 5.0,
                    ),
                    // width: double.infinity,
                    child: Text(
                      cctvDetail.name,
                      softWrap: true,
                    ),
                  ),
                  SizedBox(
                    width: screenSize.width * 0.9,
                    // height: screenSize.height * 0.06,
                    child: ElevatedButton(
                      onPressed: () async {
                        timer.cancel();
                        Fluttertoast.cancel();
                        Navigator.of(context).pop();
                        Navigator.pushNamed(
                          context,
                          SubscriptionVideoScreen.routeName,
                          arguments: SubscriptionVideoScreenArguments(
                              cctvDetail.id,
                              cctvDetail.liveUrl,
                              cctvDetail.name,
                              cctvDetail.location,
                              _distanceInBetween,
                              widget.cctvLatitude,
                              widget.cctvLongitude),
                        );
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            Theme.of(context).colorScheme.secondary),
                      ),
                      child: Text(
                        AppLocalization.of(context)!.translate('play_now')!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    "Each video session is ${subscriptionProvider.playbackDuration} minutes",
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                ],
              ),
            );
          } else if (cctvDetail!.liveUrl.contains("get live url is fail")) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  GestureDetector(
                    onTap: () => GlobalDialogHelper()
                        .showMemoryPhotoGallery(context, imageByteData!),
                    child: Image.memory(
                      imageByteData!,
                      width: double.infinity,
                      height: screenSize.height * 0.25,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => SizedBox(
                        width: double.infinity,
                        height: screenSize.height * 0.25,
                        child: Center(
                          child: Text("Camera image not available"),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                      top: 20.0,
                      left: 20.0,
                      right: 20.0,
                      bottom: 10.0,
                    ),
                    // width: double.infinity,
                    child: Text(
                      cctvDetail!.location,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                      left: 20.0,
                      right: 20.0,
                      bottom: 5.0,
                    ),
                    // width: double.infinity,
                    child: Text(
                      cctvDetail.name,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    width: screenSize.width * 0.9,
                    // height: screenSize.height * 0.06,
                    child: ElevatedButton(
                      onPressed: null,
                      child: Text(
                        AppLocalization.of(context)!.translate('play_now')!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    "Unable to get video stream. Try again",
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                GestureDetector(
                  onTap: () => GlobalDialogHelper()
                      .showMemoryPhotoGallery(context, imageByteData!),
                  child: Image.memory(
                    imageByteData!,
                    width: double.infinity,
                    height: screenSize.height * 0.25,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => SizedBox(
                      width: double.infinity,
                      height: screenSize.height * 0.25,
                      child: Center(
                        child: Text("Camera image not available"),
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(
                    top: 20.0,
                    left: 20.0,
                    right: 20.0,
                    bottom: 10.0,
                  ),
                  // width: double.infinity,
                  child: Text(
                    cctvDetail!.location,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(
                    left: 20.0,
                    right: 20.0,
                    bottom: 5.0,
                  ),
                  // width: double.infinity,
                  child: Text(
                    cctvDetail.name,
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  width: screenSize.width * 0.9,
                  // height: screenSize.height * 0.06,
                  child: ElevatedButton(
                    onPressed: () async {
                      timer.cancel();
                      Fluttertoast.cancel();
                      Navigator.of(context).pop();
                      Navigator.pushNamed(
                        context,
                        SubscriptionVideoScreen.routeName,
                        // SubscriptionVideoScreenLS.routeName,
                        arguments: SubscriptionVideoScreenArguments(
                          cctvDetail.id,
                          cctvDetail.liveUrl,
                          cctvDetail.name,
                          cctvDetail.location,
                          _distanceInBetween,
                          widget.cctvLatitude,
                          widget.cctvLongitude,
                        ),
                      );
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          Theme.of(context).colorScheme.secondary),
                    ),
                    child: Text(
                      AppLocalization.of(context)!.translate('play_now')!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Text(
                  "Each video session is ${subscriptionProvider.playbackDuration} minutes",
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(
                  height: 20.0,
                )
              ],
            ),
          );
        }
      },
    );
  }
}
