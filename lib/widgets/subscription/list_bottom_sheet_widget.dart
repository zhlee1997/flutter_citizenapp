import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';

import '../../utils/app_localization.dart';
import '../../providers/location_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../screens/subscription/subscription_video_screen.dart';
import '../../arguments/subscription_video_screen_arguments.dart';
import '../../models/cctv_model.dart';
import '../../providers/cctv_provider.dart';

// ignore: must_be_immutable
class ListBottomSheetWidget extends StatefulWidget {
  final String cctvLatitude;
  final String cctvLongitude;
  final String cctvName;
  final String cctvLocation;
  final String imageUrl;

  const ListBottomSheetWidget({
    required this.cctvName,
    required this.cctvLocation,
    required this.cctvLatitude,
    required this.cctvLongitude,
    required this.imageUrl,
    super.key,
  });

  @override
  State<ListBottomSheetWidget> createState() => _ListBottomSheetWidgetState();
}

class _ListBottomSheetWidgetState extends State<ListBottomSheetWidget> {
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
            widget.imageUrl + "12",
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
              onPressed: cctvDetail != null && cctvDetail.liveUrl.isNotEmpty
                  ? () async {
                      Navigator.of(context).pop();
                      Navigator.pushNamed(
                        context,
                        SubscriptionVideoScreen.routeName,
                        arguments: SubscriptionVideoScreenArguments(
                          cctvDetail.id,
                          cctvDetail.liveUrl,
                          widget.cctvName,
                          widget.cctvLocation,
                          distanceInBetween,
                          widget.cctvLatitude,
                          widget.cctvLongitude,
                        ),
                      );
                    }
                  : null,
              style: cctvDetail != null && cctvDetail.liveUrl.isNotEmpty
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
}
