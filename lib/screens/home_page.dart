import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/emergency/emergency_screen.dart';
import '../screens/talikhidmat/new_case_screen.dart';
import '../screens/bill_payment/bill_payment_screen.dart';
import '../widgets/sarawakid/login_full_bottom_modal.dart';
import '../widgets/subscription/subscription_preview_dialog.dart';
import '../widgets/homepage/homepage_citizen_announcement.dart';

import '../providers/auth_provider.dart';
import '../services/announcement_services.dart';
import "../models/announcement_model.dart";

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool citizenShimmer = false;
  bool tourismShimmer = false;
  List<AnnouncementModel> citizenAnnouncements = [];
  List<AnnouncementModel> tourismAnnouncements = [];

  final AnnouncementServices _announcementServices = AnnouncementServices();

  Future<void> getCitizenAnn() async {
    setState(() {
      citizenShimmer = true;
    });
    var response = await _announcementServices.queryPageList(
      '1',
      pageSize: '6',
      annType: '1',
    );

    if (response['status'] == '200') {
      var data = response['data']['list'] as List;
      setState(() {
        citizenShimmer = false;
        // Cast to AnnouncementModel type to use AnnouncementModel object
        citizenAnnouncements =
            data.map((e) => AnnouncementModel.fromJson(e)).toList();
      });
    }
  }

  Future<void> getTourismAnn() async {
    var response = await _announcementServices.queryPageList(
      '1',
      pageSize: '3',
      annType: '2',
    );

    if (response['status'] == '200') {
      var data = response['data']['list'] as List;
      setState(() {
        tourismShimmer = false;
        var list = data.map((e) => AnnouncementModel.fromJson(e)).toList();
        for (var element in list) {
          if (element.attachmentDtoList.length > 0) {
            for (var dto in element.attachmentDtoList) {
              if (dto.attFileType == '2') {
                tourismAnnouncements.add(element);
                break;
              }
            }
          }
        }
      });
      print("getTourismAnn: $tourismAnnouncements");
      print(tourismAnnouncements.length);
    }
  }

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

  Future<void> _showSubscriptionIntroDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return const SubscriptionPreviewDialog();
      },
    );
  }

  void _handleNavigateToEmergency(BuildContext context) =>
      Provider.of<AuthProvider>(context, listen: false).isAuth
          ? Navigator.of(context).pushNamed(EmergencyScreen.routeName)
          : _handleFullScreenLoginBottomModal(context);

  void _handleNavigateToTalikhidmat(BuildContext context) =>
      Provider.of<AuthProvider>(context, listen: false).isAuth
          ? Navigator.of(context).pushNamed(NewCaseScreen.routeName)
          : _handleFullScreenLoginBottomModal(context);

  void _handleNavigateToSubscription(BuildContext context) =>
      Provider.of<AuthProvider>(context, listen: false).isAuth
          ? _showSubscriptionIntroDialog(context)
          : _handleFullScreenLoginBottomModal(context);

  void _handleNavigateToPayment(BuildContext context) =>
      Provider.of<AuthProvider>(context, listen: false).isAuth
          ? Navigator.of(context).pushNamed(BillPaymentScreen.routeName)
          : _handleFullScreenLoginBottomModal(context);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getCitizenAnn();
    getTourismAnn();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 15.0,
          vertical: 10.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Quick Services',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              'Shortcut to frequently used function',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: Theme.of(context).textTheme.labelLarge!.fontSize,
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(
                vertical: 20.0,
              ),
              child: GridView(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 1.6 / 1,
                ),
                children: <Widget>[
                  GestureDetector(
                    onTap: () => _handleNavigateToTalikhidmat(context),
                    child: Card(
                      elevation: 5.0,
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.feedback_outlined,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 30.0,
                                ),
                                const Text(
                                  "Talikhidmat",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            Container(
                              margin: const EdgeInsets.only(
                                left: 10.0,
                              ),
                              child: Text(
                                "Submit a report",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
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
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.sos_outlined,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 30.0,
                                ),
                                const Text(
                                  "Emergency",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            Container(
                              margin: const EdgeInsets.only(
                                left: 10.0,
                              ),
                              child: Text(
                                "Rescue request",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _handleNavigateToSubscription(context),
                    child: Card(
                      elevation: 5.0,
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.subscriptions,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 30.0,
                                ),
                                const Text(
                                  "Subscription",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            Container(
                              margin: const EdgeInsets.only(
                                left: 10.0,
                              ),
                              child: Text(
                                "Premium member",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
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
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.receipt_long_outlined,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 30.0,
                                ),
                                const Text(
                                  "Bill Payment",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            Container(
                              margin: const EdgeInsets.only(
                                left: 10.0,
                              ),
                              child: Text(
                                "Billing and taxes",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Citizen Announcements',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                GestureDetector(
                  onTap: () {
                    print("view all pressed");
                  },
                  child: Text(
                    'VIEW ALL',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize:
                          Theme.of(context).textTheme.labelSmall!.fontSize,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              'Get updated on the latest announcements',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: Theme.of(context).textTheme.labelLarge!.fontSize,
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(
                vertical: 20.0,
              ),
              child: HomepageCitizenAnnouncement(
                citizenShimmer: citizenShimmer,
                citizenAnnouncements: citizenAnnouncements,
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tourism News',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                GestureDetector(
                  onTap: () {
                    print("view all pressed");
                  },
                  child: Text(
                    'VIEW ALL',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize:
                          Theme.of(context).textTheme.labelSmall!.fontSize,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              'Checkout the tourist updates',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: Theme.of(context).textTheme.labelLarge!.fontSize,
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(
                vertical: 20.0,
              ),
              child: Column(
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(
                      bottom: 10.0,
                    ),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(10.0), // Set the border radius
                      border: Border.all(
                        color: Colors.grey, // Set the border color
                        width: 0.5, // Set the border width
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        Flexible(
                          flex: 1,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10.0),
                              bottomLeft: Radius.circular(10.0),
                            ),
                            child: Image.asset(
                              "assets/images/icon/sioc.png",
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const Text(
                                  "Unifi TV",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(
                                  height: 5.0,
                                ),
                                SizedBox(
                                  width: screenSize.width * 0.67,
                                  child: Text(
                                    "Subcribers get to enjoy 3 streaming apps on us",
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style:
                                        Theme.of(context).textTheme.labelSmall,
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                      bottom: 10.0,
                    ),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(10.0), // Set the border radius
                      border: Border.all(
                        color: Colors.grey, // Set the border color
                        width: 0.5, // Set the border width
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        Flexible(
                          flex: 1,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10.0),
                              bottomLeft: Radius.circular(10.0),
                            ),
                            child: Image.asset(
                              "assets/images/icon/sioc.png",
                              // width: 70,
                              // height: 90,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const Text(
                                  "Unifi TV",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(
                                  height: 5.0,
                                ),
                                SizedBox(
                                  width: screenSize.width * 0.67,
                                  child: Text(
                                    "Subcribers get to enjoy 3 streaming apps on us",
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style:
                                        Theme.of(context).textTheme.labelSmall,
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                      bottom: 10.0,
                    ),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(10.0), // Set the border radius
                      border: Border.all(
                        color: Colors.grey, // Set the border color
                        width: 0.5, // Set the border width
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        Flexible(
                          flex: 1,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10.0),
                              bottomLeft: Radius.circular(10.0),
                            ),
                            child: Image.asset(
                              "assets/images/icon/sioc.png",
                              // width: 70,
                              // height: 90,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const Text(
                                  "Unifi TV",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(
                                  height: 5.0,
                                ),
                                SizedBox(
                                  width: screenSize.width * 0.67,
                                  child: Text(
                                    "Subcribers get to enjoy 3 streaming apps on us",
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style:
                                        Theme.of(context).textTheme.labelSmall,
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(
                bottom: 20.0,
              ),
              alignment: Alignment.center,
              child: const Text(
                "That's all for now",
              ),
            )
          ],
        ),
      ),
    );
  }
}
