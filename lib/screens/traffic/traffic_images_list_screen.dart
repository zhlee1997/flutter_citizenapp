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

  // Tap the Camera Marker to show camera details
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
                return TrafficImagesBottomWidget();
              }
            });
      },
    );
  }

  Future<void> _initCCTVList() async {
    setState(() {
      _isLoading = true;
    });
    bool success = await Provider.of<CCTVProvider>(context, listen: false)
        .getCctvCoordinatesProvider();
    if (success) {
      _cctvModelList =
          Provider.of<CCTVProvider>(context, listen: false).cctvModel;
    }
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
