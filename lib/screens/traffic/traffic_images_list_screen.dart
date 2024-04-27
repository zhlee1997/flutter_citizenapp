import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../models/cctv_model.dart';
import '../../utils/global_dialog_helper.dart';
import '../../providers/cctv_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../utils/app_localization.dart';
import '../../widgets/traffic/traffic_images_bottom_widget.dart';
import '../../services/camera_subscription_services.dart';
import '../../models/camera_subscription_model.dart';

class TrafficImagesListScreen extends StatefulWidget {
  static const String routeName = "traffic-images-list-screen";

  const TrafficImagesListScreen({super.key});

  @override
  State<TrafficImagesListScreen> createState() =>
      _TrafficImagesListScreenState();
}

class _TrafficImagesListScreenState extends State<TrafficImagesListScreen> {
  // List<CCTVModel> _cctvModelList = [];
  List<CameraSubscriptionModel> _cctvModelList = [];
  bool _isLoading = false;
  bool _isError = false;
  late CCTVModelDetail _cctvModelDetail;

  final GlobalDialogHelper _globalDialogHelper = GlobalDialogHelper();

  // Tap the Camera Marker to show camera details
  Future<void> onPressCameraIcon(CameraSubscriptionModel cctv) async {
    Future<void> handleFuture() async {
      _cctvModelDetail = CCTVModelDetail(
        id: cctv.deviceCode,
        name: cctv.deviceName,
        location: cctv.location,
        image: '',
        updateTime: '',
        liveUrl: '',
      );
      Map<String, dynamic> data = {
        "channel": "02",
        "thridDeviceId": cctv.deviceCode,
      };
      try {
        await Provider.of<CCTVProvider>(context, listen: false)
            .getCameraShortCutUrlProvider(data);
      } catch (e) {
        setState(() {
          _isError = true;
        });
      }
    }

    await showModalBottomSheet(
      showDragHandle: true,
      context: context,
      builder: (_) {
        return FutureBuilder(
            future: handleFuture(),
            builder: (_, AsyncSnapshot snapshot) {
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
                          child: SvgPicture.asset(
                              'assets/images/svg/undraw_online.svg'),
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
                return TrafficImagesBottomWidget(
                  cctvModelDetail: _cctvModelDetail,
                );
              }
            });
      },
    );
  }

  Future<void> _initCCTVList() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final subscribeId =
          Provider.of<SubscriptionProvider>(context, listen: false).subscribeId;
      var response = await CameraSubscriptionServices()
          .queryTrafficDevicesByPackageId(subscribeId);
      if (response["status"] == "200") {
        var list = response["data"] as List;
        _cctvModelList =
            list.map((e) => CameraSubscriptionModel.fromJson(e)).toList();
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print("_initCCTVList fail: ${e.toString()}");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initCCTVList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Traffic Images")),
      body: _isLoading
          ? _globalDialogHelper.showLoadingSpinner()
          : ListView.separated(
              padding: const EdgeInsets.all(8.0),
              separatorBuilder: (context, index) => const Divider(),
              itemCount: _cctvModelList.length,
              itemBuilder: ((context, index) {
                return ListTile(
                  title: Text(_cctvModelList[index].deviceName),
                  subtitle: Text(_cctvModelList[index].location),
                  leading: CircleAvatar(
                    child: Text("${index + 1}".toString()),
                  ),
                  trailing: Icon(
                    Icons.emoji_transportation_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onTap: () async {
                    await onPressCameraIcon(_cctvModelList[index]);
                  },
                );
              }),
            ),
    );
  }
}
