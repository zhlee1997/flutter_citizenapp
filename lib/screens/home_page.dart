import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:permission_handler/permission_handler.dart';

import '../screens/emergency/emergency_screen.dart';
import '../screens/talikhidmat/new_case_screen.dart';
import '../screens/bill_payment/bill_payment_screen.dart';
import '../screens/announcement/citizen_announcements_screen.dart';
import '../widgets/sarawakid/login_full_bottom_modal.dart';
import '../widgets/subscription/subscription_preview_dialog.dart';
import '../widgets/homepage/homepage_citizen_announcement.dart';
import '../widgets/homepage/homepage_tourism_card.dart';
import '../widgets/subscription/subscription_whitelist_bottom_modal.dart';
import '../screens/announcement/tourism_news_screen.dart';
import '../screens/subscription/subscription_choose_screen.dart';
import '../screens/subscription/subscription_result_screen.dart';
import '../screens/traffic/traffic_images_list_screen.dart';
import '../screens/bill_payment/bill_payment_result_screen.dart';

import '../providers/announcement_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/subscription_provider.dart';
import '../services/announcement_services.dart';
import '../services/subscription_services.dart';
import "../models/announcement_model.dart";
import '../models/major_announcement_model.dart';
import "../utils/global_dialog_helper.dart";
import '../utils/major_dialog_helper.dart';
import '../arguments/bill_payment_result_screen_arguments.dart';
import '../arguments/subscription_result_screen_arguments.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // TODO: To query subscription status API (in video splash screen), if isAuth => true
  // TODO: add subscription status in provider
  bool isSubscribed = false;
  bool isSubscription = false;
  String? vipDueDate;

  bool citizenShimmer = false;
  bool tourismShimmer = false;
  List<AnnouncementModel> citizenAnnouncements = [];
  List<AnnouncementModel> tourismAnnouncements = [];
  late int numberOfRequestLeft;

  final AnnouncementServices _announcementServices = AnnouncementServices();
  final GlobalDialogHelper _globalDialogHelper = GlobalDialogHelper();

  // Payment EventChannel and StreamSubscription
  static const EventChannel eventChannel =
      EventChannel("com.sma.citizen_mobile/pay");
  late StreamSubscription _paymentStreamSubscription;

  // receive Object from activity (eventChannel)
  // stream for listening to SPay SDK when payment is done
  void _onData(Object? obj) async {
    try {
      if (isSubscription) {
        // TODO: Temp skip auth checking
        Provider.of<AuthProvider>(context, listen: false)
            .queryUserInfoAfterSubscriptionProvider();
      }
      String encryptedData = obj as String;
      if (encryptedData.isEmpty) {
        GlobalDialogHelper().showAlertDialogWithSingleButton(
          context: context,
          title: "Payment Error",
          message:
              "There was an error while processing your payment. Please contact support or try again later",
        );
        return;
      }
      print("encryptData: $encryptedData");
      Map<String, dynamic> param = {"encryptData": encryptedData};
      var response = await SubscriptionServices().decryptData(param);
      Map<String, dynamic> payResult = {};
      if (response['status'] == '200') {
        payResult = response['data'];
        // Provider.of<InboxProvider>(context, listen: false).refreshCount();
        Navigator.of(context).pop(true);

        // when success, can look for extra data
        // payResult['orderAmt'], payResult['orderDate']
        // Navigate to transaction result page
        jumpPayResult(payResult);
      }
    } catch (e) {
      throw e;
    }
  }

  // receive error Object from activity (eventChannel) when error
  void _onError(Object obj) {}

  // display transaction result screen when a transaction is completed
  void jumpPayResult(Map<String, dynamic> param) {
    print("isSubscription: $isSubscription");
    if (isSubscription) {
      // for subscription, after payment
      Provider.of<SubscriptionProvider>(context, listen: false)
          .changeIsSubscription(false);
      Navigator.of(context).pushNamedAndRemoveUntil(
        SubscriptionResultScreen.routeName,
        (route) => route.isFirst,
        arguments: SubscriptionResultScreenArguments(
          orderAmt: param["orderAmt"],
          orderDate: param["orderDate"],
          orderStatus: param["orderStatus"],
        ),
      ); // is used to keep only the first route (the HomeScreen);
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil(
        BillPaymentResultScreen.routeName,
        (route) => route.isFirst,
        arguments: BillPaymentResultScreenArguments(
          orderAmt: param["orderAmt"],
          orderDate: param["orderDate"],
          orderStatus: param["orderStatus"],
        ),
      ); // is used to keep only the first route (the HomeScreen);
    }
  }

  String returnPackageName(String packageName) {
    switch (packageName) {
      case "option_1":
        return "1-month Premium Subscription";
      case "option_2":
        return "3-month Premium Subscription";
      default:
        return "12-month Premium Subscription";
    }
  }

  Future<void> getSubscriptionPackageOption() async {
    GlobalDialogHelper().buildCircularProgressCenter(context: context);
    try {
      var response =
          await Provider.of<SubscriptionProvider>(context, listen: false)
              .querySubscriptionPackageOptionProvider();
      if (response.isNotEmpty) {
        Navigator.of(context).pop();
        showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: Text("Subscription Info"),
              content: Text(
                  "Your current subscription package is ${returnPackageName(response)}."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      Navigator.of(context).pop();
      print("getSubscriptionPackageOption: ${e.toString()}");
    }
  }

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
      if (mounted) {
        // Check if the widget is still mounted
        setState(() {
          citizenShimmer = false;
          // Cast to AnnouncementModel type to use AnnouncementModel object
          citizenAnnouncements =
              data.map((e) => AnnouncementModel.fromJson(e)).toList();
        });
      }
    }
  }

  Future<void> getTourismAnn() async {
    setState(() {
      tourismShimmer = true;
    });
    var response = await _announcementServices.queryPageList(
      '1',
      pageSize: '4',
      annType: '2',
    );

    if (response['status'] == '200') {
      var data = response['data']['list'] as List;
      if (mounted) {
        // Check if the widget is still mounted
        setState(() {
          tourismShimmer = false;
          tourismAnnouncements =
              data.map((e) => AnnouncementModel.fromJson(e)).toList();
          // for (var element in list) {
          //   if (element.attachmentDtoList.isNotEmpty) {
          //     for (var dto in element.attachmentDtoList) {
          //       if (dto.attFileType == '2') {
          //         tourismAnnouncements.add(element);
          //         break;
          //       }
          //     }
          //   }
          // }
        });
      }
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

  Future<void> _showEmergencyRequestLeftDialog(BuildContext context) async {
    // TODO: Emergency service to check location permission is given
    // TODO: If denied, ask again
    // TODO: If foreverDenied, need navigate to app settings
    await Permission.location.onDeniedCallback(() {
      // Your code
    }).onGrantedCallback(() async {
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

  // first => check subscription enabled (already done)
  // second => check is it whitelisted (if yes, show bottom modal)
  // third => check is it subsrcibed
  void _handleNavigateToSubscription(BuildContext context) async {
    final AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);
    final SubscriptionProvider subscriptionProvider =
        Provider.of<SubscriptionProvider>(context, listen: false);

    if (authProvider.isAuth) {
      GlobalDialogHelper().buildCircularProgressCenter(context: context);
      bool isWhitelisted = await subscriptionProvider
          .queryAndSetIsWhitelisted(authProvider.auth.fullName);
      Navigator.of(context).pop();
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

  void _handleNavigateToTrafficImages(BuildContext context) =>
      Navigator.of(context).pushNamed(TrafficImagesListScreen.routeName);

  void _handleNavigateToPayment(BuildContext context) =>
      Provider.of<AuthProvider>(context, listen: false).isAuth
          ? Navigator.of(context).pushNamed(BillPaymentScreen.routeName)
          : _handleFullScreenLoginBottomModal(context);

  void _handleNavigateToCitizenAnnouncements(BuildContext context) =>
      Navigator.of(context).pushNamed(CitizenAnnouncementsScreen.routeName);

  void _handleNavigateToTourismNews(BuildContext context) =>
      Navigator.of(context).pushNamed(TourismNewsScreen.routeName);

  // display major announcement popup
  Future<void> getMajorAnn() async {
    if (mounted) {
      List<MajorAnnouncementModel> majorAnnList =
          Provider.of<AnnouncementProvider>(context, listen: false)
              .majorAnnouncementList;
      if (majorAnnList.isNotEmpty) {
        await showDialog(
          context: context,
          builder: (_) {
            return BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 10.0,
                sigmaY: 10.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Dialog(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        MajorDialogHelper(
                          majorAnnouncementList: majorAnnList,
                        ),
                      ],
                    ),
                  ),
                  Material(
                    shape: const CircleBorder(),
                    color: Theme.of(context).colorScheme.secondary,
                    child: IconButton(
                      splashRadius: 25.0,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(
                        Icons.close,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timestamp) async {
      getMajorAnn();
    });
    _paymentStreamSubscription = eventChannel.receiveBroadcastStream().listen(
          _onData,
          onError: _onError,
        );
    getCitizenAnn();
    getTourismAnn();
    numberOfRequestLeft = 2;
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    isSubscribed = Provider.of<AuthProvider>(context).auth.vipStatus;
    isSubscription = Provider.of<SubscriptionProvider>(context).isSubscription;
    vipDueDate = Provider.of<AuthProvider>(context).auth.vipDueDate;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    //      if (_paymentStreamSubscription != null) {
    //    _paymentStreamSubscription.cancel();
    //  }
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
            if (isSubscribed)
              GestureDetector(
                onTap: getSubscriptionPackageOption,
                child: Container(
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
                            // TODO: calculate remaining days, and show alert text when lower than 14 days
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
                            const SizedBox(height: 3.0),
                            Text("Due date: ${vipDueDate ?? "---"}"),
                          ],
                        ),
                      )
                    ],
                  ),
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
                    // TODO: check for location permission
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
                  Consumer<SubscriptionProvider>(
                    builder: (BuildContext ctx,
                        SubscriptionProvider subscriptionProvider, child) {
                      return GestureDetector(
                        onTap: () => subscriptionProvider.isSubscriptionEnabled
                            ? _handleNavigateToSubscription(context)
                            : _handleNavigateToTrafficImages(context),
                        child: Card(
                          elevation: 5.0,
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    subscriptionProvider.isSubscriptionEnabled
                                        ? Icon(
                                            Icons.subscriptions,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            size: 30.0,
                                          )
                                        : Icon(
                                            Icons.traffic_outlined,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            size: 30.0,
                                          ),
                                    Text(
                                      subscriptionProvider.isSubscriptionEnabled
                                          ? "Subscription"
                                          : "Traffic images",
                                      style: const TextStyle(
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
                                    subscriptionProvider.isSubscriptionEnabled
                                        ? "Premium member"
                                        : "Live road images",
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
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
