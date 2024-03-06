import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_citizenapp/arguments/subscription_video_screen_arguments.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../providers/cctv_provider.dart';
import '../../models/cctv_model.dart';
import '../../utils/app_localization.dart';
import '../../utils/global_dialog_helper.dart';
import '../../screens/subscription/subscription_video_screen.dart';

class MapBottomSheetWidget extends StatefulWidget {
  const MapBottomSheetWidget({super.key});

  @override
  State<MapBottomSheetWidget> createState() => _MapBottomSheetWidgetState();
}

class _MapBottomSheetWidgetState extends State<MapBottomSheetWidget> {
  Uint8List? imageByteData;

  late CCTVProvider cctvProvider;
  late Timer timer;

  Future<Uint8List?> _loadNetworkImage(String path) async {
    final completer = Completer<ImageInfo>();
    var img = NetworkImage(path);
    img.resolve(const ImageConfiguration()).addListener(
        ImageStreamListener((info, _) => completer.complete(info)));

    final imageInfo = await completer.future;
    final byteData =
        await imageInfo.image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  Future<void> _loadWatermark() async {
    timer = Timer(const Duration(seconds: 7), () {
      Fluttertoast.showToast(
        msg: "Still loading... Please wait",
        toastLength: Toast.LENGTH_LONG,
        timeInSecForIosWeb: 5,
      );
    });
    try {
      // imageByteData = await _loadNetworkImage(cctvProvider.imageUrl)
      //     .timeout(const Duration(seconds: 12));
      imageByteData = await _loadNetworkImage(
              "https://images.lifestyleasia.com/wp-content/uploads/sites/5/2022/07/15175110/Hero_Sarawak_River-1600x900.jpg")
          .timeout(const Duration(seconds: 12));
    } on TimeoutException catch (e) {
      print('Image Timeout');
      print(e.toString());
    } catch (e) {
      print(e.toString());
    }
    if (imageByteData != null) {
      timer.cancel();
      Fluttertoast.cancel();
    } else {
      // no image byte data
    }
  }

  // TODO: use geolocator service to calculate the distance
  Future<void> getDistanceFromCoordinates() async {}

  @override
  void didChangeDependencies() async {
    cctvProvider = Provider.of<CCTVProvider>(context, listen: false);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    // final CCTVModelDetail? cctvDetail =
    //     Provider.of<CCTVProvider>(context, listen: false).cctvModelDetail;

    final CCTVModelDetail? cctvDetail = CCTVModelDetail(
      id: "1",
      name: "SIOC CCTV 1",
      location: "Bangunan Baitulmakmur 1",
      image:
          "https://images.lifestyleasia.com/wp-content/uploads/sites/5/2022/07/15175110/Hero_Sarawak_River-1600x900.jpg",
      updateTime: "updateTime1",
      liveUrl:
          "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
    );

    // if (cctvProvider.imageUrl.isEmpty) {
    //   print("imageURL is empty");
    //   return Container(
    //     child: Center(
    //       child: Column(
    //         mainAxisAlignment: MainAxisAlignment.center,
    //         children: [
    //           SizedBox(
    //             height: 150,
    //             child: SvgPicture.asset('assets/images/undraw_online.svg'),
    //           ),
    //           SizedBox(
    //             height: 20,
    //           ),
    //           Container(
    //             child: Text(AppLocalization.of(context)!
    //                 .translate('camera_is_not_available')!),
    //           )
    //         ],
    //       ),
    //     ),
    //   );
    // }

    return FutureBuilder(
      future: _loadWatermark(),
      builder: (_, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                width: double.infinity,
                height: screenSize.height * 0.25,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const CircularProgressIndicator(),
                    const SizedBox(
                      height: 20,
                    ),
                    RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: "Loading image...",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(
                  top: 20.0,
                  left: 20.0,
                  right: 20.0,
                  bottom: 10.0,
                ),
                // width: double.infinity,
                child: Text(
                  cctvDetail!.location,
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(
                  left: 20.0,
                  right: 20.0,
                  bottom: 20.0,
                ),
                // width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      cctvDetail.name,
                      softWrap: true,
                      style: const TextStyle(
                        fontSize: 15.0,
                      ),
                    ),
                    const SizedBox(
                      width: 5.0,
                    ),
                    const Text(
                      "\u00B7",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.0,
                      ),
                    ),
                    const SizedBox(
                      width: 5.0,
                    ),
                    const Text(
                      "5 KM",
                      style: TextStyle(
                        fontSize: 15.0,
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                width: screenSize.width * 0.9,
                // height: screenSize.height * 0.06,
                child: ElevatedButton(
                  onPressed: () async {
                    // Map<String, dynamic> data = {
                    //   "liveUrl": cctvDetail.liveUrl,
                    //   "name": cctvDetail.name,
                    //   "address": cctvDetail.location
                    // };
                    timer.cancel();
                    Fluttertoast.cancel();
                    Navigator.of(context).pop();
                    Navigator.pushNamed(
                      context,
                      SubscriptionVideoScreen.routeName,
                      arguments: SubscriptionVideoScreenArguments(
                        cctvDetail.liveUrl,
                        cctvDetail.name,
                        cctvDetail.location,
                      ),
                    );
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        Theme.of(context).colorScheme.secondary),
                  ),
                  child: Text(
                    AppLocalization.of(context)!.translate('play_now')!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
            ],
          );
        } else {
          // if (imageByteData == null) {
          //   return Column(
          //     children: <Widget>[
          //       Container(
          //         child: Center(
          //           child: Container(
          //             width: double.infinity,
          //             height: screenSize.height * 0.25,
          //             child: Center(
          //               child: Text(
          //                 AppLocalization.of(context)!
          //                     .translate('camera_is_not_available')!,
          //                 textAlign: TextAlign.center,
          //               ),
          //             ),
          //           ),
          //         ),
          //       ),
          //       Container(
          //         margin: const EdgeInsets.only(
          //           top: 20.0,
          //           left: 20.0,
          //           right: 20.0,
          //           bottom: 10.0,
          //         ),
          //         width: double.infinity,
          //         child: Text(
          //           '${cctvDetail!.location}',
          //           style: TextStyle(
          //             fontSize: Platform.isIOS ? 18.0 : 18.0,
          //             fontWeight: FontWeight.bold,
          //           ),
          //         ),
          //       ),
          //       Container(
          //         margin: const EdgeInsets.only(
          //           left: 20.0,
          //           right: 20.0,
          //           bottom: 20.0,
          //         ),
          //         width: double.infinity,
          //         child: Text(
          //           '${cctvDetail.name}',
          //           softWrap: true,
          //           style: TextStyle(
          //             fontSize: Platform.isIOS ? 18.0 : 15.0,
          //           ),
          //         ),
          //       ),
          //       Container(
          //         width: screenSize.width * 0.9,
          //         height: screenSize.height * 0.06,
          //         child: ElevatedButton(
          //           onPressed: null,
          //           child: Text(
          //             AppLocalization.of(context)!.translate('play_now')!,
          //             style: TextStyle(
          //               fontWeight: FontWeight.bold,
          //             ),
          //           ),
          //         ),
          //       )
          //     ],
          //   );
          // }
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              GestureDetector(
                onTap: () => GlobalDialogHelper()
                    .showMemoryPhotoGallery(context, imageByteData!),
                child: Image.memory(
                  imageByteData!,
                  width: double.infinity,
                  height: screenSize.height * 0.25,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => SizedBox(
                    width: double.infinity,
                    height: screenSize.height * 0.25,
                    child: Center(
                      child: Text(AppLocalization.of(context)!
                          .translate('camera_is_not_available')!),
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(
                  top: 20.0,
                  left: 20.0,
                  right: 20.0,
                  bottom: 10.0,
                ),
                // width: double.infinity,
                child: Text(
                  cctvDetail!.location,
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(
                  bottom: 20.0,
                ),
                // width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      cctvDetail.name,
                      softWrap: true,
                      style: const TextStyle(
                        fontSize: 15.0,
                      ),
                    ),
                    const SizedBox(
                      width: 5.0,
                    ),
                    const Text(
                      "\u00B7",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.0,
                      ),
                    ),
                    const SizedBox(
                      width: 5.0,
                    ),
                    const Text(
                      "5 KM",
                      style: TextStyle(
                        fontSize: 15.0,
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                width: screenSize.width * 0.9,
                // height: screenSize.height * 0.06,
                child: ElevatedButton(
                  onPressed: () async {
                    // Map<String, dynamic> data = {
                    //   "liveUrl": cctvDetail.liveUrl,
                    //   "name": cctvDetail.name,
                    //   "address": cctvDetail.location
                    // };
                    timer.cancel();
                    Fluttertoast.cancel();
                    Navigator.of(context).pop();
                    Navigator.pushNamed(
                      context,
                      SubscriptionVideoScreen.routeName,
                      arguments: SubscriptionVideoScreenArguments(
                        cctvDetail.liveUrl,
                        cctvDetail.name,
                        cctvDetail.location,
                      ),
                    );
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        Theme.of(context).colorScheme.secondary),
                  ),
                  child: Text(
                    AppLocalization.of(context)!.translate('play_now')!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20.0,
              )
            ],
          );
        }
      },
    );
  }
}
