import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../screens/emergency/emergency_screen.dart';
import '../screens/talikhidmat/new_case_screen.dart';
import '../screens/bill_payment/bill_payment_screen.dart';
import '../screens/announcement/citizen_announcements_screen.dart';
import '../widgets/sarawakid/login_full_bottom_modal.dart';
import '../widgets/subscription/subscription_preview_dialog.dart';
import '../widgets/homepage/homepage_citizen_announcement.dart';
import '../widgets/homepage/homepage_tourism_card.dart';
import '../screens/announcement/tourism_news_screen.dart';

import '../providers/auth_provider.dart';
import '../services/announcement_services.dart';
import "../models/announcement_model.dart";
import "../utils/global_dialog_helper.dart";

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
  late int numberOfRequestLeft;

  final AnnouncementServices _announcementServices = AnnouncementServices();
  final GlobalDialogHelper _globalDialogHelper = GlobalDialogHelper();

  Future<void> getCitizenAnn() async {
    setState(() {
      citizenShimmer = true;
      // TODO: to remove
      citizenAnnouncements = [];
    });
    // var response = await _announcementServices.queryPageList(
    //   '1',
    //   pageSize: '6',
    //   annType: '1',
    // );

    // if (response['status'] == '200') {
    //   var data = response['data']['list'] as List;
    //   if (mounted) {
    //     // Check if the widget is still mounted
    //     setState(() {
    //       citizenShimmer = false;
    //       // Cast to AnnouncementModel type to use AnnouncementModel object
    //       citizenAnnouncements =
    //           data.map((e) => AnnouncementModel.fromJson(e)).toList();
    //     });
    //   }
    // }
  }

  Future<void> getTourismAnn() async {
    setState(() {
      tourismShimmer = true;
      // TODO: to remove
      tourismAnnouncements = [];
    });
    // var response = await _announcementServices.queryPageList(
    //   '1',
    //   pageSize: '3',
    //   annType: '2',
    // );

    // if (response['status'] == '200') {
    //   var data = response['data']['list'] as List;
    //   if (mounted) {
    //     // Check if the widget is still mounted
    //     setState(() {
    //       tourismShimmer = false;
    //       var list = data.map((e) => AnnouncementModel.fromJson(e)).toList();
    //       for (var element in list) {
    //         if (element.attachmentDtoList.length > 0) {
    //           for (var dto in element.attachmentDtoList) {
    //             if (dto.attFileType == '2') {
    //               tourismAnnouncements.add(element);
    //               break;
    //             }
    //           }
    //         }
    //       }
    //     });
    //   }
    // }
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

  Future<void> _showEmergencyRequestLeftDialog(BuildContext context) async {
    // TODO: Emergency service to check location permission is given
    // TODO: If denied, ask again
    // TODO: If foreverDenied, need navigate to app settings

    if (numberOfRequestLeft != 0) {
      await _globalDialogHelper.showAlertDialog(
        context: context,
        yesButtonFunc: () {
          Navigator.of(context).pop();
          Navigator.of(context).pushNamed(EmergencyScreen.routeName);
        },
        title: "Remaining requests",
        message:
            "You have $numberOfRequestLeft requests left per day. Are you sure to proceed?",
      );
    } else {
      await _globalDialogHelper.showAlertDialogWithSingleButton(
        context: context,
        title: "No more requests",
        message: "There is no more requests. Please try again tomorrow",
      );
    }
  }

  void _handleNavigateToEmergency(BuildContext context) =>
      Provider.of<AuthProvider>(context, listen: false).isAuth
          ? _showEmergencyRequestLeftDialog(context)
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

  void _handleNavigateToCitizenAnnouncements(BuildContext context) =>
      Provider.of<AuthProvider>(context, listen: false).isAuth
          ? Navigator.of(context)
              .pushNamed(CitizenAnnouncementsScreen.routeName)
          : _handleFullScreenLoginBottomModal(context);

  void _handleNavigateToTourismNews(BuildContext context) =>
      Provider.of<AuthProvider>(context, listen: false).isAuth
          ? Navigator.of(context).pushNamed(TourismNewsScreen.routeName)
          : _handleFullScreenLoginBottomModal(context);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getCitizenAnn();
    getTourismAnn();
    numberOfRequestLeft = 2;
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
            Container(
              margin: const EdgeInsets.only(bottom: 15.0, top: 5.0),
              width: double.infinity,
              height: screenSize.height * 0.125,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(
                  width: 2.0,
                  color: Colors.grey.shade300,
                ),
              ),
              child: Stack(
                children: <Widget>[
                  SizedBox(
                    width: double.infinity,
                    child: Image.asset(
                      "assets/images/pictures/premium/premium_image.png",
                      opacity: const AlwaysStoppedAnimation(0.15),
                      fit: BoxFit.cover,
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerRight,
                    width: double.infinity,
                    child: Image.asset(
                      "assets/images/pictures/premium/premium_image_bg.png",
                      width: screenSize.width * 0.2,
                      height: screenSize.width * 0.2,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Text(
                          "4 days left!",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        Text(
                          "You are subscribed",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .fontSize,
                          ),
                        ),
                        SizedBox(height: 3.0),
                        Text("Premium access: 22 Feb - 21 Mac"),
                      ],
                    ),
                  )
                ],
              ),
            ),
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
                  onTap: () => _handleNavigateToCitizenAnnouncements(context),
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
                  onTap: () => _handleNavigateToTourismNews(context),
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
              child: tourismAnnouncements.isEmpty
                  ? Container(
                      margin: const EdgeInsets.symmetric(
                        vertical: 10.0,
                      ),
                      child: Center(
                        child: Column(
                          children: <Widget>[
                            SvgPicture.asset(
                              "assets/images/svg/no_data.svg",
                              width: screenSize.width * 0.25,
                              height: screenSize.width * 0.25,
                              semanticsLabel: 'No Data Logo',
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            const Text("No news"),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      children: tourismShimmer
                          ? List.generate(
                              3,
                              (index) => Shimmer.fromColors(
                                    baseColor: Colors.white,
                                    highlightColor: Colors.transparent,
                                    child: const HomepageTourismCard(
                                      useDefault: true,
                                      imageUrl: "assets/images/icon/sioc.png",
                                      title: "Loading...",
                                      subtitle: "Loading...",
                                    ),
                                  ))
                          : tourismAnnouncements
                              .map((e) => e.attachmentDtoList.isEmpty
                                  ? HomepageTourismCard(
                                      useDefault: true,
                                      annId: e.annId,
                                      imageUrl: "assets/images/icon/sioc.png",
                                      title: e.annTitleEn,
                                      subtitle: e.annMessageEn,
                                    )
                                  : HomepageTourismCard(
                                      annId: e.annId,
                                      imageUrl:
                                          e.attachmentDtoList[0].attFilePath,
                                      title: e.annTitleEn,
                                      subtitle: e.annMessageEn,
                                    ))
                              .toList(),
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
