import 'package:flutter/material.dart';

import '../models/case_model.dart';
import '../services/event_services.dart';

class TalikhidmatProvider with ChangeNotifier {
  // address
  // location (lat long)
  // category
  // attachments (photo) => https
  // message (string)

  String _address = "";
  String get address => _address;

  double _latitude = 0;
  double get latitude => _latitude;

  double _longitude = 0;
  double get longitude => _longitude;

  // default => "-1" (not yet set anything)
  // then setCategory => <1,2,3,4,5>
  // case "1":
  //       return "COMPLAINT";
  // case "2":
  //       return "REQUEST FOR SERVICE";
  // case "3":
  //       return "COMPLIMENT";
  // case "4":
  //       return "ENQUIRY";
  // default:
  //       return "SUGGESTION";
  String _category = "-1";
  String get category => _category;

  String _message = "";
  String get message => _message;

  List<Map<String, dynamic>> _attachments = [];
  List<Map<String, dynamic>> get attachments => _attachments;

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

  void setCategoryAndMessage({
    required String category,
    required String message,
  }) {
    _category = category;
    _message = message;
    notifyListeners();
  }

  void setAttachement({required Map<String, dynamic> attachment}) {
    _attachments.add(attachment);
    notifyListeners();
  }

  void removeAttachement({required String attachment}) {
    _attachments.removeWhere((element) => element["filePath"] == attachment);
    notifyListeners();
  }

  void resetProvider() {
    _address = "";
    _latitude = 0;
    _longitude = 0;
    _category = "-1";
    _message = "";
    _attachments = [];
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
