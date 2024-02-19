import 'dart:ui';
import 'dart:typed_data';

import 'package:flutter/material.dart';

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
          title: Text('$title'),
          content: Text('$message'),
          actions: [
            TextButton(
              onPressed: yesButtonFunc as void Function()?,
              child: Text(
                'Yes',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 18,
                ),
              ),
              style: ButtonStyle(
                overlayColor: MaterialStateProperty.all<Color>(
                    Colors.red.withOpacity(0.1)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'No',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => WillPopScope(
        child: Dialog(
          child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        flex: 3,
                        child: Container(
                          child: Text(
                            '$message',
                            softWrap: true,
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        onWillPop: () async => false,
      ),
    );
  }
}
