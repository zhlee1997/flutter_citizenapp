import 'package:flutter/material.dart';

class EmergencyProvider with ChangeNotifier {
  // address
  // location (lat long)
  // category
  // attachment
  // yourself

  String _address = "";
  String get address => _address;

  double _latitude = 0;
  double get latitude => _latitude;

  double _longitude = 0;
  double get longitude => _longitude;

  // default => -1 (not yet set anything)
  // then setCategory => <0,1,2,3,4,5,6 - others,7 - voice recording>
  int _category = -1;
  int get category => _category;

  bool _yourself = true;
  bool get yourself => _yourself;

  String _audioPath = "";
  String get audioPath => _audioPath;

  String? _otherText;
  String? get otherText => _otherText;

  void setAddressAndLocation({
    required String address,
    required double latitide,
    required double longitude,
  }) {
    _address = address;
    _latitude = latitide;
    _longitude = longitude;
    notifyListeners();
  }

  void setCategoryAndYourself({
    required int category,
    required bool yourself,
  }) {
    _category = category;
    _yourself = yourself;
    notifyListeners();
  }

  void setOtherText(String? otherText) {
    _otherText = otherText;
  }

  void setAudioPath(String audioPath) {
    _audioPath = audioPath;
  }

  void resetProvider() {
    _address = "";
    _latitude = 0;
    _longitude = 0;
    _category = -1;
    _yourself = true;
    _audioPath = "";
    _otherText = null;
    notifyListeners();
  }
}
