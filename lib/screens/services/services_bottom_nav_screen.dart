import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../bus_schedule/bus_map_screen.dart';
import '../traffic/traffic_images_list_screen.dart';
import '../talikhidmat/new_case_screen.dart';
import '../emergency/emergency_screen.dart';
import '../../widgets/sarawakid/login_full_bottom_modal.dart';
import '../bill_payment/bill_payment_screen.dart';
import '../announcement/tourism_news_screen.dart';

import '../../providers/auth_provider.dart';

class ServicesBottomNavScreen extends StatelessWidget {
  static const String routeName = 'servcies-bottom-nav-screen';

  const ServicesBottomNavScreen({super.key});

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
  // Location: no permission, still can access
  void _handleNavigateToTalikhidmat(BuildContext context) async {
    if (Provider.of<AuthProvider>(context, listen: false).isAuth) {
      if (await Permission.location.isGranted) {
        Navigator.of(context).pushNamed(NewCaseScreen.routeName);
      } else {
        Permission.location.request().then(
            (_) => Navigator.of(context).pushNamed(NewCaseScreen.routeName));
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
    await Permission.location.onDeniedCallback(() {
      // Your code
    }).onGrantedCallback(() async {
      Navigator.of(context).pushNamed(EmergencyScreen.routeName);

      // if (numberOfRequestLeft != 0) {
      //   await _globalDialogHelper.showAlertDialog(
      //     context: context,
      //     yesButtonFunc: () {
      //       Navigator.of(context).pop();
      //       Navigator.of(context).pushNamed(EmergencyScreen.routeName);
      //     },
      //     title: "Remaining requests",
      //     message:
      //         "You have $numberOfRequestLeft requests left per day. Are you sure to proceed?",
      //   );
      // } else {
      //   await _globalDialogHelper.showAlertDialogWithSingleButton(
      //     context: context,
      //     title: "No more requests",
      //     message: "There is no more requests. Please try again tomorrow",
      //   );
      // }
    }).onPermanentlyDeniedCallback(() async {
      // The user opted to never again see the permission request dialog for this
      // app. The only way to change the permission's status now is to let the
      // user manually enables it in the system settings.
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
    }).onRestrictedCallback(() {
      // Your code
    }).onLimitedCallback(() {
      // Your code
    }).onProvisionalCallback(() {
      // Your code
    }).request();
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(
                          top: 35.0,
                        ),
                        child: Icon(
                          Icons.feedback_outlined,
                          size: 50.0,
                        ),
                      ),
                      SizedBox(
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
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(
                          top: 35.0,
                        ),
                        child: Icon(
                          Icons.sos_outlined,
                          size: 50.0,
                        ),
                      ),
                      SizedBox(
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
              onTap: () {},
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
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(
                          top: 35.0,
                        ),
                        child: Icon(
                          Icons.subscriptions_outlined,
                          size: 50.0,
                        ),
                      ),
                      SizedBox(
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
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.only(
                          top: 35.0,
                        ),
                        child: const Icon(
                          Icons.traffic_outlined,
                          size: 50.0,
                        ),
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
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(
                          top: 35.0,
                        ),
                        child: Icon(
                          Icons.wallet_outlined,
                          size: 50.0,
                        ),
                      ),
                      SizedBox(
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
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(
                          top: 35.0,
                        ),
                        child: Icon(
                          Icons.luggage_outlined,
                          size: 50.0,
                        ),
                      ),
                      SizedBox(
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
            GestureDetector(
              onTap: () => _handleNavigateToBusSchedule(context),
              child: Card(
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
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(
                          top: 35.0,
                        ),
                        child: Icon(
                          Icons.bus_alert_outlined,
                          size: 50.0,
                        ),
                      ),
                      SizedBox(
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
            )
          ],
        ));
  }
}
