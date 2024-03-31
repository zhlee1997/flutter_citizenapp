import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:provider/provider.dart';

import '../../utils/app_localization.dart';
import '../../utils/global_dialog_helper.dart';
import '../../services/upload_services.dart';
import '../../providers/talikhidmat_provider.dart';

class ReportScreen extends StatefulWidget {
  final String category;
  final Function(String?) categoryCallback;
  final Function(String) messageCallback;
  final GlobalKey<FormState> formKey;

  const ReportScreen({
    required this.category,
    required this.categoryCallback,
    required this.messageCallback,
    required this.formKey,
    super.key,
  });

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _messageController = TextEditingController();
  final picker = ImagePicker();

  List<Map> _images = [];

  // late String _category;

  /// Delete images
  ///
  /// Receives [imagePath] as the file image path
  void _removePhoto(String imagePath) {
    setState(() {
      _images.removeWhere((img) => img['file'].path == imagePath);
    });
    // TODO: new added provider for images
    Provider.of<TalikhidmatProvider>(context).removeAttachement(
      attachment: imagePath,
    );
  }

  /// Get image using camera
  Future _getPhotoCamera() async {
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.camera);

      if (pickedFile != null) {
        _uploadFile(pickedFile);
      } else {
        print('No image selected in camera.');
      }
    } catch (e) {
      print('_getPhotoCamera error');
      print(e);
    }
  }

  /// Upload images when receiving image file from gallery or camera
  /// Using uploadFile API
  ///
  /// Receives [pickedFile] as the source of image file information
  /// such as file path, file type and file name
  Future<void> _uploadFile(XFile pickedFile) async {
    File selectedImage = File(pickedFile.path);
    String path = pickedFile.path;
    String name = path.substring(path.lastIndexOf("/") + 1, path.length);
    String type = name.substring(name.lastIndexOf(".") + 1, name.length);

    double imageByte = selectedImage.lengthSync() / (1024 * 1024);
    print('imageSize: $imageByte');
    if (imageByte > 10.0) {
      Fluttertoast.showToast(
        msg: AppLocalization.of(context)!.translate('image_less_than_10')!,
      );
      return;
    }

    GlobalDialogHelper().buildCircularProgressWithTextCenter(
      context: context,
      message: AppLocalization.of(context)!.translate('upload_photo')!,
    );

    FlutterImageCompress.compressWithFile(path, quality: 75)
        .then((Uint8List? value) async {
      try {
        // TODO: Upload image service
        var response = await UploadServices().uploadFile(
          value,
          type,
          name,
        );
        if (response["status"] == '200') {
          Navigator.of(context).pop();
          setState(() {
            _images.insert(0, {
              "file": selectedImage,
              "imgUrl": response["data"],
            });
          });
          // TODO: new added provider for images
          Provider.of<TalikhidmatProvider>(context, listen: false)
              .setAttachement(
            // imageUrl
            attachment: response["data"],
          );
        }
      } catch (e) {
        print("_uploadFile error: ${e.toString()}");
        Navigator.of(context).pop();
        Fluttertoast.showToast(
          msg: AppLocalization.of(context)!.translate('upload_fail')!,
        );
      }
    });
  }

  // Get image using gallery
  Future _getPhotoLibrary() async {
    try {
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        _uploadFile(pickedFile);
      } else {
        print('No image selected in gallery.');
      }
    } catch (e) {
      print('_getPhotoLibrary error');
      print(e);
    }
  }

  // display image upload method in a modal
  Future<void> _showPhotoModal() async {
    FocusScope.of(context).unfocus();
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext ctx) => SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                size: 30,
              ),
              title: Text(
                AppLocalization.of(context)!.translate('photo_library')!,
                style: const TextStyle(
                  fontSize: 18.0,
                ),
              ),
              onTap: () {
                _getPhotoLibrary();
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_camera,
                size: 30,
              ),
              title: Text(
                AppLocalization.of(context)!.translate('camera')!,
                style: const TextStyle(
                  fontSize: 18.0,
                ),
              ),
              onTap: () {
                _getPhotoCamera();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          Image.asset(
              "assets/images/pictures/talikhidmat/talikhidmat_banner.jpg"),
          Container(
            margin: const EdgeInsets.only(top: 5.0),
            child: const Text(
              "Your feedback makes a difference",
              style: TextStyle(
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const Divider(),
          Container(
            height: screenSize.height * 0.1,
            margin: const EdgeInsets.only(
              top: 15.0,
            ),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText:
                    "${AppLocalization.of(context)!.translate('category')!}*",
                labelStyle: const TextStyle(
                  fontSize: 18.0,
                ),
              ),
              focusColor: Theme.of(context).primaryColor,
              isExpanded: true,
              value: widget.category,
              iconSize: 35.0,
              items: [
                DropdownMenuItem(
                    value: '1',
                    child: Text(
                      AppLocalization.of(context)!.translate('complaint')!,
                      style: const TextStyle(
                        fontSize: 18.0,
                      ),
                    )),
                DropdownMenuItem(
                  value: '2',
                  child: Text(
                    AppLocalization.of(context)!
                        .translate('request_for_service')!,
                    style: const TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                ),
                DropdownMenuItem(
                  value: '3',
                  child: Text(
                    AppLocalization.of(context)!.translate('compliment')!,
                    style: const TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                ),
                DropdownMenuItem(
                  value: '4',
                  child: Text(
                    AppLocalization.of(context)!.translate('enquiry')!,
                    style: const TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                ),
                DropdownMenuItem(
                  value: '5',
                  child: Text(
                    AppLocalization.of(context)!.translate('suggestion')!,
                    style: const TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                ),
              ],
              onChanged: (value) {
                widget.categoryCallback(value);
              },
            ),
          ),
          Container(
            height: screenSize.height * 0.13,
            margin: const EdgeInsets.only(
              top: 10.0,
            ),
            child: Form(
              key: widget.formKey,
              child: TextFormField(
                style: const TextStyle(
                  fontSize: 18.0,
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalization.of(context)!
                        .translate('please_enter_messages')!;
                  }
                  return null;
                },
                controller: _messageController,
                onChanged: (value) {
                  widget.messageCallback(value);
                },
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText:
                      "${AppLocalization.of(context)!.translate('message')!}*",
                  labelStyle: const TextStyle(
                    fontSize: 18.0,
                  ),
                ),
                maxLines: 3,
                textInputAction: TextInputAction.done,
                // keyboardType: TextInputType.multiline,
              ),
            ),
          ),
          const SizedBox(
            height: 15.0,
          ),
          const Text("Attachments:"),
          Container(
            margin: const EdgeInsets.only(
              top: 15.0,
            ),
            height: screenSize.height * 0.1,
            child: _images.length == 0
                ? GestureDetector(
                    onTap: _showPhotoModal,
                    child: DottedBorder(
                      color: Colors.grey,
                      radius: const Radius.circular(5.0),
                      strokeWidth: 1,
                      borderType: BorderType.RRect,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const Icon(
                              Icons.add_a_photo,
                              size: 30,
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text('${_images.length} / 5'),
                          ],
                        ),
                      ),
                    ),
                  )
                : ListView(
                    scrollDirection: Axis.horizontal,
                    children: <Widget>[
                      ..._returnImageWidget(),
                      _images.length == 5
                          ? Container()
                          : GestureDetector(
                              onTap: _showPhotoModal,
                              child: Container(
                                height: screenSize.height * 0.15,
                                width: screenSize.width * 0.25,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        Icons.add_a_photo,
                                        size: 25,
                                        color: Colors.grey.shade700,
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Text('${_images.length} / 5'),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                    ],
                  ),
          ),
          SizedBox(
            height: screenSize.width * 0.05,
          ),
        ],
      ),
    );
  }

  // return image Widget
  List<Stack> _returnImageWidget() {
    return _images
        .map(
          (e) => Stack(
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height * 0.14,
                width: MediaQuery.of(context).size.width * 0.25,
                margin: const EdgeInsets.only(
                  left: 8.0,
                  right: 8.0,
                  top: 8.0,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                    width: 0.5,
                  ),
                ),
                child: Image.file(
                  e['file'],
                  fit: BoxFit.contain,
                ),
              ),
              Positioned(
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    _removePhoto(e['file'].path);
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(200),
                    child: Container(
                      width: 20,
                      height: 20,
                      color: Theme.of(context).colorScheme.secondary,
                      child: const Icon(
                        Icons.close,
                        color: Colors.black,
                        size: 12.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
        .toList();
  }
}
