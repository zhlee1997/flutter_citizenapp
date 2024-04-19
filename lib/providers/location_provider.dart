import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationProvider with ChangeNotifier {
  Position? _currentLocation;
  Position? get currentLocation => _currentLocation;

  double _latitude = 0;
  double get latitude => _latitude;

  double _longitude = 0;
  double get longitude => _longitude;

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      print("request users of the App to enable the location services");
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        print("next time you could try requesting permissions again");
        print(
            "this is also where Android's shouldShowRequestPermissionRationale returned true");
        print(
            "According to Android guidelines your App should show an explanatory UI now");
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      print("Permission to access the device's location is permanently denied");
      print(
          "When requesting permissions the permission dialog will not be shown until the user updates the permission in the App settings");
      print(
          "Ask user to change permission in Settings, navigate to Device Settings");
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  /// Get the current location of user when app is opened
  /// When accessing Google Map
  /// When submitting cases
  Future<Position?> getCurrentLocation() async {
    Position position = await _determinePosition();

    if (position.latitude.isFinite && position.longitude.isFinite) {
      _currentLocation = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (_currentLocation != null) {
        _latitude = _currentLocation!.latitude;
        _longitude = _currentLocation!.longitude;
        notifyListeners();
        return _currentLocation;
      }
    } else {
      _currentLocation = null;
    }
    notifyListeners();
    return null;
  }
}
