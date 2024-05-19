import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fijkplayer/fijkplayer.dart';
import 'package:flutter_citizenapp/utils/global_dialog_helper.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';

import '../../utils/app_localization.dart';
import '../../arguments/subscription_video_screen_arguments.dart';
import '../../models/cctv_model.dart';
import '../../services/cctv_services.dart';
import '../../utils/app_constant.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/cctv_provider.dart';
import '../../providers/location_provider.dart';

class SubscriptionVideoScreen extends StatefulWidget {
  static const String routeName = "subscription-video-screen";

  const SubscriptionVideoScreen({super.key});

  @override
  State<SubscriptionVideoScreen> createState() =>
      _SubscriptionVideoScreenState();
}

class _SubscriptionVideoScreenState extends State<SubscriptionVideoScreen>
    with SingleTickerProviderStateMixin {
  final FijkPlayer player = FijkPlayer();

  late Timer timer;
  late Timer videoTimer;
  late SubscriptionVideoScreenArguments args;
  TabController? tabController;
  List<CCTVOtherModel> _CCTVOtherModelList = [];
  late CCTVModelDetail? otherCCTVDetail;
  late StreamSubscription _videoStreamSubscription;

  double _endLatitude = 0;
  double _endLongitude = 0;
  String _distanceInBetween = "";

  String latitude = "";
  String longitude = "";

  void _setTimer() {
    timer = Timer(const Duration(seconds: 7), () {
      Fluttertoast.showToast(
        msg: "Still loading... Please wait",
        toastLength: Toast.LENGTH_LONG,
        timeInSecForIosWeb: 5,
      );
    });
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

  void _fijkValueListener() {
    FijkState state = player.state;
    print("PlayerStates: ${state.index}");

    if (state.index == 0) {
      player.setDataSource(
        args.liveUrl,
        autoPlay: true,
      );
    }

    if (state.index == 4) {
      Fluttertoast.cancel();
      timer.cancel();
    }

    if (state.index == 6) {
      Future.delayed(const Duration(seconds: 5), () {
        print('error player reset!');
        player.reset(); // player will be in state 0
      });
    }

    if (state.index == 8) {
      print('video player in error state');
      Fluttertoast.cancel();
      timer.cancel();

      final snackBar = SnackBar(
        content: const Text('An error has occurred. Tap to retry'),
        action: SnackBarAction(
          label: "Retry",
          onPressed: (() {
            player.reset(); // player will be in state 0
            _setTimer();
          }),
        ),
        duration: const Duration(minutes: 1),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  // return Google Map URL
  String get getGoogleMapUrl {
    String lat = latitude;
    String long = longitude;
    return "https://www.google.com/maps/search/?api=1&query=$lat,$long";
  }

  // Open Google Maps
  Future<void> _launchGoogleMaps() async {
    if (latitude.isNotEmpty && longitude.isNotEmpty) {
      final Uri encodedURl = Uri.parse(getGoogleMapUrl);
      await launchUrl(
        encodedURl,
        mode: LaunchMode.externalApplication,
      );
    } else {
      Fluttertoast.showToast(msg: "Unable to open Google Maps");
    }
  }

  // Get other cameras  => API (need 5 cameras)
  Future<void> getOtherCamerasList(String deviceCode) async {
    try {
      Map<String, dynamic> data = {
        "channel": "02",
        "thridDeviceId": deviceCode,
      };
      _CCTVOtherModelList =
          await Provider.of<CCTVProvider>(context, listen: false)
              .queryNearbyDevicesListProvider(data);
      setState(() {});
    } catch (e) {
      print("getOtherCamerasList error: ${e.toString()}");
    }
  }

  //  Get CCTV Detail API
  Future<String?> getOtherLiveUrl(CCTVOtherModel cctvOtherModel) async {
    final CCTVServices cctvServices = CCTVServices();

    try {
      Map<String, dynamic> map = {
        "channel": cctvOtherModel.channel,
        "thridDeviceId": cctvOtherModel.cctvId,
        "urlType": AppConstant
            .urlType, // video type：1.rtsp、2.hls、3.rtmp、4.flv-http、5.dash
      };
      var response = await cctvServices.getCctvDetail(map);
      if (response["status"] == 200) {
        var liveUrl = response["obj"]["liveUrl"] as String?;

        if (liveUrl != null && liveUrl.isNotEmpty) {
          return liveUrl;
        } else {
          return null;
        }
      }
    } catch (e) {
      print("getOtherLiveUrl fail: ${e.toString()}");
    }
    return null;
  }

  Future<void> onSelectOtherCamera(CCTVOtherModel cctvOtherModel) async {
    try {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      GlobalDialogHelper().buildCircularProgressWithTextCenter(
          context: context, message: "Loading camera...");
      String? liveUrl = await getOtherLiveUrl(cctvOtherModel);

      if (liveUrl == null || liveUrl.isEmpty) {
        Navigator.of(context).pop();
        Fluttertoast.showToast(
            msg: "Camera cannot be played. Please try again later");
        return;
      }

      // To calculate distance in between for other cameras
      _distanceInBetween = getDistanceFromCoordinates(
        double.parse(cctvOtherModel.latitude),
        double.parse(cctvOtherModel.longitude),
        _endLatitude,
        _endLongitude,
      );

      Navigator.of(context).pop();
      Navigator.of(context).pushReplacementNamed(
        SubscriptionVideoScreen.routeName,
        arguments: SubscriptionVideoScreenArguments(
          cctvOtherModel.cctvId,
          liveUrl,
          cctvOtherModel.deviceName,
          cctvOtherModel.location,
          _distanceInBetween,
          cctvOtherModel.latitude,
          cctvOtherModel.longitude,
        ),
      );
    } catch (e) {
      Navigator.of(context).pop();
      print("onSelectOtherCamera error: ${e.toString()}");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      // Accessing the arguments passed to the modal route
      args = ModalRoute.of(context)!.settings.arguments
          as SubscriptionVideoScreenArguments;
      player.setDataSource(
        args.liveUrl,
        autoPlay: true,
        showCover: true,
      );
      player.addListener(_fijkValueListener);

      // Playback duration limit
      var playbackDurationLimit =
          Provider.of<SubscriptionProvider>(context, listen: false)
              .playbackDuration;
      _videoStreamSubscription =
          player.onCurrentPosUpdate.listen((Duration duration) {
        if (duration.inMinutes == int.parse(playbackDurationLimit)) {
          player.release();
          Fluttertoast.cancel();
          timer.cancel();

          final videoSnackBar = SnackBar(
            content:
                Text('$playbackDurationLimit-min playing duration reached.'),
            action: SnackBarAction(
              label: "Back",
              onPressed: () => Navigator.of(context).pop(),
            ),
            duration: const Duration(minutes: 1),
          );

          ScaffoldMessenger.of(context).showSnackBar(videoSnackBar);
        }
      });
      // get other cameras => API
      getOtherCamerasList(args.deviceCode);
      // CCTV latitude, longitude
      latitude = args.latitude;
      longitude = args.longitude;
    });
    _setTimer();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    LocationProvider locationProvider = Provider.of<LocationProvider>(context);
    if (locationProvider.currentLocation != null) {
      _endLatitude = locationProvider.currentLocation!.latitude;
      _endLongitude = locationProvider.currentLocation!.longitude;
    }
  }

  @override
  void dispose() async {
    // TODO: implement dispose
    super.dispose();
    if (timer.isActive) {
      timer.cancel();
    }
    Fluttertoast.cancel();
    player.removeListener(_fijkValueListener);
    player.release();
    _videoStreamSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final SubscriptionVideoScreenArguments args = ModalRoute.of(context)!
        .settings
        .arguments as SubscriptionVideoScreenArguments;

    return PopScope(
      canPop: true, //When false, blocks the current route from being popped.
      onPopInvoked: (bool didPop) {
        //do your logic here:
        ScaffoldMessenger.of(context).clearSnackBars();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalization.of(context)!.translate('live_cctv')!),
        ),
        body: Column(
          children: [
            SizedBox(
              height: screenSize.height * 0.32,
              child: FijkView(
                fs: true,
                player: player,
                color: Colors.black,
              ),
            ),
            TabBar(
              tabs: const [
                Tab(
                  icon: Icon(Icons.camera),
                  text: "Camera Details",
                ),
                Tab(
                  icon: Icon(Icons.more_horiz_outlined),
                  text: "Other Cameras",
                ),
              ],
              controller: tabController,
              indicatorSize: TabBarIndicatorSize.tab,
            ),
            Expanded(
              child: TabBarView(
                controller: tabController,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 15.0,
                      horizontal: 15.0,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  const Icon(Icons.location_pin),
                                  const SizedBox(
                                    width: 10.0,
                                  ),
                                  Flexible(
                                    child: Text(
                                      args.address,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Row(
                                children: <Widget>[
                                  const Icon(Icons.camera_outdoor),
                                  const SizedBox(
                                    width: 10.0,
                                  ),
                                  Flexible(
                                    child: Text(
                                      args.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Row(
                                children: <Widget>[
                                  const Icon(Icons.directions_walk_outlined),
                                  const SizedBox(
                                    width: 10.0,
                                  ),
                                  Text(
                                    "${args.distanceInBetween}KM from you",
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Container(
                                width: screenSize.width * 0.9,
                                margin: const EdgeInsets.only(
                                  bottom: 10.0,
                                ),
                                padding: const EdgeInsets.all(15.0),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondaryContainer,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10.0)),
                                ),
                                child: Column(
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        CircleAvatar(
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .background,
                                          radius: 16.0,
                                          child: Icon(
                                            Icons.tips_and_updates,
                                            size: 18.0,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10.0,
                                        ),
                                        const Text(
                                          "Note",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 5.0,
                                    ),
                                    const Text(
                                      "You can open the Google Maps if installed. Otherwise, open map browser to pinpoint the camera location.",
                                      style: TextStyle(
                                        fontSize: 13.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: screenSize.width * 0.9,
                                margin: const EdgeInsets.only(
                                  bottom: 5.0,
                                ),
                                child: ElevatedButton.icon(
                                  onPressed: _launchGoogleMaps,
                                  icon: const Icon(Icons.map_outlined),
                                  label: const Text("Google Maps"),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  _CCTVOtherModelList.isEmpty
                      ? Container(
                          margin:
                              EdgeInsets.only(top: screenSize.height * 0.05),
                          child: Column(
                            children: <Widget>[
                              SvgPicture.asset(
                                "assets/images/svg/no_data.svg",
                                width: screenSize.width * 0.5,
                                height: screenSize.width * 0.5,
                                semanticsLabel: 'No Data Logo',
                              ),
                              const SizedBox(
                                height: 10.0,
                              ),
                              const Text("No other cameras"),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5.0,
                            vertical: 5.0,
                          ),
                          shrinkWrap: true,
                          itemCount: _CCTVOtherModelList.length,
                          itemBuilder: ((context, index) {
                            return ListTile(
                              onTap: () => onSelectOtherCamera(
                                  _CCTVOtherModelList[index]),
                              title: Text(
                                _CCTVOtherModelList[index].location,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Text(
                                _CCTVOtherModelList[index].deviceName,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              trailing: SizedBox(
                                width: screenSize.width * 0.275,
                                height: screenSize.width * 0.2,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(5.0),
                                  child: Image.network(
                                    _CCTVOtherModelList[index].picUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Image.asset(
                                      "assets/images/icon/sioc.png",
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
