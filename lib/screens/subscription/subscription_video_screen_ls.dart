import 'dart:io';
import 'dart:convert'; // for the utf8.encode method

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:crypto/crypto.dart';

import '../../providers/cctv_provider.dart';
import '../../arguments/subscription_video_screen_arguments.dart';
import '../../models/cctv_model.dart';
import '../../utils/global_dialog_helper.dart';
import '../../services/cctv_services.dart';
import '../../providers/location_provider.dart';
import '../../config/app_config.dart';

class SubscriptionVideoScreenLS extends StatefulWidget {
  static const String routeName = "subscription-video-screen-ls";

  const SubscriptionVideoScreenLS({super.key});

  @override
  State<SubscriptionVideoScreenLS> createState() =>
      _SubscriptionVideoScreenLSState();
}

class _SubscriptionVideoScreenLSState extends State<SubscriptionVideoScreenLS>
    with SingleTickerProviderStateMixin {
  final GlobalKey _webviewKey = GlobalKey();
  var loadingPercentage = 0;
  late bool _isLoading;
  late bool _isNearbyLoading;
  late String newCCTVId;
  late String session;
  late String liveUrl;

  TabController? tabController;
  late SubscriptionVideoScreenArguments args;
  String latitude = "";
  String longitude = "";
  List<CCTVOtherModel> _CCTVOtherModelList = [];
  late double height;

  String _distanceInBetween = "";
  double _endLatitude = 0;
  double _endLongitude = 0;

  // Use geolocator service to calculate the distance
  String getDistanceFromCoordinates(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    double distanceBetween = Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
    distanceBetween = distanceBetween / 1000;
    return distanceBetween.toStringAsFixed(1);
  }

  String amendCCTVToken(String cctvId) {
    if (cctvId.isNotEmpty) {
      String updatedString = cctvId.replaceAll('#', '_');
      return "0ba9--$updatedString";
    } else {
      return "";
    }
  }

  // return Google Map URL
  String get getGoogleMapUrl {
    String lat = latitude;
    String long = longitude;
    return "https://www.google.com/maps/search/?api=1&query=$lat,$long";
  }

  // Open Google Maps
  Future<void> _launchGoogleMaps() async {
    if (latitude.isNotEmpty && longitude.isNotEmpty) {
      final Uri encodedURl = Uri.parse(getGoogleMapUrl);
      await launchUrl(
        encodedURl,
        mode: LaunchMode.externalApplication,
      );
    } else {
      Fluttertoast.showToast(msg: "Unable to open Google Maps");
    }
  }

  // Get other cameras  => API (need 5 cameras)
  Future<void> getOtherCamerasList(String deviceCode) async {
    try {
      Map<String, dynamic> data = {
        "channel": "02",
        "thridDeviceId": deviceCode,
      };
      _CCTVOtherModelList =
          await Provider.of<CCTVProvider>(context, listen: false)
              .queryNearbyDevicesListProvider(data);
      setState(() {
        _isNearbyLoading = false;
      });
    } catch (e) {
      print("getOtherCamerasList error: ${e.toString()}");
      setState(() {
        _isNearbyLoading = false;
      });
    }
  }

  //  Get CCTV Detail API
  Future<String?> getOtherLiveUrl(CCTVOtherModel cctvOtherModel) async {
    final CCTVServices cctvServices = CCTVServices();
    var bytes = utf8.encode(dotenv.env["password"]!); // data being hashed
    var digest = md5.convert(bytes);

    try {
      Map<String, dynamic> map = {
        "user": dotenv.env["username"],
        "password": digest.toString(),
      };

      var response = await cctvServices.getLinkingVisionLogin(map);
      if (response['bStatus'] == true) {
        String newSession = response["strSession"] ?? "";
        String newOtherCCTVId = amendCCTVToken(cctvOtherModel.cctvId);
        String newOtherLiveUrl = AppConfig().isProductionInternal
            ? "https://10.16.24.144:18445/rtc.html?token=$newOtherCCTVId&session=$newSession"
            : 'https://video.sioc.sma.gov.my:18445/rtc.html?token=$newOtherCCTVId&session=$newSession';
        return newOtherLiveUrl;
      } else {
        throw Exception("LS login api return false");
      }
    } catch (e) {
      print("getOtherLiveUrl fail: ${e.toString()}");
    }
    return null;
  }

  Future<void> onSelectOtherCamera(CCTVOtherModel cctvOtherModel) async {
    try {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      GlobalDialogHelper().buildCircularProgressWithTextCenter(
        context: context,
        message: "Loading camera...",
      );
      String? newOtherLiveUrl = await getOtherLiveUrl(cctvOtherModel);

      if (newOtherLiveUrl == null || newOtherLiveUrl.isEmpty) {
        Navigator.of(context).pop();
        Fluttertoast.showToast(
            msg: "Camera cannot be played. Please try again");
        return;
      }

      // To calculate distance in between for other cameras
      _distanceInBetween = getDistanceFromCoordinates(
        double.parse(cctvOtherModel.latitude),
        double.parse(cctvOtherModel.longitude),
        _endLatitude,
        _endLongitude,
      );

      Navigator.of(context).pop();
      Navigator.of(context).pushReplacementNamed(
        SubscriptionVideoScreenLS.routeName,
        arguments: SubscriptionVideoScreenArguments(
          cctvOtherModel.cctvId,
          newOtherLiveUrl,
          cctvOtherModel.deviceName,
          cctvOtherModel.location,
          _distanceInBetween,
          cctvOtherModel.latitude,
          cctvOtherModel.longitude,
        ),
      );
    } catch (e) {
      Navigator.of(context).pop();
      print("onSelectOtherCamera error: ${e.toString()}");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _isLoading = true;
    _isNearbyLoading = true;
    tabController = TabController(length: 2, vsync: this);
    height = 200;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      // Accessing the arguments passed to the modal route
      args = ModalRoute.of(context)!.settings.arguments
          as SubscriptionVideoScreenArguments;
      // rtc
      // https://10.16.24.144:18445/rtc.html?token=0ba9--03445253977265490101_2450e628c6654835a282faf5e4185d8b&session=1aa43ca0-8e85-4041-9368-77503d1e0dbb
      session = Provider.of<CCTVProvider>(context, listen: false).sessionLS;

      setState(() {
        _isLoading = false;
      });

      // get other cameras => API
      getOtherCamerasList(args.deviceCode);
      // CCTV latitude, longitude
      latitude = args.latitude;
      longitude = args.longitude;
    });
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    LocationProvider locationProvider = Provider.of<LocationProvider>(context);
    if (locationProvider.currentLocation != null) {
      _endLatitude = locationProvider.currentLocation!.latitude;
      _endLongitude = locationProvider.currentLocation!.longitude;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live CCTV'),
        bottom: loadingPercentage < 100
            ? PreferredSize(
                preferredSize:
                    const Size.fromHeight(1.0), // Adjust the height as needed
                child: LinearProgressIndicator(
                  value: loadingPercentage / 100.0,
                ),
              )
            : null,
      ),
      body: _isLoading
          ? Container()
          : Column(
              children: [
                SizedBox(
                  height: height,
                  child: InAppWebView(
                    key: _webviewKey,
                    initialUrlRequest: URLRequest(
                      url: WebUri(args.liveUrl),
                    ),
                    initialSettings: InAppWebViewSettings(
                      supportZoom: false,
                      javaScriptEnabled: true,
                      disableHorizontalScroll: true,
                      disableVerticalScroll: true,
                      mediaPlaybackRequiresUserGesture: false,
                      allowsInlineMediaPlayback: true,
                    ),
                    onReceivedServerTrustAuthRequest:
                        (InAppWebViewController controller,
                            URLAuthenticationChallenge challenge) async {
                      return ServerTrustAuthResponse(
                        action: ServerTrustAuthResponseAction.PROCEED,
                      );
                    },
                    onWebViewCreated:
                        (InAppWebViewController controller) async {
                      if (Platform.isIOS) {
                        await Future.delayed(
                          const Duration(milliseconds: 1500),
                        );
                        int? heightController =
                            await controller.getContentHeight() ??
                                (screenSize.height * 0.27).toInt();
                        setState(() {
                          height = heightController.toDouble();
                        });
                        print("heightIOS: $height");
                      } else {
                        await Future.delayed(
                          const Duration(milliseconds: 1500),
                        );
                        int? heightController =
                            await controller.getContentHeight() ??
                                (screenSize.height * 0.27).toInt();
                        setState(() {
                          height = heightController.toDouble() * 0.38;
                        });
                        print("height: $height");
                      }
                    },
                    onLoadStart: (InAppWebViewController controller, Uri? url) {
                      setState(() {
                        loadingPercentage = 0;
                      });
                    },
                    onProgressChanged: (_, int progress) {
                      setState(() {
                        loadingPercentage = progress;
                      });
                    },
                    onLoadStop:
                        (InAppWebViewController controller, Uri? url) async {
                      setState(() {
                        loadingPercentage = 100;
                      });
                    },
                    onReceivedError: (
                      InAppWebViewController controller,
                      WebResourceRequest webResourceRequest,
                      WebResourceError webResourceError,
                    ) {
                      setState(() {
                        loadingPercentage = 100;
                      });
                    },
                  ),
                ),
                TabBar(
                  tabs: const [
                    Tab(
                      icon: Icon(Icons.camera),
                      text: "Camera Details",
                    ),
                    Tab(
                      icon: Icon(Icons.linked_camera_outlined),
                      text: "Camera Nearby",
                    ),
                  ],
                  controller: tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                ),
                Expanded(
                  child: TabBarView(
                    controller: tabController,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 15.0,
                          horizontal: 15.0,
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Column(
                                children: <Widget>[
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      const Icon(Icons.location_pin),
                                      const SizedBox(
                                        width: 10.0,
                                      ),
                                      Flexible(
                                        child: Text(
                                          args.address,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Row(
                                    children: <Widget>[
                                      const Icon(Icons.camera_outdoor),
                                      const SizedBox(
                                        width: 10.0,
                                      ),
                                      Flexible(
                                        child: Text(
                                          args.name,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Row(
                                    children: <Widget>[
                                      const Icon(
                                          Icons.directions_walk_outlined),
                                      const SizedBox(
                                        width: 10.0,
                                      ),
                                      Text(
                                        "${args.distanceInBetween}KM from you",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Column(
                                children: [
                                  Container(
                                    width: screenSize.width * 0.9,
                                    margin: const EdgeInsets.only(
                                      bottom: 15.0,
                                    ),
                                    padding: const EdgeInsets.all(15.0),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondaryContainer,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10.0)),
                                    ),
                                    child: Column(
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            CircleAvatar(
                                              backgroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .background,
                                              radius: 16.0,
                                              child: Icon(
                                                Icons.tips_and_updates,
                                                size: 18.0,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10.0,
                                            ),
                                            const Text(
                                              "Note",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 5.0,
                                        ),
                                        const Text(
                                          "You can open the Google Maps to pinpoint the camera location.",
                                          style: TextStyle(
                                            fontSize: 12.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: screenSize.width * 0.9,
                                    margin: const EdgeInsets.only(
                                      bottom: 5.0,
                                    ),
                                    child: ElevatedButton.icon(
                                      onPressed: _launchGoogleMaps,
                                      icon: const Icon(Icons.map_outlined),
                                      label: const Text("Google Maps"),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      _isNearbyLoading
                          ? GlobalDialogHelper().showLoadingSpinner()
                          : _CCTVOtherModelList.isEmpty
                              ? Container(
                                  margin: EdgeInsets.only(
                                    top: screenSize.height * 0.05,
                                  ),
                                  child: Column(
                                    children: <Widget>[
                                      SvgPicture.asset(
                                        "assets/images/svg/no_data.svg",
                                        width: screenSize.width * 0.4,
                                        height: screenSize.width * 0.4,
                                        semanticsLabel: 'No Data Logo',
                                      ),
                                      const SizedBox(
                                        height: 10.0,
                                      ),
                                      const Text("No camera nearby"),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5.0,
                                    vertical: 5.0,
                                  ),
                                  shrinkWrap: true,
                                  itemCount: _CCTVOtherModelList.length,
                                  itemBuilder: ((context, index) {
                                    return ListTile(
                                      onTap: () => onSelectOtherCamera(
                                          _CCTVOtherModelList[index]),
                                      title: Text(
                                        _CCTVOtherModelList[index].location,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      subtitle: Text(
                                        _CCTVOtherModelList[index].deviceName,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                      trailing: SizedBox(
                                        width: screenSize.width * 0.275,
                                        height: screenSize.width * 0.2,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          child: Image.network(
                                            // _CCTVOtherModelList[index].picUrl,
                                            "https://video.sioc.sma.gov.my:18445/api/v1/GetImage?token=${amendCCTVToken(_CCTVOtherModelList[index].cctvId)}&session=$session",
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Image.asset(
                                              "assets/images/icon/sioc.png",
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                )
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
