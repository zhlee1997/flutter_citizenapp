import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geocoding/geocoding.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../providers/emergency_provider.dart';
import '../../providers/location_provider.dart';
import '../../utils/app_localization.dart';

class EmergencyBottomModal extends StatefulWidget {
  final VoidCallback handleProceedNext;
  final int category;

  const EmergencyBottomModal({
    required this.handleProceedNext,
    required this.category,
    super.key,
  });

  @override
  State<EmergencyBottomModal> createState() => _EmergencyBottomModalState();
}

class _EmergencyBottomModalState extends State<EmergencyBottomModal> {
  String _address = "";
  double _latitude = 0;
  double _longitude = 0;

  String returnCategoryInText(int category) {
    switch (category) {
      case 0:
        return AppLocalization.of(context)!.translate('harassment')!;
      case 1:
        return AppLocalization.of(context)!.translate('fire/rescue')!;
      case 2:
        return AppLocalization.of(context)!
            .translate('traffic_accident/injuries')!;
      case 3:
        return AppLocalization.of(context)!.translate('theft/robbery')!;
      case 4:
        return AppLocalization.of(context)!.translate('physical_violence')!;
      case 5:
        return AppLocalization.of(context)!.translate('others')!;
      default:
        return AppLocalization.of(context)!.translate('voice_recording')!;
    }
  }

  /// Perform geocoding from coordinates to get address
  ///
  /// Receives [latitude] and [longitude] as the latitude and longitude
  Future<void> _geocodeAddress(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      String name = placemarks[0].name != '' ? '${placemarks[0].name}, ' : '';
      String subLocal = placemarks[0].subLocality != ''
          ? '${placemarks[0].subLocality}, '
          : '';
      String thoroughfare =
          placemarks[0].thoroughfare != '' && Platform.isAndroid
              ? '${placemarks[0].thoroughfare}, '
              : '';
      _address =
          '$name$thoroughfare$subLocal${placemarks[0].locality}, ${placemarks[0].administrativeArea}, ${placemarks[0].postalCode}';
      if (mounted) {
        Provider.of<EmergencyProvider>(context, listen: false)
            .setAddressAndLocation(
          address: _address,
          latitide: latitude,
          longitude: longitude,
        );
        setState(() {});
      }
    } catch (e) {
      // Fluttertoast.showToast(msg: "Geocode error. Please try again");
      print("_geocodeAddress error: ${e.toString()}");
    }
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    final LocationProvider locationProvider =
        Provider.of<LocationProvider>(context);
    if (locationProvider.currentLocation != null) {
      _latitude = locationProvider.currentLocation!.latitude;
      _longitude = locationProvider.currentLocation!.longitude;
      _geocodeAddress(_latitude, _longitude);
    } else {
      // no location permission (just in case)
      // because emergency cannot access if no location permission
      _latitude = 1.576472;
      _longitude = 110.345828;
      _geocodeAddress(_latitude, _longitude);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      width: double.infinity,
      child: Stack(children: <Widget>[
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.only(
                top: 20.0,
                bottom: 10.0,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 5.0,
              ),
              child: Text(
                AppLocalization.of(context)!
                    .translate('are_you_the_one_in_need_of_help')!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 10.0),
              child: Text(returnCategoryInText(widget.category)),
            ),
            Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Colors.red,
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () {
                    Provider.of<EmergencyProvider>(context, listen: false)
                        .setOtherText(null);
                    // Emergency provider => yourself: true
                    Provider.of<EmergencyProvider>(context, listen: false)
                        .setCategoryAndYourself(
                      category: widget.category,
                      yourself: true,
                    );
                    widget.handleProceedNext();
                  },
                  child: Text(
                    AppLocalization.of(context)!.translate('yes')!,
                    style: const TextStyle(
                      fontSize: 16.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Colors.grey,
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(),
                  onPressed: () {
                    Provider.of<EmergencyProvider>(context, listen: false)
                        .setOtherText(null);
                    // Emergency provider => yourself: false
                    Provider.of<EmergencyProvider>(context, listen: false)
                        .setCategoryAndYourself(
                      category: widget.category,
                      yourself: false,
                    );
                    widget.handleProceedNext();
                  },
                  child: Text(
                    AppLocalization.of(context)!.translate('no')!,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20.0,
            )
          ],
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: 60,
              height: 5,
              decoration: const BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
