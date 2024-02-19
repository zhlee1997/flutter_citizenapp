import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

// import '../providers/settings_provider.dart';
// import '../providers/language_provider.dart';
import '../providers/auth_provider.dart';
// import '../providers/location_provider.dart';
// import '../providers/bus_provider.dart';
// import '../providers/inbox_provider.dart';

import './home_screen.dart';
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
    _videoPlayerController.addListener(() {
      if (_videoPlayerController.value.playingState == PlayingState.ended) {
        Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
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
    return Center(
      child: VlcPlayer(
        controller: _videoPlayerController,
        aspectRatio: 16 / 9,
        placeholder: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
