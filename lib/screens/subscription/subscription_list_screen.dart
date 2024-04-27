import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../models/cctv_model.dart';
import '../../models/camera_subscription_model.dart';
import '../../utils/global_dialog_helper.dart';
import '../../services/cctv_services.dart';
import '../../widgets/subscription/list_bottom_sheet_widget.dart';
import '../../providers/camera_subscription_provider.dart';
import '../../providers/cctv_provider.dart';
import '../../utils/app_localization.dart';

class SubscriptionListScreen extends StatefulWidget {
  static const String routeName = "subscription-list-screen";

  const SubscriptionListScreen({super.key});

  @override
  State<SubscriptionListScreen> createState() => _SubscriptionListScreenState();
}

class _SubscriptionListScreenState extends State<SubscriptionListScreen> {
  List<CameraSubscriptionModel> _cameraListModelList = [];
  bool _isLoading = false;
  bool _noMoreLoad = true;
  bool _isError = false;

  final GlobalDialogHelper _globalDialogHelper = GlobalDialogHelper();

  String get returnCurrentTime =>
      DateFormat("yyyy/MM/dd hh:mm:ss a").format(DateTime.now());

  Future<void> onPressCCTVSnapshotImage({
    required String imageUrl,
    required String name,
    required String location,
    required String latitide,
    required String longitude,
    required CameraSubscriptionModel cameraSubscriptionModel,
  }) async {
    Future<void> handleFuture() async {
      try {
        await Provider.of<CCTVProvider>(context, listen: false)
            .getCctvDetailProvider(cameraSubscriptionModel);
      } catch (e) {
        setState(() {
          _isError = true;
        });
      }
    }

    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return FutureBuilder(
          future: handleFuture(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              if (_isError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 150,
                        child:
                            SvgPicture.asset('assets/images/undraw_online.svg'),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(AppLocalization.of(context)!
                          .translate('camera_is_not_available')!),
                    ],
                  ),
                );
              }
              return ListBottomSheetWidget(
                cctvName: name,
                cctvLocation: location,
                cctvLatitude: latitide,
                cctvLongitude: longitude,
                imageUrl: imageUrl,
              );
            }
          },
        );
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isLoading = true;
      });
      _cameraListModelList.addAll(
          Provider.of<CameraSubscriptionProvider>(context, listen: false)
              .cameraSubscription);
      _cameraListModelList.add(CameraSubscriptionModel(
        channel: "",
        deviceCode: "",
        deviceName: "",
        id: "",
        latitude: "",
        longitude: "",
        location: "",
        picUrl: "",
      ));
      print(_cameraListModelList);
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    // TODO: NO data condition => list empty
    return Scaffold(
      appBar: AppBar(
        title: const Text("List Display"),
      ),
      body: _isLoading
          ? _globalDialogHelper.showLoadingSpinner()
          : ListView.builder(
              padding: EdgeInsets.all(10.0),
              shrinkWrap: true,
              itemCount: _cameraListModelList.length,
              itemBuilder: ((context, index) {
                if (_cameraListModelList.length == index + 1) {
                  if (_noMoreLoad) {
                    return Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 20.0,
                        ),
                        child: Text(
                            // Extra last empty element in array, so need to minus 1
                            "Number of CCTVs: ${_cameraListModelList.length - 1}"),
                      ),
                    );
                  }
                } else {
                  // to detect the last empty element
                  if (_cameraListModelList[index].id.isNotEmpty) {
                    return Card(
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              _cameraListModelList[index].deviceName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => onPressCCTVSnapshotImage(
                              imageUrl: _cameraListModelList[index].picUrl,
                              name: _cameraListModelList[index].deviceName,
                              location: _cameraListModelList[index].location,
                              latitide: _cameraListModelList[index].latitude,
                              longitude: _cameraListModelList[index].longitude,
                              cameraSubscriptionModel:
                                  _cameraListModelList[index],
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              height: screenSize.height * 0.3,
                              child: Image.network(
                                _cameraListModelList[index].picUrl,
                                errorBuilder: (context, error, stackTrace) =>
                                    Image.asset(
                                  "assets/images/icon/sioc.png",
                                  fit: BoxFit.cover,
                                ),
                                width: double.infinity,
                                height: screenSize.height * 0.3,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(8.0),
                            alignment: Alignment.centerRight,
                            child: Text(
                              returnCurrentTime,
                              // _cameraListModelList[index].updateTime,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                }
                return null;
              }),
            ),
    );
  }
}
