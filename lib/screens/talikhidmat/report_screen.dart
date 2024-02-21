import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:dotted_border/dotted_border.dart';

import '../../utils/app_localization.dart';
import '../../utils/global_dialog_helper.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  final picker = ImagePicker();

  List<Map> _images = [];

  late String _category;

  /// Delete images
  ///
  /// Receives [imagePath] as the file image path
  void _removePhoto(String imagePath) {
    setState(() {
      _images.removeWhere((img) => img['file'].path == imagePath);
    });
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
        .then((value) async {
      try {
        // TODO: Upload Service
        // Response? response = await UploadFileService().uploadFile(
        //   value,
        //   type,
        //   name,
        // );
        // if (response!.data["status"] == '200') {
        //   Navigator.of(context).pop(true);
        //   setState(() {
        //     _images.insert(0, {
        //       "file": selectedImage,
        //       "imgUrl": response.data["data"],
        //     });
        //   });
        // }
      } catch (e) {
        Navigator.of(context).pop(true);
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
        child: Container(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(
                  Icons.photo_library,
                  size: 30,
                ),
                title: Text(
                  AppLocalization.of(context)!.translate('photo_library')!,
                  style: TextStyle(
                    fontSize: 18.0,
                  ),
                ),
                onTap: () {
                  _getPhotoLibrary();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.photo_camera,
                  size: 30,
                ),
                title: Text(
                  AppLocalization.of(context)!.translate('camera')!,
                  style: TextStyle(
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
      ),
    );
  }

  @override
  void initState() {
    _category = '1';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Form(
      key: _formKey,
      child: GestureDetector(
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
              margin: EdgeInsets.only(top: 5.0),
              child: Text(
                "Your feedback makes a difference",
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            Divider(),
            Container(
              margin: EdgeInsets.only(
                top: 15.0,
              ),
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText:
                      AppLocalization.of(context)!.translate('category')! + "*",
                  labelStyle: TextStyle(
                    fontSize: 18.0,
                  ),
                ),
                focusColor: Theme.of(context).primaryColor,
                isExpanded: true,
                value: _category,
                iconSize: 35.0,
                items: [
                  DropdownMenuItem(
                    child: Text(
                      AppLocalization.of(context)!.translate('complaint')!,
                      style: TextStyle(
                        fontSize: 18.0,
                      ),
                    ),
                    value: '1',
                  ),
                  DropdownMenuItem(
                    child: Text(
                      AppLocalization.of(context)!.translate('compliment')!,
                      style: TextStyle(
                        fontSize: 18.0,
                      ),
                    ),
                    value: '3',
                  ),
                  DropdownMenuItem(
                    child: Text(
                      AppLocalization.of(context)!.translate('enquiry')!,
                      style: TextStyle(
                        fontSize: 18.0,
                      ),
                    ),
                    value: '4',
                  ),
                  DropdownMenuItem(
                    child: Text(
                      AppLocalization.of(context)!
                          .translate('request_for_service')!,
                      style: TextStyle(
                        fontSize: 18.0,
                      ),
                    ),
                    value: '2',
                  ),
                  DropdownMenuItem(
                    child: Text(
                      AppLocalization.of(context)!.translate('suggestion')!,
                      style: TextStyle(
                        fontSize: 18.0,
                      ),
                    ),
                    value: '5',
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _category = value!;
                  });
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.only(
                top: 10.0,
              ),
              child: TextFormField(
                style: TextStyle(
                  fontSize: 18.0,
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalization.of(context)!
                        .translate('please_enter_messages')!;
                  }
                },
                controller: _messageController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText:
                      AppLocalization.of(context)!.translate('message')! + "*",
                  labelStyle: TextStyle(
                    fontSize: 18.0,
                  ),
                ),
                maxLines: 3,
                textInputAction: TextInputAction.done,
                // keyboardType: TextInputType.multiline,
              ),
            ),
            SizedBox(
              height: 15.0,
            ),
            Text("Attachments:"),
            Container(
              margin: const EdgeInsets.only(
                top: 15.0,
              ),
              height: screenSize.height * 0.13,
              child: _images.length == 0
                  ? GestureDetector(
                      onTap: _showPhotoModal,
                      child: DottedBorder(
                        color: Colors.grey,
                        radius: Radius.circular(5.0),
                        strokeWidth: 1,
                        borderType: BorderType.RRect,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.add_a_photo,
                                size: 30,
                              ),
                              SizedBox(
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Icon(
                                          Icons.add_a_photo,
                                          size: 25,
                                          color: Colors.grey.shade700,
                                        ),
                                        SizedBox(
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
                // top: 4,
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
                      child: Icon(
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
