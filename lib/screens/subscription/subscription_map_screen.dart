import 'dart:async';
import 'dart:collection';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../utils/global_dialog_helper.dart';
import '../../models/cctv_model.dart';
import '../../utils/app_localization.dart';
import '../../widgets/subscription/map_bottom_sheet_widget.dart';
import '../../providers/cctv_provider.dart';
import '../../models/cctv_model.dart';

class SubscriptionMapScreen extends StatefulWidget {
  static const String routeName = "subscription-map-screen";

  const SubscriptionMapScreen({super.key});

  @override
  State<SubscriptionMapScreen> createState() => _SubscriptionMapScreenState();
}

class _SubscriptionMapScreenState extends State<SubscriptionMapScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  final GlobalDialogHelper _globalDialogHelper = GlobalDialogHelper();

  Set<Marker> _markers = HashSet<Marker>();

  bool _isError = false;
  late bool _isLoading;
  late double _latitude;
  late double _longitude;
  late CameraPosition _initialLocation;

  // TODO: CCTV Marker
  // TODO: CCTV Local Sample Video (.flv)

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  double convertStringToDouble(String value) {
    return double.parse(value);
  }

  Future<void> onPressCctvIcon(CCTVModel cctv) async {
    Future<void> handleFuture() async {
      try {
        await Provider.of<CCTVProvider>(context, listen: false)
            .getCctvDetailProvider(cctv);
      } catch (e) {
        setState(() {
          _isError = true;
        });
      }

      Map<String, dynamic> data = {
        "channel": "02",
        "thridDeviceId": cctv.cctvId,
      };
      try {
        await Provider.of<CCTVProvider>(context, listen: false)
            .getCameraShortCutUrlProvider(data);
      } catch (e) {
        setState(() {
          _isError = true;
        });
      }
    }

    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return FutureBuilder(
            future: handleFuture(),
            builder: (_, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                if (_isError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 150,
                          child: SvgPicture.asset(
                              'assets/images/undraw_online.svg'),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Text(AppLocalization.of(context)!
                            .translate('camera_is_not_available')!),
                      ],
                    ),
                  );
                }
                return const MapBottomSheetWidget();
              }
            });
      },
    );
  }

  /// Displays the markers of CCTV on Google Map when screen first renders
  Future<void> _renderMarker() async {
    // TODO: vms/getCameraList => API
    bool success = await Provider.of<CCTVProvider>(context, listen: false)
        .getCctvCoordinatesProvider();
    if (success) {
      List<CCTVModel> cctvModel =
          Provider.of<CCTVProvider>(context, listen: false).cctvModel;

      final Uint8List markerIcon =
          await getBytesFromAsset('assets/images/icon/cctv.png', 80);
      cctvModel.forEach((cctv) {
        setState(() {
          _markers.add(
            Marker(
              markerId: MarkerId(cctv.cctvId),
              position: LatLng(
                convertStringToDouble(cctv.latitude),
                convertStringToDouble(cctv.longitude),
              ),
              icon: BitmapDescriptor.fromBytes(markerIcon),
              onTap: () async {
                setState(() {
                  _isError = false;
                });
                await onPressCctvIcon(cctv);
              },
            ),
          );
        });
      });
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _showBottomModalSheetFirstNote() async {
    await showModalBottomSheet(
        context: context,
        builder: (_) {
          return Container(
              // Define padding for the container.
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 15,
              ),
              // Create a Wrap widget to display the sheet contents.
              child: Wrap(
                spacing: 60, // Add spacing between the child widgets.
                children: <Widget>[
                  // Add a container with height to create some space.
                  Container(height: 10),
                  // Add a text widget with a title for the sheet.
                  Text(
                    "Note",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Container(height: 10), // Add some more space.
                  // Add a text widget with a long description for the sheet.
                  Text(
                    'Currently, the location of cameras focuses around city of Kuching. It will be updated from time to time.',
                    style: TextStyle(
                        color: Colors.grey[600], // Set the text color.
                        fontSize: 16.0 // Set the text size.
                        ),
                  ),
                  Container(height: 10), // Add some more space.
                  // Add a row widget to display buttons for closing and reading more.
                  Row(
                    mainAxisAlignment: MainAxisAlignment
                        .end, // Align the buttons to the right.
                    children: <Widget>[
                      // Add an elevated button to read more.
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                        ), // Set the button background color.
                        onPressed: () {
                          Navigator.pop(context); // Close the sheet.
                        },
                        child: Text("Okay",
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary)), // Add the button text.
                      )
                    ],
                  )
                ],
              ));
        });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _isLoading = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // default location: Kuching Waterfront
      _latitude = 1.558497;
      _longitude = 110.344320;
      _initialLocation = CameraPosition(
        target: LatLng(_latitude, _longitude),
        zoom: 14.4746,
      );
      _renderMarker();
      _showBottomModalSheetFirstNote();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Map Display"),
      ),
      body: _isLoading
          ? _globalDialogHelper.showLoadingSpinner()
          : GoogleMap(
              initialCameraPosition: _initialLocation,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              mapToolbarEnabled: false,
              mapType: MapType.terrain,
              markers: _markers,
            ),
    );
  }
}
