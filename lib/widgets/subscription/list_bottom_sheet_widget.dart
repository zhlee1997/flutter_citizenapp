import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';

import '../../utils/app_localization.dart';
import '../../providers/location_provider.dart';
import '../../screens/subscription/subscription_video_screen.dart';
import '../../arguments/subscription_video_screen_arguments.dart';

// ignore: must_be_immutable
class ListBottomSheetWidget extends StatelessWidget {
  final String cctvLatitude;
  final String cctvLongitude;
  final String cctvName;
  final String cctvLocation;
  final String imageUrl;
  final String liveUrl;

  const ListBottomSheetWidget({
    required this.cctvName,
    required this.cctvLocation,
    required this.cctvLatitude,
    required this.cctvLongitude,
    required this.imageUrl,
    required this.liveUrl,
    super.key,
  });

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
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    double endLatitude = 0;
    double endLongitude = 0;
    String distanceInBetween = "";

    LocationProvider locationProvider = Provider.of<LocationProvider>(context);
    if (locationProvider.currentLocation != null) {
      endLatitude = locationProvider.currentLocation!.latitude;
      endLongitude = locationProvider.currentLocation!.longitude;
      distanceInBetween = getDistanceFromCoordinates(
        double.parse(cctvLatitude),
        double.parse(cctvLongitude),
        endLatitude,
        endLongitude,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Image.network(
          imageUrl,
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
        Container(
          margin: const EdgeInsets.only(
            top: 20.0,
            left: 20.0,
            right: 20.0,
            bottom: 10.0,
          ),
          // width: double.infinity,
          child: Text(
            cctvLocation,
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
                cctvName,
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
                "${distanceInBetween}KM from you",
              )
            ],
          ),
        ),
        SizedBox(
          width: screenSize.width * 0.9,
          // height: screenSize.height * 0.06,
          child: ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              Navigator.pushNamed(
                context,
                SubscriptionVideoScreen.routeName,
                arguments: SubscriptionVideoScreenArguments(
                  liveUrl,
                  cctvName,
                  cctvLocation,
                  distanceInBetween,
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
}
