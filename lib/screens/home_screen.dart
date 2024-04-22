import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../providers/auth_provider.dart';
import '../providers/inbox_provider.dart';
import '../screens/home_page.dart';
import '../screens/notifications/notifications_bottom_nav_screen.dart';
import '../screens/profile/profile_bottom_nav_screen.dart';
import '../screens/profile/profile_details_screen.dart';
import '../screens/services/services_bottom_nav_screen.dart';
import '../widgets/sarawakid/login_full_bottom_modal.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = 'home-page-screen';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentPageIndex = 0;
  bool isNotificationsSelected = true;

  /// Creating a navigation key to control tab bar navigation
  final _navigationKey = GlobalKey();

  void setNotificationsState(bool isSelected) {
    setState(() {
      isNotificationsSelected = isSelected;
    });
  }

  List<Widget> _screens = [];

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
                    : const TextStyle(
                        color: Colors.grey,
                      ),
          ),
        ),
        child: NavigationBar(
          onDestinationSelected: (int index) {
            if (index == _currentPageIndex) {
              return;
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
              icon: const Icon(
                Icons.home_outlined,
                color: Colors.grey,
              ),
              label: 'Home',
            ),
            NavigationDestination(
              selectedIcon: Icon(
                Icons.apps,
                color: Theme.of(context).colorScheme.primary,
              ),
              icon: const Icon(
                Icons.apps_outlined,
                color: Colors.grey,
              ),
              label: 'Services',
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
                  child: const Icon(
                    Icons.notifications_outlined,
                    color: Colors.grey,
                  )),
              label: 'Notifications',
            ),
            NavigationDestination(
              selectedIcon: Icon(
                Icons.account_circle,
                color: Theme.of(context).colorScheme.primary,
              ),
              icon: const Icon(
                Icons.account_circle_outlined,
                color: Colors.grey,
              ),
              label: 'Profile',
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
        return 'Good Morning';
      } else if (hour >= 12 && hour < 17) {
        return 'Good Afternoon';
      } else {
        return 'Good Evening';
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
              final String fullName = authProvider.auth.fullName;
              final String firstName = fullName.split(" ")[0];

              final String greetings = getGreeting();

              return GestureDetector(
                onTap: authProvider.isAuth
                    ? null
                    : () => _handleFullScreenLoginBottomModal(),
                child: Text(
                  authProvider.isAuth
                      ? "$greetings, $firstName"
                      : "Login Now to CitizenApp",
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
          title: const Text("Services"),
        );
      case 2:
        return AppBar(
          title: const Text("Notifications"),
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
                title: const Text("Profile"),
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
        preferredSize: Size(
          MediaQuery.of(context).size.width,
          // TODO: Adjust appbar height
          height + screenSize.height * 0.22,
        ),
        child: Stack(
          children: <Widget>[
            Container(
              // Background
              color: Theme.of(context).primaryColor,
              // TODO: Adjust appbar height
              height: height + screenSize.height * 0.13,
              width: screenSize.width,
              child: Container(
                margin: EdgeInsets.only(top: screenSize.height * 0.06),
                alignment: Alignment.topCenter,
                child: const Text(
                  "Profile",
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            Container(), // Required some widget in between to float AppBar

            Positioned(
              // To take AppBar Size only
              top: 100.0,
              left: 20.0,
              right: 20.0,
              child: AppBar(
                // TODO: Adjust appbar height
                toolbarHeight: screenSize.height * 0.17,
                shape: Border.all(
                  width: 0.5,
                  color: Colors.grey,
                ),
                scrolledUnderElevation: 0.0,
                backgroundColor: Colors.white,
                primary: false,
                title: Column(
                  children: <Widget>[
                    Consumer<AuthProvider>(
                      builder: (_, AuthProvider authProvider, __) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.only(left: 10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    authProvider.auth.fullName,
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    authProvider.auth.mobile ?? "",
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .fontSize,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  authProvider.auth.profileImage != null &&
                                          authProvider
                                              .auth.profileImage!.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(25.0),
                                          child: CachedNetworkImage(
                                            fit: BoxFit.cover,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.13,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.13,
                                            placeholder: (BuildContext context,
                                                    String url) =>
                                                Container(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary,
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child:
                                                  const CircularProgressIndicator
                                                      .adaptive(
                                                strokeWidth: 2.0,
                                              ),
                                            ),
                                            imageUrl:
                                                authProvider.auth.profileImage!,
                                            errorWidget:
                                                (context, url, error) =>
                                                    Container(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary,
                                              child: const Icon(
                                                Icons.error_outline,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        )
                                      : CircleAvatar(
                                          radius: 25.0,
                                          child: Lottie.asset(
                                            'assets/animations/lottie_profile.json',
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.11,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.11,
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                  Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.star,
                                      color: Colors.white,
                                      size: 10.5,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const Divider(),
                    GestureDetector(
                      onTap: handleNavigateToProfileDetailsScreen,
                      child: Container(
                        margin: const EdgeInsets.only(
                          top: 5.0,
                        ),
                        child: Center(
                          child: Text(
                            "View Profile",
                            style: TextStyle(
                              fontSize: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .fontSize,
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      );
}
