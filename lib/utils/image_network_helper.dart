import "package:flutter/material.dart";
import 'package:cached_network_image/cached_network_image.dart';

import '../utils/app_localization.dart';

class ImageNetworkHelper {
  /// Displays normal image
  /// Using CachedNetworkImage API
  ///
  /// Receives [url] as the image URL
  /// [fit] as the type of image layout
  /// [height] as the desired image height
  /// [width] as the desired image width
  /// Returns CachedNetworkImage widget
  static Widget imageNetworkBuilder({
    String? url,
    BoxFit? fit,
    double? height,
    double? width,
    bool isCamera = false,
  }) {
    return url == null
        ? Image.asset(
            'assets/images/icon/sioc.png',
            height: height! * 0.5,
            width: width,
          )
        : CachedNetworkImage(
            imageUrl: url,
            height: height,
            width: width,
            fit: fit,
            progressIndicatorBuilder:
                (BuildContext context, String url, DownloadProgress progress) {
              return SizedBox(
                width: width,
                height: height,
                child: Center(
                  child: CircularProgressIndicator(
                    value: progress.totalSize != null
                        ? progress.downloaded / progress.totalSize!
                        : null,
                  ),
                ),
              );
            },
            errorWidget: (BuildContext context, String url, dynamic error) =>
                SizedBox(
              width: width,
              height: height,
              child: Center(
                child: isCamera
                    ? Text(AppLocalization.of(context)!
                        .translate('camera_is_not_available')!)
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error),
                          SizedBox(
                            width: 5.0,
                          ),
                          Text("Image unavailable")
                        ],
                      ),
              ),
            ),
          );
  }
}
