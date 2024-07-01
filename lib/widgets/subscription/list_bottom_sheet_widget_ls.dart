import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';

import '../../utils/app_localization.dart';
import '../../providers/location_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../screens/subscription/subscription_video_screen_ls.dart';
import '../../arguments/subscription_video_screen_arguments.dart';
import '../../models/cctv_model.dart';
import '../../providers/cctv_provider.dart';
import '../../config/app_config.dart';

// ignore: must_be_immutable
class ListBottomSheetWidgetLS extends StatefulWidget {
  final String cctvLatitude;
  final String cctvLongitude;
  final String cctvName;
  final String cctvLocation;
  final String imageUrl;

  const ListBottomSheetWidgetLS({
    required this.cctvName,
    required this.cctvLocation,
    required this.cctvLatitude,
    required this.cctvLongitude,
    required this.imageUrl,
    super.key,
  });

  @override
  State<ListBottomSheetWidgetLS> createState() =>
      _ListBottomSheetWidgetLSState();
}

class _ListBottomSheetWidgetLSState extends State<ListBottomSheetWidgetLS> {
  late CCTVProvider cctvProvider;
  late SubscriptionProvider subscriptionProvider;

  double endLatitude = 0;
  double endLongitude = 0;
  String distanceInBetween = "";

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

  String amendCCTVToken(String cctvId) {
    if (cctvId.isNotEmpty) {
      String updatedString = cctvId.replaceAll('#', '_');
      return "0ba9--$updatedString";
    } else {
      return "";
    }
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    subscriptionProvider =
        Provider.of<SubscriptionProvider>(context, listen: false);
    cctvProvider = Provider.of<CCTVProvider>(context, listen: false);
    LocationProvider locationProvider = Provider.of<LocationProvider>(context);
    if (locationProvider.currentLocation != null) {
      endLatitude = locationProvider.currentLocation!.latitude;
      endLongitude = locationProvider.currentLocation!.longitude;
      distanceInBetween = getDistanceFromCoordinates(
        double.parse(widget.cctvLatitude),
        double.parse(widget.cctvLongitude),
        endLatitude,
        endLongitude,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final CCTVModelDetail? cctvDetail = cctvProvider.cctvModelDetail;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Image.network(
            widget.imageUrl,
            width: double.infinity,
            height: screenSize.height * 0.25,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Image.asset(
              "assets/images/icon/sioc.png",
              width: double.infinity,
              height: screenSize.height * 0.25,
              fit: BoxFit.fill,
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
              widget.cctvLocation,
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
            child: Text(
              widget.cctvName,
              textAlign: TextAlign.center,
            ),
          ),
          // Container(
          //   margin: const EdgeInsets.only(
          //     left: 20.0,
          //     right: 20.0,
          //     bottom: 5.0,
          //   ),
          //   child: Text("${distanceInBetween}KM from you"),
          // ),
          SizedBox(
            width: screenSize.width * 0.9,
            // height: screenSize.height * 0.06,
            child: ElevatedButton(
              onPressed: cctvDetail != null &&
                      !cctvDetail.liveUrl.contains("get live url is fail")
                  ? () async {
                      var cctvId =
                          Provider.of<CCTVProvider>(context, listen: false)
                              .cctvModelDetail!
                              .id;
                      String newCCTVId = amendCCTVToken(cctvId);
                      String session =
                          Provider.of<CCTVProvider>(context, listen: false)
                              .sessionLS;
                      String liveUrl = AppConfig().isProductionInternal
                          ? "https://10.16.24.144:18445/rtc.html?token=$newCCTVId&session=$session"
                          : "https://video.sioc.sma.gov.my:18445/rtc.html?token=$newCCTVId&session=$session";
                      Navigator.of(context).pop();
                      Navigator.pushNamed(
                        context,
                        SubscriptionVideoScreenLS.routeName,
                        arguments: SubscriptionVideoScreenArguments(
                          cctvDetail.id,
                          liveUrl,
                          widget.cctvName,
                          widget.cctvLocation,
                          distanceInBetween,
                          widget.cctvLatitude,
                          widget.cctvLongitude,
                        ),
                      );
                    }
                  : null,
              style: cctvDetail != null &&
                      !cctvDetail.liveUrl.contains("get live url is fail")
                  ? ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          Theme.of(context).colorScheme.secondary),
                    )
                  : null,
              child: Text(
                AppLocalization.of(context)!.translate('play_now')!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Text(
            cctvDetail != null &&
                    !cctvDetail.liveUrl.contains("get live url is fail")
                ? "Each video session is ${subscriptionProvider.playbackDuration} minutes"
                : "Unable to get video stream. Try again",
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(
            height: 20.0,
          )
        ],
      ),
    );
  }
}
