import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:geocoding/geocoding.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../providers/emergency_provider.dart';
import '../../utils/app_localization.dart';
import '../../providers/location_provider.dart';

class OtherEmergencyBottomModal extends StatefulWidget {
  final VoidCallback handleProceedNext;
  final GlobalKey<FormState> formKey;

  const OtherEmergencyBottomModal({
    required this.handleProceedNext,
    required this.formKey,
    super.key,
  });

  @override
  State<OtherEmergencyBottomModal> createState() =>
      _OtherEmergencyBottomModalState();
}

class _OtherEmergencyBottomModalState extends State<OtherEmergencyBottomModal> {
  String _address = "";
  double _latitude = 0;
  double _longitude = 0;
  final TextEditingController textEditingController = TextEditingController();

  final int _otherTextFormFieldLengthLimit = 50;

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
      Fluttertoast.showToast(msg: "Geocode error. Please try again");
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
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
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
                      .translate('enter_here_to_tell_us_more')!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 5.0,
                ),
                child: Form(
                  key: widget.formKey,
                  child: TextFormField(
                      maxLength: _otherTextFormFieldLengthLimit,
                      controller: textEditingController,
                      decoration: InputDecoration(
                        labelText: AppLocalization.of(context)!
                            .translate('describe_your_emergency_to_us')!,
                      ),
                      textInputAction: TextInputAction.done,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(
                            _otherTextFormFieldLengthLimit),
                      ],
                      validator: (String? v) {
                        if (v == null || v.isEmpty) {
                          return AppLocalization.of(context)!
                              .translate('Please enter some text')!;
                        }
                        return null;
                      }),
                ),
              ),
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
                      if (!widget.formKey.currentState!.validate()) {
                        return;
                      }
                      Provider.of<EmergencyProvider>(context, listen: false)
                          .setOtherText(textEditingController.text);
                      // others category => 5
                      // Emergency provider => yourself: true
                      Provider.of<EmergencyProvider>(context, listen: false)
                          .setCategoryAndYourself(
                        category: 5,
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
                      if (!widget.formKey.currentState!.validate()) {
                        return;
                      }
                      Provider.of<EmergencyProvider>(context, listen: false)
                          .setOtherText(textEditingController.text);
                      // others category => 5
                      // Emergency provider => yourself: false
                      Provider.of<EmergencyProvider>(context, listen: false)
                          .setCategoryAndYourself(
                        category: 5,
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
      ),
    );
  }
}
