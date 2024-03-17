import 'package:flutter/material.dart';

import '../models/case_model.dart';
import '../services/event_services.dart';

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
  // then setCategory => <0,1,2,3,4,5,6 - others, 7 - voice recording>
  int _category = -1;
  int get category => _category;

  bool _yourself = true;
  bool get yourself => _yourself;

  String _audioPath = "";
  String get audioPath => _audioPath;

  String? _otherText;
  String? get otherText => _otherText;

  // Report Cases - Talikhidmat

  List<AttachmentModel> _reportedCaseAttachmentList = [];
  List<AttachmentModel> get reportCaseAttachmentList =>
      _reportedCaseAttachmentList;

  late String _reportedCaseDetailStatus;
  String get reportedCaseDetailStatus => _reportedCaseDetailStatus;

  String? _reportedCaseId;

  CaseDetailModel? _reportedCaseDetail;
  CaseDetailModel? get reportedCaseDetail => _reportedCaseDetail;

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

  /// Get the detail of reported case when accessing each card in Reported Cases
  /// Using getEventById API for detail
  /// Using attachmentGetById API for attachments
  ///
  /// Receives [caseId] as the reported case ID
  Future<void> setCaseDetail(
    String caseId,
    String caseDetailStatus,
  ) async {
    _reportedCaseAttachmentList = [];
    try {
      _reportedCaseDetailStatus = caseDetailStatus;
      _reportedCaseId = caseId;
      var res = await EventServices().getEventById(caseId);
      if (res['data'] != null) {
        var caseDetailData = res['data'];
        _reportedCaseDetail = CaseDetailModel.fromJson(caseDetailData);

        // get the attachments
        var response = await EventServices().attachmentGetById(caseId);
        if (response['data'] != null) {
          List data = response['data'];
          _reportedCaseAttachmentList = [];
          data.forEach((element) {
            AttachmentModel attachment = AttachmentModel.fromJson(element);
            _reportedCaseAttachmentList.add(attachment);
          });
        }
      }
    } catch (e) {
      print('setCaseDetail error');
      throw e;
    }
  }
}
