import 'package:flutter/material.dart';

import '../../models/cctv_model.dart';
import '../../utils/global_dialog_helper.dart';
import '../../services/cctv_services.dart';
import '../../widgets/subscription/list_bottom_sheet_widget.dart';

class SubscriptionListScreen extends StatefulWidget {
  static const String routeName = "subscription-list-screen";

  const SubscriptionListScreen({super.key});

  @override
  State<SubscriptionListScreen> createState() => _SubscriptionListScreenState();
}

class _SubscriptionListScreenState extends State<SubscriptionListScreen> {
  List<CCTVListModel> _cctvListModelList = [];
  bool _isLoading = false;
  bool _noMoreLoad = true;

  final GlobalDialogHelper _globalDialogHelper = GlobalDialogHelper();

  // TODO: Get Snapshots API
  // TODO: infinite scrolling
  // TODO: show total number of CCTVs in the bottom of list
  Future<void> getSnapshotList(Map<String, dynamic> data) async {
    final CCTVServices cctvServices = CCTVServices();

    try {
      var response = await cctvServices.queryCCTVSnapshotList(data);
      if (response["status"] == "200") {
        setState(() {
          _cctvListModelList = response["obj"];
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
      _cctvListModelList = [
        CCTVListModel(
          cctvId: "1",
          name: "SIOC CCTV 1",
          location: "Bangunan Baitulmakmur 1",
          latitude: "1.552111111",
          longitude: "110.3352278",
          image:
              "https://images.lifestyleasia.com/wp-content/uploads/sites/5/2022/07/15175110/Hero_Sarawak_River-1600x900.jpg",
          updateTime: "02/03/2024 12:17:12 AM",
          liveUrl:
              "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
        ),
        CCTVListModel(
          cctvId: "2",
          name: "SIOC CCTV 2",
          location: "Bangunan Baitulmakmur 2",
          latitude: "1.559844444",
          longitude: "110.3456778",
          image:
              "https://static.vecteezy.com/system/resources/previews/032/079/941/large_2x/aerial-view-of-bandaraya-kuching-mosque-in-kuching-sarawak-east-malaysia-photo.jpg",
          updateTime: "02/03/2024 12:17:12 AM",
          liveUrl:
              "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
        ),
        CCTVListModel(
          cctvId: "3",
          name: "SIOC CCTV 3",
          location: "Bangunan Baitulmakmur 3",
          latitude: "1.552111111",
          longitude: "110.3352278",
          image:
              "https://www.globeguide.ca/wp-content/uploads/2020/02/Malaysia-Sarawak-Kuching-city-view.jpg",
          updateTime: "02/03/2024 12:17:12 AM",
          liveUrl:
              "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
        ),
        CCTVListModel(
          cctvId: "4",
          name: "SIOC CCTV 4",
          location: "Bangunan Baitulmakmur 4",
          latitude: "1.559844444",
          longitude: "110.3456778",
          image:
              "https://cdn.audleytravel.com/3602/2573/79/15979011-kuching-borneo.jpg",
          updateTime: "02/03/2024 12:17:12 AM",
          liveUrl:
              "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
        ),
        CCTVListModel(
          cctvId: "5",
          name: "SIOC CCTV 5",
          location: "Bangunan Baitulmakmur 5",
          latitude: "1.552111111",
          longitude: "110.3352278",
          image:
              "https://media.tacdn.com/media/attractions-splice-spp-674x446/07/18/2a/dc.jpg",
          updateTime: "02/03/2024 12:17:12 AM",
          liveUrl:
              "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4",
        ),
        CCTVListModel(
          cctvId: "",
          name: "",
          location: "",
          latitude: "",
          longitude: "",
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

  Future<void> onPressCCCTVSnapshotImage({
    required String imageUrl,
    required String liveUrl,
    required String name,
    required String location,
    required String latitide,
    required String longitude,
  }) async {
    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return ListBottomSheetWidget(
          cctvName: name,
          cctvLocation: location,
          cctvLatitude: latitide,
          cctvLongitude: longitude,
          imageUrl: imageUrl,
          liveUrl: liveUrl,
        );
      },
    );
  }

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
              padding: EdgeInsets.all(10.0),
              shrinkWrap: true,
              itemCount: _cctvListModelList.length,
              itemBuilder: ((context, index) {
                if (_cctvListModelList.length == index + 1) {
                  if (_noMoreLoad) {
                    return Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 20.0,
                        ),
                        child: Text(
                            // Extra last empty element in array, so need to minus 1
                            "Number of CCTVs: ${_cctvListModelList.length - 1}"),
                      ),
                    );
                  }
                } else {
                  // to detect the last empty element
                  if (_cctvListModelList[index].cctvId.isNotEmpty) {
                    return Card(
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              _cctvListModelList[index].name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => onPressCCCTVSnapshotImage(
                              imageUrl: _cctvListModelList[index].image,
                              liveUrl: _cctvListModelList[index].liveUrl,
                              name: _cctvListModelList[index].name,
                              location: _cctvListModelList[index].location,
                              latitide: _cctvListModelList[index].latitude,
                              longitude: _cctvListModelList[index].longitude,
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              height: screenSize.height * 0.3,
                              child: Image.network(
                                _cctvListModelList[index].image,
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
                              _cctvListModelList[index].updateTime,
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
