import 'package:flutter/material.dart';

import '../../models/cctv_model.dart';
import '../../utils/global_dialog_helper.dart';
import './subscription_video_screen.dart';
import '../../arguments/subscription_video_screen_arguments.dart';
import '../../services/cctv_services.dart';
import '../../widgets/subscription/map_bottom_sheet_widget.dart';

class SubscriptionListScreen extends StatefulWidget {
  static const String routeName = "subscription-list-screen";

  const SubscriptionListScreen({super.key});

  @override
  State<SubscriptionListScreen> createState() => _SubscriptionListScreenState();
}

class _SubscriptionListScreenState extends State<SubscriptionListScreen> {
  List<CCTVModelDetail> _cctvModelDetailList = [];
  bool _isLoading = false;
  bool _noMoreLoad = true;

  final GlobalDialogHelper _globalDialogHelper = GlobalDialogHelper();

  void _handleNavigateToSubscriptionVideoScreen({
    required String imageUrl,
    required String liveUrl,
    required String name,
    required String location,
  }) {
    // onPressCCCTVSnapshotImage(imageUrl, liveUrl, name, location);

    Navigator.of(context).pushNamed(
      SubscriptionVideoScreen.routeName,
      arguments: SubscriptionVideoScreenArguments(
        liveUrl,
        name,
        location,
        // TODO: to calculate the distance between for camera
        "15",
      ),
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
          _cctvModelDetailList = response["obj"];
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
      _cctvModelDetailList = [
        CCTVModelDetail(
          id: "1",
          name: "SIOC CCTV 1",
          location: "Bangunan Baitulmakmur 1",
          image:
              "https://images.lifestyleasia.com/wp-content/uploads/sites/5/2022/07/15175110/Hero_Sarawak_River-1600x900.jpg",
          updateTime: "updateTime 1",
          liveUrl:
              "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
        ),
        CCTVModelDetail(
          id: "2",
          name: "SIOC CCTV 2",
          location: "Bangunan Baitulmakmur 2",
          image:
              "https://static.vecteezy.com/system/resources/previews/032/079/941/large_2x/aerial-view-of-bandaraya-kuching-mosque-in-kuching-sarawak-east-malaysia-photo.jpg",
          updateTime: "updateTime 2",
          liveUrl:
              "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
        ),
        CCTVModelDetail(
          id: "3",
          name: "SIOC CCTV 3",
          location: "Bangunan Baitulmakmur 3",
          image:
              "https://www.globeguide.ca/wp-content/uploads/2020/02/Malaysia-Sarawak-Kuching-city-view.jpg",
          updateTime: "updateTime 3",
          liveUrl:
              "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
        ),
        CCTVModelDetail(
          id: "4",
          name: "SIOC CCTV 4",
          location: "Bangunan Baitulmakmur 4",
          image:
              "https://cdn.audleytravel.com/3602/2573/79/15979011-kuching-borneo.jpg",
          updateTime: "updateTime 4",
          liveUrl:
              "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
        ),
        CCTVModelDetail(
          id: "5",
          name: "SIOC CCTV 5",
          location: "Bangunan Baitulmakmur 5",
          image:
              "https://media.tacdn.com/media/attractions-splice-spp-674x446/07/18/2a/dc.jpg",
          updateTime: "updateTime 5",
          liveUrl:
              "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4",
        ),
        CCTVModelDetail(
          id: "",
          name: "",
          location: "",
          image: "",
          updateTime: "",
          liveUrl: "",
        )
      ];
    });
    setState(() {
      _isLoading = false;
    });
  }

  // Future<void> onPressCCCTVSnapshotImage(
  //     imageUrl, liveUrl, name, location) async {
  //   Future<void> handleFuture() async {
  //     try {
  //       await Provider.of<CCTVProvider>(context, listen: false)
  //           .getCctvDetailProvider(cctv);
  //     } catch (e) {
  //       setState(() {
  //         _isError = true;
  //       });
  //     }

  //     Map<String, dynamic> data = {
  //       "channel": "02",
  //       "thridDeviceId": cctv.cctvId,
  //     };
  //     try {
  //       await Provider.of<CCTVProvider>(context, listen: false)
  //           .getCameraShortCutUrlProvider(data);
  //     } catch (e) {
  //       setState(() {
  //         _isError = true;
  //       });
  //     }
  //   }

  //   await showModalBottomSheet(
  //     context: context,
  //     showDragHandle: true,
  //     builder: (_) {
  //       return FutureBuilder(
  //           future: handleFuture(),
  //           builder: (_, AsyncSnapshot snapshot) {
  //             if (snapshot.connectionState == ConnectionState.waiting) {
  //               return const Center(
  //                 child: CircularProgressIndicator(),
  //               );
  //             } else {
  //               if (_isError) {
  //                 return Center(
  //                   child: Column(
  //                     mainAxisAlignment: MainAxisAlignment.center,
  //                     children: [
  //                       SizedBox(
  //                         height: 150,
  //                         child: SvgPicture.asset(
  //                             'assets/images/undraw_online.svg'),
  //                       ),
  //                       const SizedBox(
  //                         height: 20,
  //                       ),
  //                       Text(AppLocalization.of(context)!
  //                           .translate('camera_is_not_available')!),
  //                     ],
  //                   ),
  //                 );
  //               }
  //               return MapBottomSheetWidget(
  //                 cctvLatitude: cctv.latitude,
  //                 cctvLongitude: cctv.longitude,
  //               );
  //             }
  //           });
  //     },
  //   );
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initCCTVList();
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
              shrinkWrap: true,
              itemCount: _cctvModelDetailList.length,
              itemBuilder: ((context, index) {
                if (_cctvModelDetailList.length == index + 1) {
                  if (_noMoreLoad) {
                    return Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 20.0,
                        ),
                        child: Text(
                            // Extra last empty element in array, so need to minus 1
                            "Number of CCTVs: ${_cctvModelDetailList.length - 1}"),
                      ),
                    );
                  }
                } else {
                  // to detect the last empty element
                  if (_cctvModelDetailList[index].id.isNotEmpty) {
                    return Column(
                      children: [
                        Container(
                          width: double.infinity,
                          height: screenSize.height * 0.035,
                          color: Colors.blueGrey.shade800,
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.arrow_drop_down,
                                color: Colors.white,
                              ),
                              const SizedBox(
                                width: 5.0,
                              ),
                              Text(
                                _cctvModelDetailList[index].name,
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _handleNavigateToSubscriptionVideoScreen(
                            imageUrl: _cctvModelDetailList[index].image,
                            liveUrl: _cctvModelDetailList[index].liveUrl,
                            name: _cctvModelDetailList[index].name,
                            location: _cctvModelDetailList[index].location,
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            height: screenSize.height * 0.3,
                            child: Stack(
                              children: <Widget>[
                                Image.network(
                                  _cctvModelDetailList[index].image,
                                  width: double.infinity,
                                  height: screenSize.height * 0.3,
                                  fit: BoxFit.cover,
                                ),
                                // TODO: Current API lack of screenshot time
                                Container(
                                  width: screenSize.width * 0.5,
                                  color: Colors.black,
                                  child: Text(
                                    "02/03/2024 12:17:12 AM",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                }

                return null;
              }),
            ),
    );
  }
}
