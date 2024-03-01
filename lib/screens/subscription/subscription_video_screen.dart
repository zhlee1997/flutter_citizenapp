import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fijkplayer/fijkplayer.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../utils/app_localization.dart';
import '../../arguments/subscription_video_screen_arguments.dart';

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
  late SubscriptionVideoScreenArguments args;
  TabController? tabController;

  void _timer() {
    timer = Timer(const Duration(seconds: 7), () {
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
            _timer();
          }),
        ),
        duration: const Duration(minutes: 1),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
    });
    _timer();
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
              // unselectedLabelColor: Colors.black,
              // labelColor: Colors.red,
              tabs: const [
                Tab(
                  icon: Icon(Icons.details_outlined),
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
                // physics: AlwaysScrollableScrollPhysics(),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 15.0,
                      horizontal: 15.0,
                    ),
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
                                Text(
                                  args.address,
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
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
                                Text(
                                  args.name,
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
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
                                  "5 KM",
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
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
                                bottom: 5.0,
                              ),
                              child: ElevatedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.map_outlined),
                                label: const Text("Google Maps"),
                              ),
                            ),
                            Container(
                              width: screenSize.width * 0.85,
                              margin: const EdgeInsets.only(
                                bottom: 10.0,
                              ),
                              child: Text(
                                "Note: This will open the Google Maps if installed. Otherwise, open map in browser to pinpoint the camera location.",
                                style: TextStyle(
                                  fontSize: 12.0,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: 5.0,
                      vertical: 5.0,
                    ),
                    shrinkWrap: true,
                    itemCount: 5,
                    itemBuilder: ((context, index) {
                      return ListTile(
                        title: Text(
                          "Timberland Hospital",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          "Bandar Selamat CCTV",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        trailing: Container(
                          width: screenSize.width * 0.275,
                          height: screenSize.width * 0.2,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5.0),
                            child: Image.asset(
                              "assets/images/pictures/kuching_city.jpeg",
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
