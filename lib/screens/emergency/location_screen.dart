import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';

import '../../providers/location_provider.dart';
import '../../providers/emergency_provider.dart';

class LocationScreen extends StatefulWidget {
  // final VoidCallback handleProceedNextWOPop;

  const LocationScreen({
    // required this.handleProceedNextWOPop,
    super.key,
  });

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  String _address = "";
  late double _latitude;
  late double _longitude;
  CameraPosition _cameraPosition = const CameraPosition(
    target: LatLng(1.576472, 110.345828),
    zoom: 14.4746,
  );

  /// Perform geocoding from coordinates to get address
  ///
  /// Receives [latitude] and [longitude] as the latitude and longitude
  Future<void> _geocodeAddress(double latitude, double longitude) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latitude, longitude);
    String name = placemarks[0].name != '' ? '${placemarks[0].name}, ' : '';
    String subLocal =
        placemarks[0].subLocality != '' ? '${placemarks[0].subLocality}, ' : '';
    String thoroughfare = placemarks[0].thoroughfare != '' && Platform.isAndroid
        ? '${placemarks[0].thoroughfare}, '
        : '';
    _address =
        '$name$thoroughfare$subLocal${placemarks[0].locality}, ${placemarks[0].administrativeArea}, ${placemarks[0].postalCode}';
    Provider.of<EmergencyProvider>(context, listen: false)
        .setAddressAndLocation(
      address: _address,
      latitide: latitude,
      longitude: longitude,
    );
    setState(() {});
  }

  /// Renders marker on Google Map when tapping on the map
  ///
  /// Receives [point] as the coordinate of the selected location
  Future<void> _handleCameraMove(CameraPosition cameraPosition) async {
    setState(() {
      _latitude = cameraPosition.target.latitude;
      _longitude = cameraPosition.target.longitude;
    });
  }

  @override
  void initState() {
    // _category = '1';

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Provider.of<LocationProvider>(context, listen: false)
          .getCurrentLocation();
    });
    super.initState();
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
      _cameraPosition = CameraPosition(
        target: LatLng(_latitude, _longitude),
        zoom: 14.4746,
      );
      _geocodeAddress(_latitude, _longitude);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: screenSize.width,
          height: screenSize.height * 0.55,
          child: Stack(
            children: <Widget>[
              GoogleMap(
                initialCameraPosition: _cameraPosition,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
                myLocationEnabled: true,
                onCameraMove: _handleCameraMove,
                onCameraIdle: () {
                  _geocodeAddress(_latitude, _longitude);
                },
              ),
              const Align(
                alignment: Alignment.center,
                child: Icon(
                  Icons.location_pin,
                  size: 45,
                  color: Colors.redAccent,
                ),
              )
            ],
          ),
        ),
        Text(
          _address,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
          ),
        ),
        Text("${_latitude.toString()}, ${_longitude.toString()}"),
        const SizedBox(
          height: 10.0,
        )
      ],
    );
  }
}
