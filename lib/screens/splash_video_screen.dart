import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import '../providers/settings_provider.dart';
// import '../providers/language_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/location_provider.dart';
// import '../providers/bus_provider.dart';
// import '../providers/inbox_provider.dart';

import './home_screen.dart';
import './onboarding_screen.dart';
// import '../utils/general_helper.dart';
import '../utils/app_constant.dart';
// import '../utils/notification/push_notification.dart';

class SplashVideoScreen extends StatefulWidget {
  const SplashVideoScreen({super.key});

  @override
  State<SplashVideoScreen> createState() => _SplashVideoScreenState();
}

class _SplashVideoScreenState extends State<SplashVideoScreen> {
  late VlcPlayerController _videoPlayerController;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VlcPlayerController.asset(
      AppConstant.splashVideoFilename,
      hwAcc: HwAcc.full,
      autoPlay: true,
      options: VlcPlayerOptions(),
    );
    _videoPlayerController.addListener(() async {
      final prefs = await SharedPreferences.getInstance();
      if (_videoPlayerController.value.playingState == PlayingState.ended) {
        final bool? isAppFirstStart = prefs.getBool('isAppFirstStart');
        if (isAppFirstStart != null && isAppFirstStart) {
          // TODO: shared preferences => isAppFirstStart: true
          // TODO: if true, no need to get auth, location (no permission), inbox, language, music
          // TODO: need to get bus route
          Provider.of<LocationProvider>(context, listen: false)
              .getCurrentLocation();
          Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
          return;
        } else {
          // TODO: if false, need to get auth, location, inbox, language, music, bus route
          // TODO: can show a loading spinner in end of video, after complete then navigate to HomeScreen
          Navigator.of(context)
              .pushReplacementNamed(OnboardingScreen.routeName);
          return;
        }
      }
    });

    Provider.of<AuthProvider>(context, listen: false).checkIsAuth(context);
  }

  @override
  void dispose() async {
    // TODO: implement dispose
    super.dispose();
    await _videoPlayerController.stopRendererScanning();
    await _videoPlayerController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Center(
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: VlcPlayer(
              controller: _videoPlayerController,
              aspectRatio: 16 / 9,
              placeholder: const Center(child: CircularProgressIndicator()),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: EdgeInsets.only(bottom: screenSize.width * 0.2),
              child: const CircularProgressIndicator(),
            ),
          )
        ],
      ),
    );
  }
}
