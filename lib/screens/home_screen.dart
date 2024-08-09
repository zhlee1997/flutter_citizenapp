import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../providers/auth_provider.dart';
import '../providers/inbox_provider.dart';
import '../providers/subscription_provider.dart';
import '../providers/announcement_provider.dart';
import '../providers/location_provider.dart';
import '../services/subscription_services.dart';

import '../screens/home_page.dart';
import '../screens/notifications/notifications_bottom_nav_screen.dart';
import '../screens/profile/profile_bottom_nav_screen.dart';
import '../screens/profile/profile_details_screen.dart';
import '../screens/services/services_bottom_nav_screen.dart';
import '../screens/subscription/subscription_result_screen.dart';
import '../screens/bill_payment/bill_payment_result_screen.dart';
import '../screens/bill_payment/bill_payment_due_screen.dart';
import '../screens/subscription/subscription_due_screen.dart';
import '../widgets/sarawakid/login_full_bottom_modal.dart';
import "../utils/global_dialog_helper.dart";
import '../utils/major_dialog_helper.dart';
import '../utils/app_localization.dart';
import '../arguments/bill_payment_result_screen_arguments.dart';
import '../arguments/subscription_result_screen_arguments.dart';
import '../models/major_announcement_model.dart';

class HomeScreen extends StatefulWidget {
  final int currentIndex;
  static const routeName = 'home-page-screen';

  const HomeScreen({required this.currentIndex, super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentPageIndex = 0;
  bool isNotificationsSelected = true;
  bool isSubscription = false;

  /// Creating a navigation key to control tab bar navigation
  final _navigationKey = GlobalKey();

  List<Widget> _screens = [];

  final GlobalDialogHelper _globalDialogHelper = GlobalDialogHelper();

  // Payment EventChannel and StreamSubscription
  static const EventChannel eventChannel =
      EventChannel("com.sma.citizen_mobile/pay");
  late StreamSubscription _paymentStreamSubscription;

  // receive Object from activity (eventChannel)
  // stream for listening to SPay SDK when payment is done
  void _onData(Object? obj) async {
    try {
      GlobalDialogHelper().buildCircularProgressWithTextCenter(
        context: context,
        message: "Fetching data",
      );
      if (isSubscription) {
        // TODO: Temp skip auth checking
        await Provider.of<AuthProvider>(context, listen: false)
            .queryUserInfoAfterSubscriptionProvider();
      }
      // Receive obj (encryptedData) from SPay Global when redirect back to app
      String encryptedData = obj as String;

      /// if encryptedData is not empty
      /// call decryptData() to get payment details
      /// if success, navigate to Successful Payment Screen
      ///
      /// else, navigate to Due Payment Screen
      if (encryptedData.isNotEmpty ||
          !encryptedData.contains("Order Acquisition Fail")) {
        print("encryptData: $encryptedData");
        Map<String, dynamic> param = {"encryptData": encryptedData};
        var response = await SubscriptionServices().decryptData(param);
        Map<String, dynamic> payResult = {};
        if (response['status'] == '200') {
          payResult = response['data'];
          Navigator.of(context).pop(true);

          // when success, can look for extra data
          // payResult['orderAmt'], payResult['orderDate']
          // Navigate to transaction result page
          jumpPayResult(payResult);
        }
      } else {
        // encryptedData is empty
        // encryptedData contains "Order Acquisition Fail"
        Navigator.of(context).pop(true);
        if (isSubscription) {
          Navigator.of(context).pushNamed(SubscriptionDueScreen.routeName);
          return;
        }
        Navigator.of(context).pushNamed(BillPaymentDueScreen.routeName);
        return;
      }
    } catch (e) {
      // decryptData error: Service not found!
      print("_onData error: ${e.toString()}");
      Navigator.of(context).pop();
      if (isSubscription) {
        Navigator.of(context).pushNamed(SubscriptionDueScreen.routeName);
        return;
      }
      Navigator.of(context).pushNamed(BillPaymentDueScreen.routeName);
      return;
    }
  }

  // receive error Object from activity (eventChannel) when error
  void _onError(Object obj) {
    // TODO: Navigate to payment fail screen
  }

  // display transaction result screen when a transaction is completed
  void jumpPayResult(Map<String, dynamic> param) {
    if (isSubscription) {
      // for subscription, after payment
      Provider.of<SubscriptionProvider>(context, listen: false)
          .changeIsSubscription(false);
      Navigator.of(context).pushNamed(
        SubscriptionResultScreen.routeName,
        arguments: SubscriptionResultScreenArguments(
          orderAmt: param["orderAmt"],
          orderDate: param["orderDate"],
          orderStatus: param["orderStatus"],
        ),
      ); // is used to keep only the first route (the HomeScreen);
    } else {
      Navigator.of(context).pushNamed(
        BillPaymentResultScreen.routeName,
        arguments: BillPaymentResultScreenArguments(
          orderAmt: param["orderAmt"],
          orderDate: param["orderDate"],
          orderStatus: param["orderStatus"],
        ),
      ); // is used to keep only the first route (the HomeScreen);
    }
  }

  void setNotificationsState(bool isSelected) {
    setState(() {
      isNotificationsSelected = isSelected;
    });
  }

  Future<void> _handleFullScreenLoginBottomModal() async {
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

  Future<void> showDeleteAllBottomModal(Size screenSize) async {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Delete all notifications?",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(
                height: 10.0,
              ),
              Text(
                "You can't undo this later.",
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: Theme.of(context).textTheme.titleMedium!.fontSize,
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              SizedBox(
                width: screenSize.width * 0.9,
                child: ElevatedButton(
                  onPressed: () {},
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    child: Text(
                      "Delete All",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              SizedBox(
                width: screenSize.width * 0.9,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    child: Text(
                      "Keep Them",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

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
        ).whenComplete(() async {
          // save the annIds into shared pref
          List<String> annIdList = majorAnnList.map((e) => e.sid).toList();
          await Provider.of<AnnouncementProvider>(context, listen: false)
              .setMajorLocalStorage(annIdList);
        });
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _screens = [
      const HomePage(),
      const ServicesBottomNavScreen(),
      NotificationsBottomNavScreen(
        setNotificationsState: setNotificationsState,
      ),
      const ProfileBottomNavScreen(),
    ];
    _currentPageIndex = widget.currentIndex;
    WidgetsBinding.instance.addPostFrameCallback((timestamp) async {
      await getMajorAnn();
      try {
        await Provider.of<LocationProvider>(context, listen: false)
            .getCurrentLocation();
      } catch (e) {
        print("initState error: ${e.toString()}");
      }
    });
    _paymentStreamSubscription = eventChannel.receiveBroadcastStream().listen(
          _onData,
          onError: _onError,
        );
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    isSubscription = Provider.of<SubscriptionProvider>(context).isSubscription;
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

    return Scaffold(
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          labelTextStyle: MaterialStateProperty.resolveWith<TextStyle>(
            (Set<MaterialState> states) =>
                states.contains(MaterialState.selected)
                    ? TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : TextStyle(
                        color: Colors.grey[600],
                      ),
          ),
        ),
        child: NavigationBar(
          onDestinationSelected: (int index) {
            if (index == _currentPageIndex) {
              return;
            }

            // Check for HomePage (Page 1).
            if (index == 0) {
              _screens.removeAt(0);
              // Pass a UniqueKey as key to force the widget lifecycle to start over.
              _screens.insert(
                0,
                HomePage(
                  key: UniqueKey(),
                ),
              );
            }

            // Check for ServicessBottomNavScreen (Page 2).
            if (index == 1) {
              _screens.removeAt(1);
              // Pass a UniqueKey as key to force the widget lifecycle to start over.
              _screens.insert(
                1,
                ServicesBottomNavScreen(
                  key: UniqueKey(),
                ),
              );
            }

            // Check for NotificationsBottomNavScreen (Page 3).
            if (index == 2) {
              _screens.removeAt(2);
              // Pass a UniqueKey as key to force the widget lifecycle to start over.
              _screens.insert(
                2,
                NotificationsBottomNavScreen(
                  key: UniqueKey(),
                  setNotificationsState: setNotificationsState,
                ),
              );
            }

            setState(() {
              _currentPageIndex = index;
            });
          },
          selectedIndex: _currentPageIndex,
          key: _navigationKey,
          destinations: <Widget>[
            NavigationDestination(
              selectedIcon: Icon(
                Icons.home,
                color: Theme.of(context).colorScheme.primary,
              ),
              icon: Icon(
                Icons.home_outlined,
                color: Colors.grey[600],
              ),
              label: AppLocalization.of(context)!.translate('home')!,
            ),
            NavigationDestination(
              selectedIcon: Icon(
                Icons.apps,
                color: Theme.of(context).colorScheme.primary,
              ),
              icon: Icon(
                Icons.apps_outlined,
                color: Colors.grey[600],
              ),
              label: AppLocalization.of(context)!.translate('services')!,
            ),
            NavigationDestination(
              selectedIcon: Badge(
                isLabelVisible:
                    Provider.of<InboxProvider>(context).unreadMessageCount != 0,
                child: Icon(
                  Icons.notifications,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              icon: Badge(
                  isLabelVisible:
                      Provider.of<InboxProvider>(context).unreadMessageCount !=
                          0,
                  child: Icon(
                    Icons.notifications_outlined,
                    color: Colors.grey[600],
                  )),
              label: AppLocalization.of(context)!.translate('notifications')!,
            ),
            NavigationDestination(
              selectedIcon: Icon(
                Icons.account_circle,
                color: Theme.of(context).colorScheme.primary,
              ),
              icon: Icon(
                Icons.account_circle_outlined,
                color: Colors.grey[600],
              ),
              label: AppLocalization.of(context)!.translate('profile')!,
            ),
          ],
        ),
      ),
      appBar: _handleAppBar(screenSize, isNotificationsSelected),
      body: IndexedStack(
        index: _currentPageIndex,
        children: _screens,
      ),
    );
  }

  PreferredSizeWidget _handleAppBar(
    Size screenSize,
    bool isNotificationsSelected,
  ) {
    void handleNavigateToProfileDetailsScreen() =>
        Navigator.of(context).pushNamed(ProfileDetailsScreen.routeName);

    String getGreeting() {
      var hour = DateTime.now().hour;
      if (hour >= 5 && hour < 12) {
        return AppLocalization.of(context)!.translate('good_morning')!;
      } else if (hour >= 12 && hour < 17) {
        return AppLocalization.of(context)!.translate('good_afternoon')!;
      } else {
        return AppLocalization.of(context)!.translate('good_evening')!;
      }
    }

    switch (_currentPageIndex) {
      case 0:
        return AppBar(
          backgroundColor: Theme.of(context).colorScheme.background,
          leading: // User Avatar Icon
              Container(
            margin: const EdgeInsets.only(
              left: 12.0,
              top: 8.0,
              bottom: 8.0,
            ),
            child: Image.asset(
              "assets/images/icon/sarawak_logo.png",
              width: 50,
              height: 50,
              fit: BoxFit.contain,
            ),
          ),
          title: Consumer<AuthProvider>(
            builder: (_, AuthProvider authProvider, __) {
              final String fullName =
                  authProvider.auth != null ? authProvider.auth!.fullName : "";
              final String firstName = fullName.split(" ")[0];
              final String greetings = getGreeting();

              return GestureDetector(
                onTap: authProvider.isAuth
                    ? null
                    : () => _handleFullScreenLoginBottomModal(),
                child: Text(
                  authProvider.isAuth
                      ? "$greetings, $firstName"
                      : AppLocalization.of(context)!
                          .translate('login_now_to_citizenApp')!,
                  style: TextStyle(
                    overflow: TextOverflow.ellipsis,
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 16.0,
                  ),
                ),
              );
            },
          ),
          actions: Provider.of<AuthProvider>(context).isAuth
              ? null
              : [
                  Container(
                    // Set the background color of the IconButton
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .inversePrimary
                          .withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    margin: const EdgeInsets.all(8.0),
                    child: IconButton(
                      color: Theme.of(context).colorScheme.primary,
                      onPressed: () => _handleFullScreenLoginBottomModal(),
                      icon: const Icon(
                        Icons.login,
                        size: 20.0,
                      ),
                    ),
                  )
                ],
        );
      case 1:
        return AppBar(
          title: Text(AppLocalization.of(context)!.translate('services')!),
        );
      case 2:
        return AppBar(
          title: Text(AppLocalization.of(context)!.translate('notifications')!),
          // actions: isNotificationsSelected
          //     ? [
          //         IconButton(
          //           onPressed: () async {
          //             await showDeleteAllBottomModal(screenSize);
          //           },
          //           icon: Icon(Icons.delete_outline),
          //         )
          //       ]
          //     : null,
        );
      case 3:
        return Provider.of<AuthProvider>(context).isAuth
            ? _appBar(
                screenSize: screenSize,
                height: AppBar().preferredSize.height,
                handleNavigateToProfileDetailsScreen: () =>
                    handleNavigateToProfileDetailsScreen(),
              )
            : AppBar(
                title: Text(AppLocalization.of(context)!.translate('profile')!),
              );
      default:
        return AppBar();
    }
  }

  _appBar({
    required Size screenSize,
    required double height,
    required void Function() handleNavigateToProfileDetailsScreen,
  }) =>
      PreferredSize(
        preferredSize: Size.fromHeight(MediaQuery.of(context).viewPadding.top +
            MediaQuery.of(context).viewPadding.top * 0.25 +
            height +
            MediaQuery.of(context).size.width * 0.13),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: const FractionalOffset(0.0, 0.0),
              end: const FractionalOffset(1.0, 1.0),
              colors: <Color>[
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
              stops: <double>[0.0, 1.0],
              tileMode: TileMode.clamp,
            ),
            borderRadius: BorderRadius.vertical(
              bottom: Radius.elliptical(
                MediaQuery.of(context).size.width,
                50.0,
              ),
            ),
          ),
          child: Consumer<AuthProvider>(
            builder: (_, AuthProvider authProvider, __) {
              return Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).viewPadding.top +
                          MediaQuery.of(context).viewPadding.top * 0.5,
                      bottom: 8.0,
                    ),
                    child: Text(
                      AppLocalization.of(context)!.translate('profile')!,
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: authProvider.auth != null &&
                                authProvider.auth!.profileImage != null &&
                                authProvider.auth!.profileImage!.isNotEmpty
                            ? CachedNetworkImage(
                                fit: BoxFit.cover,
                                width: MediaQuery.of(context).size.width * 0.13,
                                height:
                                    MediaQuery.of(context).size.width * 0.13,
                                placeholder:
                                    (BuildContext context, String url) =>
                                        Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                  padding: const EdgeInsets.all(8.0),
                                  child:
                                      const CircularProgressIndicator.adaptive(
                                    strokeWidth: 2.0,
                                  ),
                                ),
                                imageUrl: authProvider.auth != null
                                    ? authProvider.auth!.profileImage!
                                    : "",
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  child: const Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                  ),
                                ),
                              )
                            : CircleAvatar(
                                radius: 25.0,
                                child: Lottie.asset(
                                  'assets/animations/lottie_profile.json',
                                  width:
                                      MediaQuery.of(context).size.width * 0.11,
                                  height:
                                      MediaQuery.of(context).size.width * 0.11,
                                  fit: BoxFit.fill,
                                ),
                              ),
                      ),
                      SizedBox(
                        width: 5.0,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          // mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              authProvider.auth != null
                                  ? authProvider.auth!.fullName
                                  : "",
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              authProvider.auth != null
                                  ? authProvider.auth!.email!
                                  : "",
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    color: Colors.white,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit_square),
                        onPressed: handleNavigateToProfileDetailsScreen,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      );

  // PreferredSize(
  //   preferredSize: Size(
  //     MediaQuery.of(context).size.width,
  //     // TODO: Adjust appbar height
  //     height + screenSize.height * 0.22,
  //   ),
  //   child: Stack(
  //     children: <Widget>[
  //       Container(
  //         // Background
  //         color: Theme.of(context).primaryColor,
  //         // TODO: Adjust appbar height
  //         height: height + screenSize.height * 0.13,
  //         width: screenSize.width,
  //         child: Container(
  //           margin: EdgeInsets.only(top: screenSize.height * 0.06),
  //           alignment: Alignment.topCenter,
  //           child: const Text(
  //             "Profile",
  //             style: TextStyle(
  //               fontSize: 20.0,
  //               fontWeight: FontWeight.w400,
  //               color: Colors.white,
  //             ),
  //           ),
  //         ),
  //       ),

  //       Container(), // Required some widget in between to float AppBar

  //       Positioned(
  //         // To take AppBar Size only
  //         top: 100.0,
  //         left: 20.0,
  //         right: 20.0,
  //         child: AppBar(
  //           // TODO: Adjust appbar height
  //           toolbarHeight: screenSize.height * 0.17,
  //           shape: Border.all(
  //             width: 0.5,
  //             color: Colors.grey,
  //           ),
  //           scrolledUnderElevation: 0.0,
  //           backgroundColor: Colors.white,
  //           primary: false,
  //           title: Column(
  //             children: <Widget>[
  //               Consumer<AuthProvider>(
  //                 builder: (_, AuthProvider authProvider, __) {
  //                   return Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                     children: <Widget>[
  //                       Container(
  //                         padding: EdgeInsets.only(left: 10.0),
  //                         child: Column(
  //                           crossAxisAlignment: CrossAxisAlignment.start,
  //                           children: <Widget>[
  //                             Text(
  //                               authProvider.auth != null
  //                                   ? authProvider.auth!.fullName
  //                                   : "",
  //                               style:
  //                                   Theme.of(context).textTheme.bodyLarge,
  //                               overflow: TextOverflow.ellipsis,
  //                             ),
  //                             Text(
  //                               authProvider.auth != null
  //                                   ? authProvider.auth!.mobile!
  //                                   : "",
  //                               style: TextStyle(
  //                                 color: Colors.black54,
  //                                 fontSize: Theme.of(context)
  //                                     .textTheme
  //                                     .bodyMedium!
  //                                     .fontSize,
  //                                 overflow: TextOverflow.ellipsis,
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                       Container(
  //                         padding: const EdgeInsets.only(right: 10.0),
  //                         child: Stack(
  //                           alignment: Alignment.bottomRight,
  //                           children: [
  //                             authProvider.auth != null &&
  //                                     authProvider.auth!.profileImage !=
  //                                         null &&
  //                                     authProvider
  //                                         .auth!.profileImage!.isNotEmpty
  //                                 ? ClipRRect(
  //                                     borderRadius:
  //                                         BorderRadius.circular(25.0),
  //                                     child: CachedNetworkImage(
  //                                       fit: BoxFit.cover,
  //                                       width: MediaQuery.of(context)
  //                                               .size
  //                                               .width *
  //                                           0.13,
  //                                       height: MediaQuery.of(context)
  //                                               .size
  //                                               .width *
  //                                           0.13,
  //                                       placeholder: (BuildContext context,
  //                                               String url) =>
  //                                           Container(
  //                                         color: Theme.of(context)
  //                                             .colorScheme
  //                                             .secondary,
  //                                         padding:
  //                                             const EdgeInsets.all(8.0),
  //                                         child:
  //                                             const CircularProgressIndicator
  //                                                 .adaptive(
  //                                           strokeWidth: 2.0,
  //                                         ),
  //                                       ),
  //                                       imageUrl: authProvider.auth != null
  //                                           ? authProvider
  //                                               .auth!.profileImage!
  //                                           : "",
  //                                       errorWidget:
  //                                           (context, url, error) =>
  //                                               Container(
  //                                         color: Theme.of(context)
  //                                             .colorScheme
  //                                             .secondary,
  //                                         child: const Icon(
  //                                           Icons.error_outline,
  //                                           color: Colors.red,
  //                                         ),
  //                                       ),
  //                                     ),
  //                                   )
  //                                 : CircleAvatar(
  //                                     radius: 25.0,
  //                                     child: Lottie.asset(
  //                                       'assets/animations/lottie_profile.json',
  //                                       width: MediaQuery.of(context)
  //                                               .size
  //                                               .width *
  //                                           0.11,
  //                                       height: MediaQuery.of(context)
  //                                               .size
  //                                               .width *
  //                                           0.11,
  //                                       fit: BoxFit.fill,
  //                                     ),
  //                                   ),
  //                             Container(
  //                               padding: const EdgeInsets.all(3),
  //                               decoration: const BoxDecoration(
  //                                 color: Colors.green,
  //                                 shape: BoxShape.circle,
  //                               ),
  //                               child: const Icon(
  //                                 Icons.star,
  //                                 color: Colors.white,
  //                                 size: 10.5,
  //                               ),
  //                             )
  //                           ],
  //                         ),
  //                       ),
  //                     ],
  //                   );
  //                 },
  //               ),
  //               const Divider(),
  //               GestureDetector(
  //                 onTap: handleNavigateToProfileDetailsScreen,
  //                 child: Container(
  //                   margin: const EdgeInsets.only(
  //                     top: 5.0,
  //                   ),
  //                   child: Center(
  //                     child: Text(
  //                       "View Profile",
  //                       style: TextStyle(
  //                         fontSize: Theme.of(context)
  //                             .textTheme
  //                             .bodyMedium!
  //                             .fontSize,
  //                         color: Theme.of(context).colorScheme.primary,
  //                         fontWeight: FontWeight.w500,
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               )
  //             ],
  //           ),
  //         ),
  //       ),
  //     ],
  //   ),
  // );
}
