import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../utils/app_localization.dart';

class GlobalDialogHelper {
  /// Displays alert dialog
  ///
  /// Receives [title] as the dialog title
  /// [message] as the dialog message
  /// [yesButtonFunc] as the function of the 'YES' button when pressed
  Future<void> showAlertDialog({
    required BuildContext context,
    required Function yesButtonFunc,
    required String title,
    required String message,
  }) async {
    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
                onPressed: yesButtonFunc as void Function()?,
                style: ButtonStyle(
                  overlayColor: MaterialStateProperty.all<Color>(
                      Colors.red.withOpacity(0.1)),
                ),
                child: const Text(
                  'YES',
                  style: TextStyle(
                    color: Colors.red,
                  ),
                )),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('NO'),
            ),
          ],
        );
      },
    );
  }

  /// Displays alert dialog with single button
  ///
  /// Receives [title] as the dialog title
  /// [message] as the dialog message
  Future<void> showAlertDialogWithSingleButton({
    required BuildContext context,
    required String title,
    required String message,
  }) async {
    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(
              fontSize: 17,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /// Displays circular progress dialog with text
  ///
  /// Receives [message] as the dialog message
  Future<void> buildCircularProgressWithTextCenter({
    required BuildContext context,
    required String message,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => WillPopScope(
        child: Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Expanded(
                      flex: 1,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        message,
                        softWrap: true,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
        onWillPop: () async => false,
      ),
    );
  }

  /// Displays loading spinner dialog
  Widget showLoadingSpinner() {
    return Center(
      child: SpinKitWaveSpinner(
        color: Colors.purple.shade700,
        waveColor: Colors.purple.shade700,
        size: 100.0,
      ),
    );
  }

  /// Displays single memory image dialog
  ///
  /// Receives [imageByte] as the image byte data
  Future<void> showMemoryPhotoGallery(
    BuildContext ctx,
    Uint8List imageByte,
  ) async {
    await showGeneralDialog(
      context: ctx,
      pageBuilder: (_, animation, secondaryAnimation) {
        return SafeArea(
          child: Builder(
            builder: (context) {
              return Material(
                color: Colors.black54,
                child: Stack(
                  children: <Widget>[
                    PhotoView(
                      imageProvider: MemoryImage(imageByte),
                      loadingBuilder: (context, progress) => const Center(
                        child: SizedBox(
                          width: 30.0,
                          height: 30.0,
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      initialScale: PhotoViewComputedScale.contained,
                      minScale: PhotoViewComputedScale.contained,
                      maxScale: PhotoViewComputedScale.covered * 1.8,
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: IconButton(
                        iconSize: 35.0,
                        splashRadius: 20.0,
                        splashColor: Colors.white,
                        icon: const Icon(
                          Icons.cancel,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        );
      },
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(ctx).modalBarrierDismissLabel,
      transitionDuration: const Duration(
        milliseconds: 300,
      ),
    );
  }

  /// Displays circular progress in transparent dialog
  Future<void> buildCircularProgressCenter({
    required BuildContext context,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Dialog(
        backgroundColor: Colors.transparent,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  /// Displays svg image when there is no data
  ///
  /// Receives [message] as the dialog message
  Widget buildCenterNoData(BuildContext context, {String? message}) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 250,
            width: 250,
            child: SvgPicture.asset("assets/images/svg/no_data.svg"),
          ),
          SizedBox(
            height: screenHeight * 0.03,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              message == null
                  ? AppLocalization.of(context)!.translate('no_data')!
                  : message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Displays circular progress indicator and end of page with condition
  Widget buildLinearProgressIndicator({
    required BuildContext context,
    required int currentLength,
    required bool noMoreData,
    required Function() handleLoadMore,
  }) {
    if (currentLength < 9 && !noMoreData) {
      return TextButton(
        onPressed: handleLoadMore,
        child: Text(AppLocalization.of(context)!.translate('load_m')!),
      );
    }
    if (noMoreData) {
      return Center(
        child: Text(AppLocalization.of(context)!.translate('end_of')!),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(20.0),
        child: LinearProgressIndicator(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          valueColor:
              AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
        ),
      );
    }
  }

  /// Displays single image dialog
  ///
  /// Receives [imageUrl] as the image URL
  Future<void> showPhotoGallery(BuildContext ctx, String imageUrl) async {
    await showGeneralDialog(
      context: ctx,
      pageBuilder: (_, animation, secondaryAnimation) {
        return SafeArea(
          child: Builder(
            builder: (context) {
              return Material(
                color: Colors.black54,
                child: Stack(
                  children: <Widget>[
                    PhotoView(
                      imageProvider: NetworkImage(imageUrl),
                      loadingBuilder: (context, progress) => const Center(
                        child: SizedBox(
                          width: 30.0,
                          height: 30.0,
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      initialScale: PhotoViewComputedScale.contained,
                      minScale: PhotoViewComputedScale.contained,
                      maxScale: PhotoViewComputedScale.covered * 1.8,
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: IconButton(
                        iconSize: 35.0,
                        splashRadius: 20.0,
                        splashColor: Colors.white,
                        icon: const Icon(
                          Icons.cancel,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        );
      },
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(ctx).modalBarrierDismissLabel,
      transitionDuration: const Duration(
        milliseconds: 300,
      ),
    );
  }

  /// Displays svg image when API Error
  ///
  /// Receives [message] as the dialog message
  Widget buildCenterAPIError(
    BuildContext context, {
    String? message,
  }) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 250,
            width: 250,
            child: SvgPicture.asset("assets/images/undraw_denied.svg"),
          ),
          SizedBox(
            height: screenHeight * 0.03,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              message == null ? 'Error happens' : message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
