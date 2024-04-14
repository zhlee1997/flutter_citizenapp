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
import '../../models/cctv_model.dart';
import '../../utils/app_localization.dart';
import '../../utils/global_dialog_helper.dart';
import '../../screens/subscription/subscription_video_screen.dart';

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

    if (cctvProvider.imageUrl.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 150,
              child: SvgPicture.asset('assets/images/undraw_online.svg'),
            ),
            SizedBox(
              height: 20,
            ),
            Text(AppLocalization.of(context)!
                .translate('camera_is_not_available')!)
          ],
        ),
      );
    }

    return FutureBuilder(
      future: _loadWatermark(),
      builder: (_, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Column(
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
                  bottom: 20.0,
                ),
                // width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      cctvDetail.name,
                      softWrap: true,
                    ),
                    const SizedBox(
                      width: 10.0,
                    ),
                    const Text(
                      "|",
                    ),
                    const SizedBox(
                      width: 10.0,
                    ),
                    Text(
                      "${_distanceInBetween}KM from you",
                    )
                  ],
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
                        cctvDetail.liveUrl,
                        cctvDetail.name,
                        cctvDetail.location,
                        _distanceInBetween,
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
              const SizedBox(
                height: 20.0,
              ),
            ],
          );
        } else {
          if (imageByteData == null) {
            return Column(
              children: <Widget>[
                Center(
                  child: SizedBox(
                    width: double.infinity,
                    height: screenSize.height * 0.25,
                    child: Center(
                      child: Text(
                        AppLocalization.of(context)!
                            .translate('camera_is_not_available')!,
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
                  width: double.infinity,
                  child: Text(
                    cctvDetail!.location,
                    style: TextStyle(
                      fontSize: Platform.isIOS ? 18.0 : 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(
                    left: 20.0,
                    right: 20.0,
                    bottom: 20.0,
                  ),
                  width: double.infinity,
                  child: Text(
                    cctvDetail.name,
                    softWrap: true,
                    style: TextStyle(
                      fontSize: Platform.isIOS ? 18.0 : 15.0,
                    ),
                  ),
                ),
                SizedBox(
                  width: screenSize.width * 0.9,
                  height: screenSize.height * 0.06,
                  child: ElevatedButton(
                    onPressed: null,
                    child: Text(
                      AppLocalization.of(context)!.translate('play_now')!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              ],
            );
          }

          return Column(
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
                      child: Text(AppLocalization.of(context)!
                          .translate('camera_is_not_available')!),
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
                  bottom: 20.0,
                ),
                // width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      cctvDetail.name,
                      softWrap: true,
                    ),
                    const SizedBox(
                      width: 10.0,
                    ),
                    const Text(
                      "|",
                    ),
                    const SizedBox(
                      width: 10.0,
                    ),
                    Text(
                      "${_distanceInBetween}KM from you",
                    )
                  ],
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
                        cctvDetail.liveUrl,
                        cctvDetail.name,
                        cctvDetail.location,
                        _distanceInBetween,
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
              const SizedBox(
                height: 20.0,
              )
            ],
          );
        }
      },
    );
  }
}
