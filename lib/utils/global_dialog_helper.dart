import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../utils/app_localization.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:photo_view/photo_view.dart';

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
      child: SpinKitCubeGrid(
        color: Colors.purple.shade300,
        size: 50.0,
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
}
