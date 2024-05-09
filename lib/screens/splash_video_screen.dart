import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/settings_provider.dart';
import '../providers/language_provider.dart';
import '../providers/bus_provider.dart';
import '../providers/inbox_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/location_provider.dart';
import '../providers/subscription_provider.dart';
import '../providers/announcement_provider.dart';

import './home_screen.dart';
import './onboarding_screen.dart';
import '../utils/app_constant.dart';
import '../utils/notification/push_notification.dart';

class SplashVideoScreen extends StatefulWidget {
  const SplashVideoScreen({super.key});

  @override
  State<SplashVideoScreen> createState() => _SplashVideoScreenState();
}

class _SplashVideoScreenState extends State<SplashVideoScreen> {
  late VlcPlayerController _videoPlayerController;
  bool _isLoading = false;
  PushNotification _pushNotification = PushNotification();
  bool isAuth = false;
  bool isPushNotificationEnabled = false;

  @override
  void initState() {
    super.initState();
    Provider.of<SettingsProvider>(context, listen: false).checkSettings();
    _videoPlayerController = VlcPlayerController.asset(
      AppConstant.splashVideoFilename,
      hwAcc: HwAcc.full,
      options: VlcPlayerOptions(),
    );
    _videoPlayerController.addOnInitListener(() {
      bool isMusicEnabled =
          Provider.of<SettingsProvider>(context, listen: false)
              .isSplashScreenMusicEnabled;
      if (isMusicEnabled) {
        _videoPlayerController.setVolume(100);
      } else {
        _videoPlayerController.setVolume(0);
      }
    });
    _videoPlayerController.addListener(() async {
      final prefs = await SharedPreferences.getInstance();
      if (_videoPlayerController.value.playingState == PlayingState.ended) {
        final bool? isAppFirstStart = prefs.getBool('isAppFirstStart');
        if (isAppFirstStart != null && isAppFirstStart) {
          setState(() {
            _isLoading = true;
          });
          // TODO: if false, need to get auth (init, check local storage and check subscribe due date), location, inbox, language, music, bus route
          // TODO: need to get push notification status (local) -> if Auth & disable status, no need to get FCM Token; if no Auth, no need
          // TODO: can show a loading spinner in end of video, after complete then navigate to HomeScreen
          // TODO: check subscription package and whether enabled
          // TODO: need to get major announcements

          try {
            await Provider.of<LocationProvider>(context, listen: false)
                .getCurrentLocation();
          } catch (e) {
            print("getCurrentLocation error: ${e.toString()}");
          }

          try {
            await Provider.of<LanguageProvider>(context, listen: false)
                .checkLanguage();
          } catch (e) {
            print("checkLanguage error: ${e.toString()}");
          }

          try {
            await Provider.of<BusProvider>(context, listen: false)
                .setBusRouteProvider();
          } catch (e) {
            print("setBusRouteProvider error: ${e.toString()}");
          }

          try {
            await Provider.of<AnnouncementProvider>(context, listen: false)
                .queryandSetMajorAnnouncementProvider(context);
          } catch (e) {
            print(
                "queryandSetMajorAnnouncementProvider error: ${e.toString()}");
          }

          try {
            await Provider.of<SubscriptionProvider>(context, listen: false)
                .queryAndSetIsSubscriptionEnabled();
          } catch (e) {
            print("queryAndSetIsSubscriptionEnabled error: ${e.toString()}");
          }

          try {
            isAuth = await Provider.of<AuthProvider>(context, listen: false)
                .checkIsAuthAndSubscribeOverdue(context);
          } catch (e) {
            print("checkIsAuthAndSubscribeOverdue error: ${e.toString()}");
          }

          if (isAuth) {
            // Refresh Token Provider
            // After checking is within the valid refresh period (checkIsAuthAndSubscribeOverdue), then refresh token (everytime open app)
            try {
              await Provider.of<AuthProvider>(context, listen: false)
                  .refreshTokenProvider();
            } catch (e) {
              print("refreshTokenProvider error: ${e.toString()}");
            }

            try {
              await Provider.of<InboxProvider>(context, listen: false)
                  .refreshCount();
            } catch (e) {
              print("refreshCount error: ${e.toString()}");
            }

            try {
              isPushNotificationEnabled =
                  await Provider.of<SettingsProvider>(context, listen: false)
                      .checkPushNotification();
            } catch (e) {
              print("checkPushNotification error: ${e.toString()}");
            }

            if (isPushNotificationEnabled) {
              try {
                await _pushNotification.setFirebase(true);
              } catch (e) {
                print("setFirebase error: ${e.toString()}");
              }

              Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
            } else {
              try {
                await _pushNotification.setFirebase(false);
              } catch (e) {
                print("setFirebase false error: ${e.toString()}");
              }

              Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
            }
          } else {
            try {
              await _pushNotification.setFirebase(false);
            } catch (e) {
              print("setFirebase false error: ${e.toString()}");
            }

            Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
          }

          return;
        } else {
          // TODO: shared preferences => isAppFirstStart: true
          // TODO: if true, no need to get auth, location (no permission), inbox, language, music, push notification
          // TODO: need to get bus route
          // TODO: need to get major announcements

          setState(() {
            _isLoading = true;
          });
          try {
            await Provider.of<BusProvider>(context, listen: false)
                .setBusRouteProvider();
          } catch (e) {
            print("setBusRouteProvider error: ${e.toString()}");
          }

          try {
            await Provider.of<AnnouncementProvider>(context, listen: false)
                .queryandSetMajorAnnouncementProvider(context);
          } catch (e) {
            print(
                "queryandSetMajorAnnouncementProvider error: ${e.toString()}");
          }

          try {
            await Provider.of<SubscriptionProvider>(context, listen: false)
                .queryAndSetIsSubscriptionEnabled();
          } catch (e) {
            print("queryAndSetIsSubscriptionEnabled error: ${e.toString()}");
          }

          Navigator.of(context)
              .pushReplacementNamed(OnboardingScreen.routeName);
          return;
        }
      }
    });
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
          if (_isLoading)
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
