import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fijkplayer/fijkplayer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/app_localization.dart';
import '../../arguments/subscription_video_screen_arguments.dart';
import '../../models/cctv_model.dart';
import '../../services/cctv_services.dart';
import '../../utils/app_constant.dart';
import '../../providers/subscription_provider.dart';

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
  List<CCTVSnapshotModel> _listCCTVSnapshotModel = [];
  late CCTVModelDetail? otherCCTVDetail;
  late StreamSubscription _videoStreamSubscription;

  void _setTimer() {
    timer = Timer(const Duration(seconds: 7), () {
      Fluttertoast.showToast(
        msg: "Still loading... Please wait",
        toastLength: Toast.LENGTH_LONG,
        timeInSecForIosWeb: 5,
      );
    });
  }

  void _setVideoTimer(int minutes) {
    videoTimer = Timer(Duration(seconds: minutes), () {
      Fluttertoast.showToast(
        msg: "Still loading... Please wait",
        toastLength: Toast.LENGTH_LONG,
        timeInSecForIosWeb: 5,
      );
    });
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
    // TODO: use args for latitude and longitude
    String lat = "1.553110";
    String long = "110.345032";
    return "https://www.google.com/maps/search/?api=1&query=$lat,$long";
  }

  // TODO: Open Google Maps
  Future<void> _launchGoogleMaps() async {
    final Uri encodedURl = Uri.parse(getGoogleMapUrl);
    await launchUrl(encodedURl, mode: LaunchMode.externalApplication);
  }

  // TODO: Get Snapshots API (need 5 cameras)
  Future<void> getSnapshotList(Map<String, dynamic> data) async {
    final CCTVServices cctvServices = CCTVServices();

    try {
      var response = await cctvServices.queryCCTVSnapshotList(data);
      if (response["status"] == "200") {
        setState(() {
          _listCCTVSnapshotModel = response["obj"];
        });
      }
    } catch (e) {
      print("getSnapshotList fail: ${e.toString()}");
    }
  }

  // TODO: Get other cameras (need 5 cameras)
  Future<void> getOtherCamerasList() async {
    // TODO: Get other Cameras => API
    setState(() {
      _listCCTVSnapshotModel = [
        CCTVSnapshotModel(
          cctvId: "1",
          imageUrl:
              "https://images.lifestyleasia.com/wp-content/uploads/sites/5/2022/07/15175110/Hero_Sarawak_River-1600x900.jpg",
          channel: "02",
          deviceName: "SIOC Other CCTV 1",
          location: "SIOC Kuching 1",
          latitude: "0",
          longitude: "1",
        ),
        CCTVSnapshotModel(
          cctvId: "2",
          imageUrl:
              "https://images.lifestyleasia.com/wp-content/uploads/sites/5/2022/07/15175110/Hero_Sarawak_River-1600x900.jpg",
          channel: "02",
          deviceName: "SIOC Other CCTV 2",
          location: "SIOC Kuching 2",
          latitude: "0",
          longitude: "1",
        ),
        CCTVSnapshotModel(
          cctvId: "3",
          imageUrl:
              "https://images.lifestyleasia.com/wp-content/uploads/sites/5/2022/07/15175110/Hero_Sarawak_River-1600x900.jpg",
          channel: "02",
          deviceName: "SIOC Other CCTV 3",
          location: "SIOC Kuching 3",
          latitude: "0",
          longitude: "1",
        ),
        CCTVSnapshotModel(
          cctvId: "4",
          imageUrl:
              "https://images.lifestyleasia.com/wp-content/uploads/sites/5/2022/07/15175110/Hero_Sarawak_River-1600x900.jpg",
          channel: "02",
          deviceName: "SIOC Other CCTV 4",
          location: "SIOC Kuching 4",
          latitude: "0",
          longitude: "1",
        ),
        CCTVSnapshotModel(
          cctvId: "5",
          imageUrl:
              "https://images.lifestyleasia.com/wp-content/uploads/sites/5/2022/07/15175110/Hero_Sarawak_River-1600x900.jpg",
          channel: "02",
          deviceName: "SIOC Other CCTV 5",
          location: "SIOC Kuching 5",
          latitude: "0",
          longitude: "1",
        )
      ];
    });
  }

  // TODO: Get CCTV Detail API
  Future<void> getCCTVDetail(CCTVModel data) async {
    final CCTVServices cctvServices = CCTVServices();

    try {
      Map<String, dynamic> map = {
        "channel": data.channel,
        "thridDeviceId": data.cctvId,
        "urlType": AppConstant
            .urlType, // video type：1.rtsp、2.hls、3.rtmp、4.flv-http、5.dash
      };
      var response = await cctvServices.getCctvDetail(map);
      if (response["status"] == "200") {
        setState(() {
          _listCCTVSnapshotModel = response["obj"];
        });
      }
    } catch (e) {
      print("getCCTVDetail fail: ${e.toString()}");
    }
  }

  // TODO: Get camera detail for liveUrl and navigate page
  Future<void> getCameraDetail(CCTVSnapshotModel cctvSnapshotModel) async {
    // TODO: Get camera detail => API
    // TODO: temp static data => otherCCTVDetail
    otherCCTVDetail = CCTVModelDetail(
      id: "1",
      name: "SIOC CCTV 1",
      location: "Bangunan Baitulmakmur 1",
      image:
          "https://images.lifestyleasia.com/wp-content/uploads/sites/5/2022/07/15175110/Hero_Sarawak_River-1600x900.jpg",
      updateTime: "updateTime1",
      liveUrl:
          "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
    );

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    // TODO: To calculate distance in between for other cameras
    Navigator.of(context).pushReplacementNamed(
      SubscriptionVideoScreen.routeName,
      arguments: SubscriptionVideoScreenArguments(
        otherCCTVDetail!.liveUrl,
        otherCCTVDetail!.name,
        otherCCTVDetail!.location,
        "12",
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      // TODO: API => load other cameras
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
        // TODO: need to change in minutes
        if (duration.inSeconds == int.parse(playbackDurationLimit)) {
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
    });
    _setTimer();
    // TODO: get other cameras => API
    getOtherCamerasList();
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
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5.0,
                      vertical: 5.0,
                    ),
                    shrinkWrap: true,
                    itemCount: _listCCTVSnapshotModel.length,
                    itemBuilder: ((context, index) {
                      return ListTile(
                        onTap: () =>
                            getCameraDetail(_listCCTVSnapshotModel[index]),
                        title: Text(
                          _listCCTVSnapshotModel[index].location,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          _listCCTVSnapshotModel[index].deviceName,
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
                              _listCCTVSnapshotModel[index].imageUrl,
                              fit: BoxFit.cover,
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
