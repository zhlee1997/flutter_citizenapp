import 'dart:io' show Platform;
import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../utils/app_localization.dart';
import '../../utils/global_dialog_helper.dart';
import '../../providers/bus_provider.dart';
import '../../models/bus_model.dart';
import '../../widgets/bus_schedule/bus_detail_bottom_modal.dart';
import '../../widgets/bus_schedule/bus_map_filter_drawer.dart';

class BusMapScreen extends StatefulWidget {
  static const routeName = 'bus-map-screen';

  const BusMapScreen({super.key});

  @override
  State<BusMapScreen> createState() => _BusMapScreenState();
}

class _BusMapScreenState extends State<BusMapScreen> {
  bool _isLoading = false;
  late CameraPosition? _initialLocation;
  late double _latitude;
  late double _longitude;
  Position? _currentLocation;
  Completer<GoogleMapController> _controller = Completer();
  PolylinePoints polylinePoints = PolylinePoints();
  List<LatLng> _polyPoints = [];
  Set<Polyline> _polylines = HashSet<Polyline>();
  Set<Marker> _markers = HashSet<Marker>();
  final BusRouteEncodedString busRouteEncodedString = BusRouteEncodedString();
  late bool _isLoadingAction;
  bool _isBottomModalError = false;

  double convertStringToDouble(String val) => double.parse(val);

  // note: longitude, latitude are inter-changed
  /// Plot bus route polyline on Google Map when screen first renders
  /// And when switching to new route
  ///
  /// Receives [busStationList] as the list of bus stations from API
  void _getRoutes(String routeId) {
    if (routeId == "c007661d0bd643a9896829a42d6ce915") {
      List<PointLatLng> route_1 = polylinePoints
          .decodePolyline(busRouteEncodedString.semenggohToDunRoutePartOne);
      print(route_1);

      List<PointLatLng> route_2 = polylinePoints
          .decodePolyline(busRouteEncodedString.semenggohToDunRoutePartTwo);
      print(route_2);

      List<PointLatLng> route_3 = polylinePoints
          .decodePolyline(busRouteEncodedString.semenggohToDunRoutePartThree);
      print(route_3);

      if (route_1.isNotEmpty) {
        route_1.forEach((element) {
          _polyPoints.add(LatLng(element.latitude, element.longitude));
        });
      }
      if (route_2.isNotEmpty) {
        route_2.forEach((element) {
          _polyPoints.add(LatLng(element.latitude, element.longitude));
        });
      }
      if (route_3.isNotEmpty) {
        route_3.forEach((element) {
          _polyPoints.add(LatLng(element.latitude, element.longitude));
        });
      }
    } else {
      // routeId => c007661d0bd643a9896829a42d6ce916
      List<PointLatLng> route_1 = polylinePoints
          .decodePolyline(busRouteEncodedString.dunToSemenggohRoutePartOne);
      print(route_1);

      List<PointLatLng> route_2 = polylinePoints
          .decodePolyline(busRouteEncodedString.dunToSemenggohRoutePartTwo);
      print(route_2);

      List<PointLatLng> route_3 = polylinePoints
          .decodePolyline(busRouteEncodedString.dunToSemenggohRoutePartThree);
      print(route_3);

      if (route_1.isNotEmpty) {
        route_1.forEach((element) {
          _polyPoints.add(LatLng(element.latitude, element.longitude));
        });
      }
      if (route_2.isNotEmpty) {
        route_2.forEach((element) {
          _polyPoints.add(LatLng(element.latitude, element.longitude));
        });
      }
      if (route_3.isNotEmpty) {
        route_3.forEach((element) {
          _polyPoints.add(LatLng(element.latitude, element.longitude));
        });
      }
    }
    _polylines.add(Polyline(
      polylineId: const PolylineId("polylines"),
      color: Colors.purple,
      width: 5,
      points: _polyPoints,
    ));
    if (mounted) {
      setState(() {
        _isLoadingAction = false;
      });
    }
  }

  Future<void> getBusStation(String routeId) async {
    try {
      List<BusStationCoordinatesModel> busStationList =
          await Provider.of<BusProvider>(context)
              .setStationCoordinates(routeId);
      if (busStationList.isNotEmpty) {
        setState(() {
          _isLoading = false;
        });
        _renderMarker(busStationList);
        _getRoutes(routeId);
      }
    } catch (e) {
      throw e;
    }
  }

  /// Displays the markers of bus station on Google Map when screen first renders
  /// And when switching to new route
  ///
  /// Receives [busStationList] as the list of bus stations from API
  _renderMarker(List<BusStationCoordinatesModel> busStationList) async {
    // Important: longitude, latitude are inter-changed
    busStationList.asMap().forEach((index, bus) {
      _markers.add(
        Marker(
          markerId: MarkerId(bus.stationId),
          position: LatLng(
            convertStringToDouble(bus.stationLongitude),
            convertStringToDouble(bus.stationLatitude),
          ),
          onTap: () {
            setState(() {
              _isBottomModalError = false;
            });
            _showStationInformationBottomModal(
              latitude: convertStringToDouble(bus.stationLongitude),
              longitude: convertStringToDouble(bus.stationLatitude),
              busStationList: busStationList,
              currentValue: index,
              stationId: bus.stationId,
              stationName: bus.stationName,
            );
          },
        ),
      );
    });
  }

  /// Displays the details of bus station when tapping on markers
  /// Using fetchStationDetail API
  ///
  /// Receives [latitude] and [longitude] as the location of the bus station,
  /// [busStationList] as the list of bus station
  /// [currentValue] as the index of the bus station list
  /// [stationId] as the bus station ID
  /// [stationName] as the bus station name
  Future<void> _showStationInformationBottomModal({
    required double latitude,
    required double longitude,
    required List<BusStationCoordinatesModel> busStationList,
    required int currentValue,
    required String stationId,
    required String stationName,
  }) async {
    late List<BusStationModel> filteredBusStationList;
    final now = DateTime.now().toUtc();

    Future<void> handleFetchStationDetail() async {
      try {
        List<BusStationModel>? busStationDetailList =
            await Provider.of<BusProvider>(context, listen: false)
                .fetchStationDetail(
          Provider.of<BusProvider>(context, listen: false).routeId!,
          stationId,
        );
        filteredBusStationList = busStationDetailList!.where((element) {
          int hourString = int.parse(element.arrivalTime.substring(11, 13));
          int minuteString = int.parse(element.arrivalTime.substring(14, 16));
          DateTime datetimeString = DateTime(
            now.year,
            now.month,
            now.day,
            hourString,
            minuteString,
            now.second,
          );
          return datetimeString.isAfter(DateTime.now());
        }).toList();
        filteredBusStationList
            .sort((a, b) => a.arrivalTime.compareTo(b.arrivalTime));
      } catch (e) {
        print('handleFetchStationDetail failed');
        setState(() {
          _isBottomModalError = true;
        });
      }
    }

    await showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (_) => FutureBuilder(
            future: handleFetchStationDetail(),
            builder: (BuildContext ctx, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                return _isBottomModalError
                    ? Container(
                        color: Colors.white,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 150,
                                child: SvgPicture.asset(
                                    'assets/images/svg/undraw_bus_stop.svg'),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Text(
                                AppLocalization.of(context)!
                                    .translate('bus_stop_not_found')!,
                              ),
                            ],
                          ),
                        ),
                      )
                    : BusDetailMapBottom(
                        latitude: latitude,
                        longitude: longitude,
                        busStationList: busStationList,
                        currentValue: currentValue,
                        stationDetailList: filteredBusStationList,
                        stationName: stationName,
                      );
              }
            }));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _isLoading = true;
    // by default, show Kuching location
    _latitude = 1.556736;
    _longitude = 110.342802;
    _initialLocation = CameraPosition(
      target: LatLng(_latitude, _longitude),
      zoom: 13,
    );
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    String? routeId = Provider.of<BusProvider>(context).routeId;
    if (routeId == null) {
      Provider.of<BusProvider>(context, listen: false).setBusRouteProvider();
    }
    _isLoadingAction = true;
    _polylines.clear();
    _markers.clear();
    _polyPoints = [];
    if (routeId != null) {
      getBusStation(routeId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: BusMapFilterDrawer(onPressAnimate: () {}),
      appBar: AppBar(
        title: Text("Bus Schedule"),
        leading: GestureDetector(
          child: Icon(
              Platform.isIOS ? Icons.arrow_back_ios_rounded : Icons.arrow_back),
          onTap: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          Builder(
            builder: (ctx) => TextButton(
              onPressed: !_isLoadingAction
                  ? () => Scaffold.of(ctx).openEndDrawer()
                  : null,
              child: Text(
                AppLocalization.of(context)!.translate('select')!,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? GlobalDialogHelper().showLoadingSpinner()
          : Consumer<BusProvider>(
              builder: (_, busData, __) {
                return Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: _initialLocation!,
                      onMapCreated: (GoogleMapController controller) {
                        if (!_controller.isCompleted) {
                          _controller.complete(controller);
                        }
                      },
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      // TODO: markers, polylines (encoded string)
                      markers: _markers,
                      polylines: _polylines,
                    ),
                    // TODO: ActionChip
                    // Positioned(
                    //   left: 0,
                    //   right: 0,
                    //   top: 5,
                    //   child: Builder(
                    //     builder: (ctx) => ActionChip(
                    //       onPressed: () => _isLoadingAction
                    //           ? null
                    //           : Scaffold.of(ctx).openEndDrawer(),
                    //       elevation: 5.0,
                    //       backgroundColor: Theme.of(context).primaryColor,
                    //       avatar: Container(
                    //         child: _isLoadingAction
                    //             ? CircularProgressIndicator(
                    //                 color: Colors.white,
                    //                 strokeWidth: 3.5,
                    //               )
                    //             : Icon(
                    //                 Icons.directions_bus_filled_rounded,
                    //                 color: Colors.white,
                    //                 size: 20,
                    //               ),
                    //       ),
                    //       label: Text(
                    //         _isLoadingAction
                    //             ? AppLocalization.of(context)!
                    //                 .translate('loading')!
                    //             : busData.routeName == "DS"
                    //                 ? 'DUN > Semenggoh'
                    //                 : 'Semenggoh > DUN',
                    //         style: TextStyle(
                    //           color: Colors.white,
                    //           fontSize: 16,
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                );
              },
            ),
    );
  }
}

// Encoded Google Polyline String => bus route id: c007661d0bd643a9896829a42d6ce915
// Generated by Google Directions Service API
class BusRouteEncodedString {
  String get semenggohToDunRoutePartOne =>
      "iopG_xj`TcBr@Wm@sAZiANy@?aAGqAEa@?q@@gAKuCf@gGjAeAD{AKgC]oKeBkF}@sIiAkD_@cEU_Fa@eDB}AViBj@eAZyCt@w@JoAAwFo@uHk@_AE{@KmAa@oBw@}@YwCYu@CUOA@A?A?C?CA}AB_EGoABcDE]EgAYw@W{@a@uAy@]UMYEe@BOKa@WCsEScG]cFi@aFUm@?_DJiJf@}CHmB@eAEoEGiSi@eCCcHMyGE}@?oAF}ARyAb@_A^uGdDwBhAqB`AsBt@sCp@oQrBuDb@iEXoBCeAGeAMo@K}Bg@s@U}D_ByDyAkEiA_GuAaCm@Kb@[IiBe@s@Qk@CCEwDcAICNg@y@UiAQuBEy@@kCVsA@uIQkEKgEKk@E_CGUCeB_@kAk@_Aw@sA_Bs@q@kAq@mAa@gAQqBUm@Fy@EoFUwDUgCM_CQCTM~BMjBIlBGf@Q\\]P_@@_@OMOe@eAG_@Ac@G[C]AI@H?LF\\F`Aj@tAVVb@H\\GPMP]L}APcDL_CBUYCiBKkFQpAkH|@eFHgBWkBQk@e@u@s@q@s@e@_GaCsJqFw@c@aA]yCk@qAUaAUWOQQ@U@WHUPWxAYR[v@m@d@y@Lw@QoAg@_BmBkGg@_BOUWa@WKWI}@Gm@Bk@?gA^]AQAc@Me@e@kAkD_AuDiDeLcAsCc@q@aAcAe@]u@U_@I^mEh@{Hj@gIFeBCwBSiByAyKmAaIy@oGe@{BKe@uA}FkA{E{HmYgCqJiAiE_BqGWuBe@kGC}@AOaAFqBLiIh@sCH{DIqCQkCQe@Dk@JEFURu@~@}@dBmBdEqAfCm@`Bi@vB_@`BOnAElBBbARfBr@dEf@`EXhCBr@?j@e@`GM|CBbAZ~Bl@fEd@xCjBhHrA|Dz@zC\rDRjCl@nKFrGBdEQN?h@ITWb@U\\aAr@eAf@QBVL^JN^GVCHSZCCUIQGkEgBgCiAm@YOOCI{@UoJuDmO_GeEqAgAQ_CWsD]kPmBM^y@\\kBj@qC`AGKQQOMsA_@WEOATyC{BYw@ICM?]@IcAK_@ERcCx@wBbAoB`CsEn@gBX{@vAsE`AsCdAsDh@mBb@eAVcAdCeT\\{A`@aAtAeCz@gAfCwCXk@|CiHg@GDKp@gBd@kBx@wE|@iFJeAAk@ESCKBq@lAPR_BJaAKc@Mg@S[UUa@UqTyIcAg@SQ[WOLKDeGcGULm@t@T\\BHS`@{@y@oBxBQSQMi@a@kAk@c@OUUiAm@_@UqAg@wA}AiEvEqAnA";
  String get semenggohToDunRoutePartTwo =>
      "_whHseu`TuAnA{@fA{@~As@tB{@lDIx@CdBI|BMn@UjAOh@aAfBw@bBUn@g@~BGbAI|FElDKdAYbBWnBS~A_@rBgAlEm@~C]hESfDk@lHSfB[dAO`@E^Cn@Nt@@\\Eb@Md@Q\\SV]TYJe@Hw@@eAGc@Oa@Se@Ks@?]Du@XsAf@i@PDLAd@?NK?K@yAh@c@REJ?Jb@bApAfDw@XkAz@iAz@MLMIMSI_@Mc@SYUWQo@K_@[aAYw@iDvAa@PCZANEJEBEI[{@IIE?KBIFILETmCfAuEhBc@N{@Rm@Fm@Bg@?{DMaDQMAg@HwAj@c@Xa@y@{@gAq@iAgBmEq@gBiCiHy@qCmA{Ey@_De@aC[}@_AoB]m@GBmC}FaCmERIo@sAy@aBuAuC_@q@YWQKe@Oy@Uu@Oc@AO@OBu@lAu@~@s@d@kBbA]Rk@d@kAnAe@b@c@`@@\\@j@ItASjFM|DWbHEz@Kz@Ql@i@vA]x@U\\M`A@J@X?RGRUPSJo@`Bu@bB_@z@]f@c@h@eArAsAjAyA`AaAh@OPITGf@SdCEj@Id@e@tAu@rBS^a@`@YTe@Zy@^SJYRW`@W`@Ut@If@Gv@@ZN`A^xAL\\|ApBHRFV?z@Gt@BNFLZZICQ@]F}@f@CHAVBJQKG?OLYb@a@fAWn@m@~@gExGEL@HFFtB`At@\\l@NjBr@h@\rCrA~DtB|@h@hBlAj@PxEx@~@Lj@F^F?PDhAXrENpDBdB?lAKzAKhAIlA@xDBxDA`AEdBL@R?DuCbA@Cr@GdBEbACfAkAAQAChACnA?nBI~DCdBE|AKvAG`CD|@GlBOhBAlBGtBEb@Df@E`D?zB[KEN@DVH@P?PQV_EvEgArA@BHGF?BDINe@h@V^LL?DOTy@fAUQUZMIECK@SBMFY^y@dAURgAbAmAhA}@bA}@jAuBfCoBbC}AdBUV";
  String get semenggohToDunRoutePartThree =>
      "croHqsi`TsFrGoB`CsA|AkArAgBtBg@c@iEgEmAuAoBcCuCmDiGuHYYOIeBWkBWY?k@BQFc@Le@Fq@Km@Oe@UIMKc@AQe@u@c@m@gDwDyJwLiJsKmLiNwBuCm@oAw@_Ck@uBYs@e@i@_@YWg@Me@Ci@@i@B[[XSJMDsC`@mBXo@@a@C_@Gu@Qq@CoALuB\\gAHY@SEg@UYYQWAJIXQRWLLD^Db@Lv@?dAGlEo@|@Ed@BnAVd@B|C?xBET@JBx@^Me@Ci@@i@P}@Rk@p@o@Tk@F_@@]Aa@UwHMcBScFE_Ac@qISoCW_G_@iJ_AmNSoHWmES[GYO_CEaBLg@Ga@Kc@a@m@KKLD^D^A^GXQOTOn@Ar@x@vPh@tJd@~JR^NRVXb@TPDTBd@?n@K`BwApAgAzA}AvCyB|KqKZ]rA_BbFaFZc@Ti@`@mBO}CKa@[e@R@f@Cb@ILEpBEfCATKbC@hB?D_Bp@AHJ?^?z@?|@Gj@?Ts@?KvBQPiABuC?Br@DVPj@^|@zAnAbDpB~Ap@hAVfBX~HdAjBNbACt@IRCFNJRRFx@@h@EtAg@RVEDAHBHHBJ@`@S";

// Encoded Google Polyline String => bus route id: c007661d0bd643a9896829a42d6ce916
// Generated by Google Directions Service API
  String get dunToSemenggohRoutePartOne =>
      "qepHi`o`Ta@RKAICCI@IDESWeA`@ODi@Dy@ASGKSGOSBu@HcABkBO_IeAgBYiAW_Bq@cDqB{AoA_@}@Qk@IkAtC?hACPQJwBEeCD_BAsE?kCGm@[k@yGjFmA`A_@ZMPERBfAGb@O`@Y\\SNMDSRK\\?n@T~BRpCELILaB~AuEbEmBvAoE|DmFhFqCzCa@l@oBdB}BvBQZa@v@c@bAg@bBOdAKbAKzA`@tH~@nSTpENpAJn@Td@FHOMg@Sk@Cg@Le@`@Sj@M`@[XSJk@JcFt@o@@a@CeAUk@Es@?gBXyARgAFe@Mo@g@QWAJIXQRWLl@Jb@Lv@?dAG~Dk@r@Id@?`APjAL~FCl@?dAb@Vf@^Xd@h@Xr@j@tBv@~Bl@nAvBtCXYbCxCdHnIxDhEhNzOpCzCvAzAZRVJl@Hl@IFCXKn@Kl@Eb@Fj@NRLR^Fd@AVALMf@?XBPJLXPnC^^Px@x@jErFrCjDz@fAnAzAVS`@]B?@@pAvALIB?B?~A~AFCH@HDjAlAJALQHAVUrDcEdE}EnHyIxDsEpBaCfCeCfAqAd@m@?GGIGEj@}@JFP@g@t@NJZTLHT[TPx@gANU?EMMW_@d@i@HK?CCEG?GDC?BGbGeHPY?OAQWIAEDOg@YYAW@[EYOQWI[DoCJmDHc@EkAByARoGD{BH}BZuLWQQEoACBc@DkBDoA?]jA@BA?CJyBCSCEIAcA?@a@tBH?VBXDN@a@@q@@u@@}APaA`A_Cz@eCV}@Hi@Bu@A{AQyEM}AWcDyA}@aBUUE{@bCIJWEz@oB[M{@rBRFTDPC|@iCaC_@_@KmBiAQ?WP_@j@[NWC}@U{Ai@kA]{Aq@Q?KHaAlBa@bA[b@QJ}@\\s@aAy@AIJCLGKOMu@]SSQuCGgB@eARkAL_@jAkBXm@`EqG`AgBr@mBZc@\\U|@i@PWLs@Do@Cu@IW_@m@_AmAUk@[gAIm@GcABo@TmALc@Zk@LUTaAJy@v@uB^Wf@{ANGVGr@Ef@BRGJQ`@wEFWTYzCmBhAaAhB}Br@eAt@kBPs@?WG[N@VEp@WTQFSAm@EUMUIET[f@cAt@sBPo@ReD^{JNcF?iEVm@pD_DfC}ArAaArAoBJWD@~Ab@dBb@f@Tf@j@zA|CtBjE~AnD~AvCLGr@~Ap@tA|@rBVv@bAlD|@`Ep@jCt@xClAbDfAtC~BdGf@`Ad@n@JJ^Lz@Ln@BzAD|I^tACl@Gz@SxFyBtAi@";
  String get dunToSemenggohRoutePartTwo =>
      "}bkHy}p`TfJ{DxF{BJ[@WCQQ]z@?b@?T?RChB{@HM?Ob@?VGf@UTMJS?mACgAkABIE`AeAb@`@d@Tj@HF@NOr@S|@I|@@r@V`@G^K\\UZc@Nm@ToDb@sGb@aGZ{BpAwF|@oFv@wFHwABqAD_BBeCL{BLoAR_At@qB\\q@r@cBh@kCF_A\\sDZgBb@eB`@sAVq@l@kA~@wAj@q@fCcCLLlAwAzB_ChCaCh@`@\\FjFr@hAFN?ZSPM^^xBzBFQ?MGSrGdH~@|@n@\\zAl@hC~@zGpCxCrA~Ad@fATZBK\\}@jGg@jD_AtFsA`H_@hAi@lA{BvFg@dAm@`AeDzDwAbCa@|@]tAk@vF]hDu@xF]zA_C|HuAxD_BzEcAvCyC|Fg@dAg@nAE`@Pn@p@fAPTDPfE`@z@J?m@G{B@WFEfBGbEOtAIr@QfDzCk@l@NP[d@?PVn@LF|BX~D^Sd@nAJzD\\bANb@Fv@Zj@LDWMCM`@I^GAAG?ORFjCz@lChAdJhDpHtCvAj@z@TJRtDfBrB|@hBp@RDLH^s@?MEIIQUEa@Sb@MdAg@`@[X]j@gACyIMgFq@qLa@wEOy@yAuEo@oB_@DgA}Dc@mA_A}Ag@]YY~ASVMES}@sGIgAL{CXkDJwB@q@c@cFsAuIKcAI_BRADmBNoAhAyEl@aBpAgCjDkHt@_ATSJQDS@UCUGSdBr@bDXbBJ|BB~BCrF]lAGdDSbBG\\E@XT~EJlBTzBdApEzArFpCtKpAdFxEbQd@bBbCrJHb@l@zCr@tF`@hCnAlIh@hEd@|DFfBGpBk@xHSrDi@tJt@T`Ax@d@f@b@p@^~@b@rAhDdL~@tDjAjDd@d@NFd@F\\@fA_@T@j@EV?|@Fn@TRTBJNTlBfGnAbEPnAMv@Wh@MNQRe@XSZyAXQVITAVATPPVN`ATp@LrARdB^`A\bKzFf@XrChAjBv@r@d@r@p@d@t@Pj@RfABb@?\\IhA_@~BXC@^Dj@DHDAt@V~@HfABD[Ha@?KAQGGs@IeAGoAAg@@UfAKl@_@jBBTHZLZVVXTrAHnBRfCPfGZfAFtCNdCRZFJHtAFr@FDGJC|ADpCFvCCfA?pJPpDDbLV~AHALPBEt@EhB?|A|@t@\\RPJxCCfBD`@BnAFdBT`QxEtHrBdA`@rAb@zCjAjCdAnBf@lB^nBZ`AF`A?dBEpD_@xUqC~@QhA]n@SrB_A~A{@rDyBbAk@~DcBfBw@rB_ApBu@tA_@bBYtAMt@Ex@CdBDtERjALr@?tFXfFX";
  String get dunToSemenggohRoutePartThree =>
      "ucxG_tk`T|DR`AJv@BrAJzABpAHzCNbDFzBJdDLjHj@~CLzF^vF\\Cj@@n@@PRd@TV`@\\h@RXPr@Vb@P^Jf@Ff@BpCFtAA~DBpAE@ABAJ@FFTNl@VdCRf@?xCdAdA\vA^hALdF^xD`@hBRj@@f@?VCPCbASvBm@zBu@nB_@dAEhA?`ABnDZjFZhFj@pC^hFv@`F~@vGdApBVhBPv@A|@MrB]fDs@nASZA`@Bd@Db@AfA?`BJp@@rAK|@S`@KVl@bBs@";
}
