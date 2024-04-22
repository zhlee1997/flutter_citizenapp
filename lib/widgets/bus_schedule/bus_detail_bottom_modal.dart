import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/bus_provider.dart';
import '../../models/bus_model.dart';
import '../../utils/app_localization.dart';
import '../../utils/general_helper.dart';

class BusDetailMapBottom extends StatelessWidget {
  final double latitude;
  final double longitude;
  final List<BusStationCoordinatesModel> busStationList;
  final int currentValue;
  final List<BusStationModel> stationDetailList;
  final String stationName;

  const BusDetailMapBottom({
    required this.latitude,
    required this.longitude,
    required this.busStationList,
    required this.currentValue,
    required this.stationDetailList,
    required this.stationName,
    super.key,
  });

  // return Android Map URL
  String get getAndroidMapUrl {
    String lat = latitude.toString();
    String long = longitude.toString();
    return "https://www.google.com/maps/search/?api=1&query=$lat,$long";
  }

  // Launch Map App based on different mobile OS
  Future<void> launchMapApp(BuildContext context) async {
    final Uri encodedURl = Uri.parse(getAndroidMapUrl);
    await launchUrl(
      encodedURl,
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    String routeName = Provider.of<BusProvider>(context).routeName;

    return SizedBox(
      height: screenSize.height * 0.55,
      child: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              left: 20,
              top:
                  currentValue == 0 || currentValue == busStationList.length - 1
                      ? 70
                      : 20,
              right: 20,
              bottom: 20,
            ),
            margin: const EdgeInsets.only(
              top: 60,
            ),
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  if (currentValue != 0 &&
                      currentValue != busStationList.length - 1)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppLocalization.of(context)!
                              .translate('bus_station')!,
                          style: TextStyle(
                            fontSize: Platform.isIOS ? 20.0 : 15.0,
                          ),
                        ),
                        const SizedBox(
                          height: 5.0,
                        ),
                        Text(
                          routeName == 'DS'
                              ? 'DUN to Semenggoh'
                              : 'Semenggoh to DUN',
                          style: TextStyle(
                            fontSize: 15.0,
                            color: Colors.grey,
                          ),
                        )
                      ],
                    ),
                  Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 7.5,
                    ),
                    child: Text(
                      stationName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10.0,
                          ),
                          child: Text(
                            AppLocalization.of(context)!
                                .translate('scheduled_a')!,
                            style: TextStyle(
                              fontSize: 15.0,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10.0,
                            horizontal: 15.0,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).primaryColor,
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            stationDetailList.length == 0
                                ? '-'
                                : GeneralHelper.formatDateTime(
                                    dateString:
                                        stationDetailList[0].arrivalTime,
                                    format: 'HH : mm',
                                  ),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                        ),
                        child: Text(
                          AppLocalization.of(context)!.translate('next_a')!,
                          style: TextStyle(
                            fontSize: 15.0,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          stationDetailList.length <= 1
                              ? '-'
                              : GeneralHelper.formatDateTime(
                                  dateString: stationDetailList[1].arrivalTime,
                                  format: 'HH : mm',
                                ),
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 20.0,
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    // height: screenSize.height * 0.06,
                    width: screenSize.width * 0.9,
                    child: ElevatedButton(
                      onPressed: () => launchMapApp(context),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.map_outlined),
                          SizedBox(
                            width: 10,
                          ),
                          Text("Google Maps")
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          buildBusPhoto(context, screenSize),
        ],
      ),
    );
  }

  /// Displays asset image based on selected bus station
  ///
  /// Return image widget
  Widget buildBusPhoto(
    BuildContext ctx,
    Size size,
  ) {
    String routeName = Provider.of<BusProvider>(ctx).routeName;

    if (currentValue == 0 && routeName == 'DS') {
      return Positioned(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: SizedBox(
            width: 220,
            height: 120,
            child: Image.asset(
              'assets/images/pictures/bus_schedule/dun.jpeg',
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    } else if (currentValue == busStationList.length - 1 && routeName == 'DS') {
      return Positioned(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: SizedBox(
            width: 220,
            height: 120,
            child: Image.asset(
              'assets/images/pictures/bus_schedule/semenggoh.jpeg',
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    } else if (currentValue == 0 && routeName == 'SD') {
      return Positioned(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: SizedBox(
            width: 220,
            height: 120,
            child: Image.asset(
              'assets/images/pictures/bus_schedule/semenggoh.jpeg',
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    } else if (currentValue == busStationList.length - 1 && routeName == 'SD') {
      return Positioned(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: SizedBox(
            width: 220,
            height: 120,
            child: Image.asset(
              'assets/images/pictures/bus_schedule/dun.jpeg',
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
  }
}
