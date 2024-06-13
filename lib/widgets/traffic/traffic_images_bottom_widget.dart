import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import '../../providers/cctv_provider.dart';
import '../../utils/app_localization.dart';
import '../../utils/global_dialog_helper.dart';
import '../../models/cctv_model.dart';

class TrafficImagesBottomWidget extends StatefulWidget {
  final CCTVModelDetail cctvModelDetail;

  const TrafficImagesBottomWidget({
    required this.cctvModelDetail,
    super.key,
  });

  @override
  State<TrafficImagesBottomWidget> createState() =>
      _TrafficImagesBottomWidgetState();
}

class _TrafficImagesBottomWidgetState extends State<TrafficImagesBottomWidget> {
  late CCTVProvider cctvProvider;
  late Timer timer;
  Uint8List? imageByteData;
  late Uint8List watermarkImage;

  String get returnCurrentTime =>
      DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());

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

  // TODO: use other method to add watermark
  // Future<Uint8List> _addWatermark(Uint8List? imageByteData) async {
  //   Uint8List watermarkedImg = await ImageWatermark.addTextWatermark(
  //     imgBytes: imageByteData!,
  //     watermarkText: 'Copyright SMA',
  //     dstX: 20,
  //     // position of watermark x coordinate
  //     dstY: 30,
  //     // y coordinate
  //     color: Colors.white,
  //   );
  //   print(watermarkedImg.length);
  //   return watermarkedImg;
  // }

  Future<void> _loadWatermark(BuildContext context) async {
    timer = Timer(Duration(seconds: 7), () {
      Fluttertoast.showToast(
        msg: "Still loading... Please wait",
        toastLength: Toast.LENGTH_LONG,
        timeInSecForIosWeb: 5,
      );
    });
    try {
      imageByteData = await _loadNetworkImage(cctvProvider.imageUrl)
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
      try {
        // TODO: add watermark for SMA Copyright
        // watermarkImage = await _addWatermark(imageByteData);
        watermarkImage = imageByteData!;
      } catch (e) {
        print(e.toString());
      }
    } else {
      // no image byte data
    }
  }

  @override
  void didChangeDependencies() async {
    cctvProvider = Provider.of<CCTVProvider>(context, listen: false);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    // if imageUrl is empty, show default SIOC Logo
    if (cctvProvider.imageUrl.isEmpty) {
      return Column(
        children: [
          Image.asset(
            "assets/images/icon/sioc.png",
            width: double.infinity,
            height: screenSize.height * 0.3,
            fit: BoxFit.fill,
          ),
          Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 10.0,
            ),
            width: double.infinity,
            child: Text(
              widget.cctvModelDetail.location,
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 20.0,
            ),
            width: double.infinity,
            child: Row(
              children: <Widget>[
                const Icon(Icons.timelapse_rounded),
                const SizedBox(
                  width: 10,
                ),
                const Text(
                  'Last Check At: ',
                ),
                Text(returnCurrentTime)
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        FutureBuilder(
            future: _loadWatermark(context),
            builder: (_, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox(
                  width: double.infinity,
                  height: screenSize.height * 0.3,
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
                );
              } else {
                if (imageByteData == null) {
                  return Center(
                    child: SizedBox(
                      width: double.infinity,
                      height: screenSize.height * 0.3,
                      child: Center(
                        child: Text(
                          "Camera image not available",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                }
                return GestureDetector(
                  onTap: () => GlobalDialogHelper()
                      .showMemoryPhotoGallery(context, watermarkImage),
                  child: Image.memory(
                    watermarkImage,
                    width: double.infinity,
                    height: screenSize.height * 0.3,
                    fit: BoxFit.fill,
                    errorBuilder: (context, error, stackTrace) => SizedBox(
                      width: double.infinity,
                      height: screenSize.height * 0.3,
                      child: Center(
                        child: Text("Camera image not available"),
                      ),
                    ),
                  ),
                );
              }
            }),
        Container(
          margin: const EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: 10.0,
          ),
          width: double.infinity,
          child: Text(
            widget.cctvModelDetail.location,
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(
            horizontal: 20.0,
          ),
          width: double.infinity,
          child: Row(
            children: <Widget>[
              const Icon(Icons.timelapse_rounded),
              const SizedBox(
                width: 10,
              ),
              const Text(
                'Last Check At: ',
              ),
              Text(returnCurrentTime)
            ],
          ),
        ),
      ],
    );
  }
}
