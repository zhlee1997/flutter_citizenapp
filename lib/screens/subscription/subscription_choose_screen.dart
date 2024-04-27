import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../screens/subscription/subscription_map_screen.dart';
import '../../screens/subscription/subscription_list_screen.dart';
import '../../providers/camera_subscription_provider.dart';
import '../../providers/subscription_provider.dart';

class SubscriptionChooseScreen extends StatefulWidget {
  static const String routeName = "subscription-choose-screen";

  const SubscriptionChooseScreen({super.key});

  @override
  State<SubscriptionChooseScreen> createState() =>
      _SubscriptionChooseScreenState();
}

class _SubscriptionChooseScreenState extends State<SubscriptionChooseScreen> {
  late SnackBar _snackBar;

  void _handleNavigateToSubscriptionMapScreen(BuildContext context) =>
      Navigator.of(context).pushNamed(SubscriptionMapScreen.routeName);

  void _handleNavigateToSubscriptionListScreen(BuildContext context) =>
      Navigator.of(context).pushNamed(SubscriptionListScreen.routeName);

  Future<void> getSubscriptionDevicesList(String subscribeId) async {
    bool success =
        await Provider.of<CameraSubscriptionProvider>(context, listen: false)
            .getDevicesListByPackageIdProvider(subscribeId);
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(_snackBar);
    }
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    final subscribeId = Provider.of<SubscriptionProvider>(context).subscribeId;
    getSubscriptionDevicesList(subscribeId);
    _snackBar = SnackBar(
      content: const Text('Get CCTV List unsuccessful. Try again'),
      action: SnackBarAction(
        label: "Retry",
        onPressed: () {
          getSubscriptionDevicesList(subscribeId);
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Choose Services"),
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: screenSize.height * 0.025,
            ),
            GestureDetector(
              onTap: () {
                _handleNavigateToSubscriptionMapScreen(context);
              },
              child: Container(
                height: screenSize.height * 0.225,
                width: screenSize.width * 0.9,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: Colors.black26),
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4.0,
                                horizontal: 8.0,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.secondary,
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(15.0)),
                              ),
                              child: Text(
                                "MAP",
                                style: TextStyle(
                                  fontSize: 10.0,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(
                                top: 10.0,
                                bottom: 25.0,
                              ),
                              child: const Text(
                                "Access the service using map view",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text("Take me there"),
                                SizedBox(
                                  width: 5.0,
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 12.0,
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        alignment: Alignment.center,
                        child: Image.asset(
                          "assets/images/pictures/subscription/cctv_map.jpeg",
                          width: screenSize.width * 0.35,
                          height: screenSize.width * 0.35,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(
              height: screenSize.height * 0.03,
            ),
            GestureDetector(
              onTap: () {
                _handleNavigateToSubscriptionListScreen(context);
              },
              child: Container(
                height: screenSize.height * 0.225,
                width: screenSize.width * 0.9,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: Colors.black26),
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4.0,
                                horizontal: 8.0,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.secondary,
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(15.0)),
                              ),
                              child: Text(
                                "LIST",
                                style: TextStyle(
                                  fontSize: 10.0,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(
                                top: 10.0,
                                bottom: 25.0,
                              ),
                              child: const Text(
                                "Access the service using list view",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text("Take me there"),
                                SizedBox(
                                  width: 5.0,
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 12.0,
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        alignment: Alignment.center,
                        child: Image.asset(
                          "assets/images/pictures/subscription/cctv_list.jpeg",
                          width: screenSize.width * 0.3,
                          height: screenSize.width * 0.3,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
