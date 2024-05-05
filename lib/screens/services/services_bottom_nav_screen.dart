import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../bus_schedule/bus_map_screen.dart';
import '../traffic/traffic_images_list_screen.dart';
import '../talikhidmat/new_case_screen.dart';
import '../emergency/emergency_screen.dart';
import '../../widgets/sarawakid/login_full_bottom_modal.dart';
import '../bill_payment/bill_payment_screen.dart';
import '../announcement/tourism_news_screen.dart';
import '../../widgets/subscription/subscription_whitelist_bottom_modal.dart';
import '../subscription/subscription_choose_screen.dart';
import '../../widgets/subscription/subscription_preview_dialog.dart';

import '../../providers/auth_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/location_provider.dart';
import '../../utils/global_dialog_helper.dart';

class ServicesBottomNavScreen extends StatefulWidget {
  static const String routeName = 'servcies-bottom-nav-screen';

  const ServicesBottomNavScreen({super.key});

  @override
  State<ServicesBottomNavScreen> createState() =>
      _ServicesBottomNavScreenState();
}

class _ServicesBottomNavScreenState extends State<ServicesBottomNavScreen> {
  bool isSubscribed = false;
  bool isSubscriptionEnabled = false;
  bool _isLoading = false;

  double latitude = 0;
  double longitude = 0;

  void _handleNavigateToBusSchedule(BuildContext context) =>
      Navigator.of(context).pushNamed(BusMapScreen.routeName);

  void _handleNavigateToTrafficImages(BuildContext context) =>
      Navigator.of(context).pushNamed(TrafficImagesListScreen.routeName);

  Future<void> _handleFullScreenLoginBottomModal(BuildContext context) async {
    await showModalBottomSheet(
      barrierColor: Theme.of(context).colorScheme.onInverseSurface,
      useSafeArea: true,
      enableDrag: false,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return const LoginFullBottomModal();
      },
    );
  }

  // Permission: location, camera, gallery
  void _handleNavigateToTalikhidmat(BuildContext context) async {
    if (Provider.of<AuthProvider>(context, listen: false).isAuth) {
      if (await Permission.location.isGranted) {
        Navigator.of(context).pushNamed(
          NewCaseScreen.routeName,
          arguments: {
            "isServices": true,
          },
        );
      } else {
        Permission.location
            .request()
            .then((_) => Navigator.of(context).pushNamed(
                  NewCaseScreen.routeName,
                  arguments: {
                    "isServices": true,
                  },
                ));
      }
    } else {
      _handleFullScreenLoginBottomModal(context);
    }
  }

  Future<void> _showEmergencyRequestLeftDialog(BuildContext context) async {
    // await getNumberofRequestLeft();
    // TODO: Emergency service to check location permission is given
    // TODO: If denied, ask again
    // TODO: If foreverDenied, need navigate to app settings

    PermissionStatus permissionStatus = await Permission.location.request();
    if (permissionStatus.isDenied) {
      Fluttertoast.showToast(msg: 'Location permission is required');
      return;
    } else if (permissionStatus.isPermanentlyDenied) {
      await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Permission Denied'),
              content: const Text(
                  "You have to manually enable the location permission's status in the system settings."),
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
      return;
    }
    await Provider.of<LocationProvider>(context, listen: false)
        .getCurrentLocation()
        .then((position) async {
      if ((latitude != 0 && longitude != 0) ||
          (position!.latitude != 0 && position.longitude != 0)) {
        Navigator.of(context).pushNamed(
          EmergencyScreen.routeName,
          arguments: {
            "isServices": true,
          },
        );
      } else {
        await showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Require GPS to access'),
                content: const Text(
                    "GPS location is not captured by your device somehow. Kindly check the location settings of your device in order to access."),
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
      }
    }).catchError((error, stackTrace) {
      // when location service is disabled
      print("_showEmergencyRequestLeftDialog error: $error");
      Fluttertoast.showToast(msg: error);
    });

    // await Permission.location.onDeniedCallback(() {
    //   // Your code
    // }).onGrantedCallback(() async {
    //   Navigator.of(context).pushNamed(
    //     EmergencyScreen.routeName,
    //     arguments: {
    //       "isServices": true,
    //     },
    //   );
    // }).onPermanentlyDeniedCallback(() async {
    //   // The user opted to never again see the permission request dialog for this
    //   // app. The only way to change the permission's status now is to let the
    //   // user manually enables it in the system settings.
    //   await showDialog<bool>(
    //       context: context,
    //       builder: (BuildContext context) {
    //         return AlertDialog(
    //           title: const Text('Permission Denied'),
    //           content: const Text(
    //               "You have to manually enable the location permission's status in the system settings."),
    //           actions: <Widget>[
    //             TextButton(
    //               child: const Text('Open Settings'),
    //               onPressed: () {
    //                 Navigator.pop(context, false);
    //                 openAppSettings();
    //               },
    //             ),
    //             TextButton(
    //               child: const Text('Cancel'),
    //               onPressed: () {
    //                 Navigator.pop(context, false);
    //               },
    //             ),
    //           ],
    //         );
    //       });
    // }).onRestrictedCallback(() {
    //   // Your code
    // }).onLimitedCallback(() {
    //   // Your code
    // }).onProvisionalCallback(() {
    //   // Your code
    // }).request();
  }

  void _handleNavigateToEmergency(BuildContext context) =>
      Provider.of<AuthProvider>(context, listen: false).isAuth
          ? _showEmergencyRequestLeftDialog(context)
          : _handleFullScreenLoginBottomModal(context);

  void _handleNavigateToPayment(BuildContext context) =>
      Provider.of<AuthProvider>(context, listen: false).isAuth
          ? Navigator.of(context).pushNamed(BillPaymentScreen.routeName)
          : _handleFullScreenLoginBottomModal(context);

  void _handleNavigateToTourismNews(BuildContext context) =>
      Navigator.of(context).pushNamed(TourismNewsScreen.routeName);

  // first => check subscription enabled (already done)
  void _handleNavigateToSubscription(BuildContext context) async {
    final AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);
    final SubscriptionProvider subscriptionProvider =
        Provider.of<SubscriptionProvider>(context, listen: false);

    if (authProvider.isAuth && authProvider.auth != null) {
      GlobalDialogHelper().buildCircularProgressCenter(context: context);
      bool isWhitelisted = await subscriptionProvider
          .queryAndSetIsWhitelisted(authProvider.auth!.sId);
      bool isSubscriptionEnabled =
          await subscriptionProvider.queryAndSetIsSubscriptionEnabled();
      Navigator.of(context).pop();
      if (!isSubscriptionEnabled) {
        Fluttertoast.showToast(msg: "Subscription is disabled");
        return;
      }
      if (isWhitelisted) {
        // show bottom modal
        _handleSubscriptionWhitelistBottomModal(context);
      } else {
        if (isSubscribed) {
          Navigator.of(context).pushNamed(SubscriptionChooseScreen.routeName);
        } else {
          _showSubscriptionIntroDialog(context);
        }
      }
    } else {
      _handleFullScreenLoginBottomModal(context);
    }
  }

  Future<void> _handleSubscriptionWhitelistBottomModal(
      BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SubscriptionWhitelistBottomModal(
          handleNavigateToChooseScreen: () => Navigator.of(context)
              .pushNamed(SubscriptionChooseScreen.routeName),
        );
      },
    );
  }

  Future<void> _showSubscriptionIntroDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return const SubscriptionPreviewDialog();
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
        await Provider.of<SubscriptionProvider>(context, listen: false)
            .queryAndSetIsSubscriptionEnabled();
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    if (Provider.of<AuthProvider>(context).auth != null) {
      isSubscribed = Provider.of<AuthProvider>(context).auth!.vipStatus;
    }
    isSubscriptionEnabled =
        Provider.of<SubscriptionProvider>(context).isSubscriptionEnabled;
    latitude = Provider.of<LocationProvider>(context).latitude;
    longitude = Provider.of<LocationProvider>(context).longitude;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(10.0),
          child: GridView(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 5.0,
              mainAxisSpacing: 5.0,
              childAspectRatio: 0.7 / 1,
            ),
            children: <Widget>[
              GestureDetector(
                onTap: () => _handleNavigateToTalikhidmat(context),
                child: Card(
                  elevation: 5.0,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      // image: DecorationImage(
                      //   image: AssetImage(
                      //       "assets/images/pictures/talikhidmat_image.jpg"),
                      //   fit: BoxFit.cover,
                      //   opacity: 0.3,
                      // ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Icon(
                          Icons.feedback_outlined,
                          size: 50.0,
                          color: Colors.deepPurple,
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          "Talikhidmat",
                          style: Theme.of(context).textTheme.bodyMedium,
                        )
                      ],
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _handleNavigateToEmergency(context),
                child: Card(
                  color: Color.fromARGB(255, 255, 252, 221),
                  elevation: 5.0,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      // image: DecorationImage(
                      //   image: AssetImage("assets/images/pictures/sos_image.jpg"),
                      //   fit: BoxFit.cover,
                      //   opacity: 0.15,
                      // ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Icon(
                          Icons.sos_outlined,
                          size: 50.0,
                          color: Colors.orange,
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          "Emergency Button",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        )
                      ],
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _handleNavigateToBusSchedule(context),
                child: Card(
                  color: Color.fromARGB(255, 227, 255, 235),
                  elevation: 5.0,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      // image: DecorationImage(
                      //   image: AssetImage("assets/images/pictures/bus_image.jpg"),
                      //   fit: BoxFit.cover,
                      //   opacity: 0.2,
                      // ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Icon(
                          Icons.bus_alert_outlined,
                          size: 50.0,
                          color: Colors.green,
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          "Bus Schedule",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        )
                      ],
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _handleNavigateToTrafficImages(context),
                child: Card(
                  elevation: 5.0,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      // image: const DecorationImage(
                      //   image: AssetImage(
                      //       "assets/images/pictures/traffic_image.jpg"),
                      //   fit: BoxFit.cover,
                      //   opacity: 0.2,
                      // ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Icon(
                          Icons.traffic_outlined,
                          size: 50.0,
                          color: Colors.deepPurple,
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          "Traffic Images",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        )
                      ],
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _handleNavigateToPayment(context),
                child: Card(
                  color: Color.fromARGB(255, 255, 252, 221),
                  elevation: 5.0,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      // image: DecorationImage(
                      //   image: AssetImage(
                      //       "assets/images/pictures/payment_image.jpg"),
                      //   fit: BoxFit.cover,
                      //   opacity: 0.2,
                      // ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Icon(
                          Icons.receipt_long_outlined,
                          size: 50.0,
                          color: Colors.orange,
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          "Bill Payment",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        )
                      ],
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _handleNavigateToTourismNews(context),
                child: Card(
                  color: Color.fromARGB(255, 227, 255, 235),
                  elevation: 5.0,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      // image: DecorationImage(
                      //   image: AssetImage(
                      //       "assets/images/pictures/tourism_image.jpg"),
                      //   fit: BoxFit.cover,
                      //   opacity: 0.3,
                      // ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Icon(
                          Icons.luggage_outlined,
                          size: 50.0,
                          color: Colors.green,
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          "Tourism News",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        )
                      ],
                    ),
                  ),
                ),
              ),
              if (isSubscriptionEnabled)
                GestureDetector(
                  onTap: () => _handleNavigateToSubscription(context),
                  child: Card(
                    elevation: 5.0,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        // image: DecorationImage(
                        //   image: AssetImage(
                        //       "assets/images/pictures/subscription_image.jpg"),
                        //   fit: BoxFit.cover,
                        //   opacity: 0.2,
                        // ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Icon(
                            Icons.subscriptions,
                            size: 50.0,
                            color: Colors.deepPurple,
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          Text(
                            "Premium Subscription",
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (_isLoading)
          const Opacity(
            opacity: 0.25,
            child: ModalBarrier(dismissible: false, color: Colors.black),
          ),
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}
