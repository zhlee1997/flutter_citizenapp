import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(1.576472, 110.345828),
    zoom: 14.4746,
  );

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

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
                initialCameraPosition: LocationScreen._kGooglePlex,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
                myLocationEnabled: true,
              ),
              Align(
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
        SizedBox(
          height: screenSize.height * 0.015,
        ),
        Text(
          "26, Jalan SS 2/103, SS 2, 47300 Petaling Jaya, Selangor",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
          ),
        ),
        Text("3.126971, 101.625321"),
        SizedBox(
          height: 10.0,
        )
      ],
    );
  }
}
