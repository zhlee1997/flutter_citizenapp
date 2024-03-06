import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../models/cctv_model.dart';
import '../../utils/global_dialog_helper.dart';
import '../../providers/cctv_provider.dart';
import '../../utils/app_localization.dart';
import '../../widgets/traffic/traffic_images_bottom_widget.dart';
import '../../services/cctv_services.dart';

class TrafficImagesListScreen extends StatefulWidget {
  static const String routeName = "traffic-images-list-screen";

  const TrafficImagesListScreen({super.key});

  @override
  State<TrafficImagesListScreen> createState() =>
      _TrafficImagesListScreenState();
}

class _TrafficImagesListScreenState extends State<TrafficImagesListScreen> {
  List<CCTVModel> _cctvModelList = [];
  bool _isLoading = false;
  bool _isError = false;

  final GlobalDialogHelper _globalDialogHelper = GlobalDialogHelper();

  // on tap Camera Marker to show Camera details
  Future<void> onPressCameraIcon(CCTVModel cctv) async {
    Future<void> handleFuture() async {
      // try {
      //   await Provider.of<CCTVProvider>(context, listen: false)
      //       .getCctvDetailProvider(cctv);
      // } catch (e) {
      //   setState(() {
      //     _isError = true;
      //   });
      // }

      // Map<String, dynamic> data = {
      //   "channel": "02",
      //   "thridDeviceId": cctv.cctvId,
      // };
      // print(cctv.cctvId);

      // try {
      //   await Provider.of<CCTVProvider>(context, listen: false)
      //       .getCameraShortCutUrlProvider(data);
      // } catch (e) {
      //   setState(() {
      //     _isError = true;
      //   });
      // }
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
                              'assets/images/undraw_online.svg'),
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
                return TrafficImagesBottomWidget();
              }
            });
      },
    );
  }

  // TODO: Get Snapshots API
  // TODO: infinite scrolling
  // TODO: show total number of CCTVs in the bottom of list
  Future<void> getSnapshotList(Map<String, dynamic> data) async {
    final CCTVServices cctvServices = CCTVServices();

    try {
      var response = await cctvServices.queryCCTVSnapshotList(data);
      if (response["status"] == "200") {
        setState(() {
          _cctvModelList = response["obj"];
        });
      }
    } catch (e) {
      print("getSnapshotList fail: ${e.toString()}");
    }
  }

  Future<void> _initCCTVList() async {
    setState(() {
      _isLoading = true;
    });
    setState(() {
      _cctvModelList = [
        CCTVModel(
          cctvId: "1",
          deviceName: "SIOC CCTV 1",
          location: "Bangunan Baitulmakmur 1",
          latitude: "1.553110",
          longitude: "110.345032",
          channel: "02",
        ),
        CCTVModel(
          cctvId: "2",
          deviceName: "SIOC CCTV 2",
          location: "Bangunan Baitulmakmur 2",
          latitude: "1.553110",
          longitude: "110.345032",
          channel: "02",
        ),
        CCTVModel(
          cctvId: "3",
          deviceName: "SIOC CCTV 3",
          location: "Bangunan Baitulmakmur 3",
          latitude: "1.553110",
          longitude: "110.345032",
          channel: "02",
        ),
        CCTVModel(
          cctvId: "4",
          deviceName: "SIOC CCTV 4",
          location: "Bangunan Baitulmakmur 4",
          latitude: "1.553110",
          longitude: "110.345032",
          channel: "02",
        ),
        CCTVModel(
          cctvId: "5",
          deviceName: "SIOC CCTV 5",
          location: "Bangunan Baitulmakmur 5",
          latitude: "1.553110",
          longitude: "110.345032",
          channel: "02",
        )
      ];
    });
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initCCTVList();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: infinite scrolling
    return Scaffold(
      appBar: AppBar(title: const Text("Traffic Images")),
      body: _isLoading
          ? _globalDialogHelper.showLoadingSpinner()
          : ListView.separated(
              padding: const EdgeInsets.all(8.0),
              separatorBuilder: (context, index) => const Divider(),
              shrinkWrap: true,
              itemCount: _cctvModelList.length,
              itemBuilder: ((context, index) {
                return ListTile(
                  title: Text(_cctvModelList[index].deviceName),
                  subtitle: Text(_cctvModelList[index].location),
                  leading: CircleAvatar(
                    child: Text("${index + 1}".toString()),
                  ),
                  trailing: Icon(
                    Icons.camera_alt_outlined,
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
