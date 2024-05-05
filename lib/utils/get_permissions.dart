import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:device_info_plus/device_info_plus.dart';

class GetPermissions {
  ///
  ///
  /// Checking Camera Permission
  static Future<bool> getCameraPermission(BuildContext context) async {
    PermissionStatus permissionStatus = await Permission.camera.status;

    if (permissionStatus.isGranted) {
      return true;
    } else if (permissionStatus.isDenied) {
      PermissionStatus status = await Permission.camera.request();
      if (status.isGranted) {
        return true;
      } else {
        Fluttertoast.showToast(msg: 'Camera permission is required');
        return false;
      }
    } else if (permissionStatus.isPermanentlyDenied) {
      await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Permission Denied'),
              content: const Text(
                  "You have to manually enable the camera permission's status in the system settings."),
              actions: <Widget>[
                TextButton(
                  child: const Text('Open Settings'),
                  onPressed: () {
                    Navigator.pop(context, false);
                    openAppSettings();
                  },
                ),
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                ),
              ],
            );
          });
      return false;
    }
    return false;
  }

  ///
  ///
  /// Checking Storage Permission
  static Future<bool> getStoragePermission(BuildContext context) async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt <= 32) {
        PermissionStatus permissionStatus = await Permission.storage.status;

        if (permissionStatus.isGranted) {
          return true;
        } else if (permissionStatus.isDenied) {
          PermissionStatus status = await Permission.storage.request();
          if (status.isGranted) {
            return true;
          } else {
            Fluttertoast.showToast(msg: 'Storage permission is required');
            return false;
          }
        } else if (permissionStatus.isPermanentlyDenied) {
          await showDialog<bool>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Permission Denied'),
                  content: const Text(
                      "You have to manually enable the photos permission's status in the system settings."),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Open Settings'),
                      onPressed: () {
                        Navigator.pop(context, false);
                        openAppSettings();
                      },
                    ),
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () {
                        Navigator.pop(context, false);
                      },
                    ),
                  ],
                );
              });
          return false;
        }
      } else {
        PermissionStatus permissionStatus = await Permission.photos.status;

        if (permissionStatus.isGranted) {
          return true;
        } else if (permissionStatus.isDenied) {
          PermissionStatus status = await Permission.photos.request();
          if (status.isGranted) {
            return true;
          } else {
            Fluttertoast.showToast(msg: 'Photos permission is required');
            return false;
          }
        } else if (permissionStatus.isPermanentlyDenied) {
          await showDialog<bool>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Permission Denied'),
                  content: const Text(
                      "You have to manually enable the photos permission's status in the system settings."),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Open Settings'),
                      onPressed: () {
                        Navigator.pop(context, false);
                        openAppSettings();
                      },
                    ),
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () {
                        Navigator.pop(context, false);
                      },
                    ),
                  ],
                );
              });
          return false;
        }
      }
    } else {
      // iOS
      PermissionStatus permissionStatus = await Permission.photos.status;

      if (permissionStatus.isGranted) {
        return true;
      } else if (permissionStatus.isDenied) {
        PermissionStatus status = await Permission.photos.request();
        if (status.isGranted) {
          return true;
        } else {
          Fluttertoast.showToast(msg: 'Photos permission is required');
          return false;
        }
      } else if (permissionStatus.isPermanentlyDenied) {
        await showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Permission Denied'),
                content: const Text(
                    "You have to manually enable the photos permission's status in the system settings."),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Open Settings'),
                    onPressed: () {
                      Navigator.pop(context, false);
                      openAppSettings();
                    },
                  ),
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                  ),
                ],
              );
            });
        return false;
      }
    }
    return false;
  }

  ///
  ///
  /// Checking Camera Permission
  static Future<bool> getMicrophonePermission(BuildContext context) async {
    PermissionStatus permissionStatus = await Permission.microphone.status;

    if (permissionStatus.isGranted) {
      return true;
    } else if (permissionStatus.isDenied) {
      PermissionStatus status = await Permission.microphone.request();
      if (status.isGranted) {
        return true;
      } else {
        Fluttertoast.showToast(msg: 'Microphone permission is required');
        return false;
      }
    } else if (permissionStatus.isPermanentlyDenied) {
      await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Permission Denied'),
              content: const Text(
                  "You have to manually enable the microphone permission's status in the system settings."),
              actions: <Widget>[
                TextButton(
                  child: const Text('Open Settings'),
                  onPressed: () {
                    Navigator.pop(context, false);
                    openAppSettings();
                  },
                ),
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                ),
              ],
            );
          });
      return false;
    }
    return false;
  }
}
