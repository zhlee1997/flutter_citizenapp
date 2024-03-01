import 'dart:async';
import 'dart:collection';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../utils/global_dialog_helper.dart';
import '../../models/cctv_model.dart';
import '../../providers/cctv_provider.dart';
import '../../providers/location_provider.dart';
import '../../utils/app_localization.dart';
import '../../widgets/subscription/map_bottom_sheet_widget.dart';

class SubscriptionMapScreen extends StatefulWidget {
  static const String routeName = "subscription-map-screen";

  const SubscriptionMapScreen({super.key});

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(1.576472, 110.345828),
    zoom: 14.4746,
  );

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
  Position? _currentLocation;
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
      //   try {
      //     await Provider.of<CctvProvider>(context, listen: false)
      //         .getCctvDetailProvider(cctv);
      //   } catch (e) {
      //     setState(() {
      //       _isError = true;
      //     });
      //   }

      //   Map<String, dynamic> data = {
      //     "channel": "02",
      //     "thridDeviceId": cctv.cctvId,
      //   };
      //   try {
      //     await Provider.of<CctvProvider>(context, listen: false)
      //         .getCameraShortCutUrlProvider(data);
      //   } catch (e) {
      //     setState(() {
      //       _isError = true;
      //     });
      //   }
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
    List<CCTVModel> cctvModel = [
      CCTVModel(
        cctvId: "cctvId1",
        latitude: "1.553110",
        longitude: "110.345032",
        channel: "02",
        deviceName: "SIOC CCTV",
        location: "SIOC Kuching",
      ),
    ];
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // TODO: if location denied, cant access
    _isLoading = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _currentLocation =
          Provider.of<LocationProvider>(context, listen: false).currentLocation;
      if (_currentLocation != null) {
        _latitude = _currentLocation!.latitude;
        _longitude = _currentLocation!.longitude;
        _initialLocation = CameraPosition(
          target: LatLng(_latitude, _longitude),
          zoom: 14.4746,
        );
        _renderMarker();
      }
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
