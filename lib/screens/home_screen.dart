import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

import '../providers/auth_provider.dart';
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

  final List<Widget> _screens = [
    const HomePage(),
    const ServicesBottomNavScreen(),
    const NotificationsBottomNavScreen(),
    const ProfileBottomNavScreen(),
  ];

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

  @override
  Widget build(BuildContext context) {
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
            setState(() {
              _currentPageIndex = index;
            });
          },
          selectedIndex: _currentPageIndex,
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
                child: Icon(
                  Icons.notifications,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              icon: const Badge(
                  child: Icon(
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
      appBar: _handleAppBar(),
      body: _screens[_currentPageIndex],
    );
  }

  PreferredSizeWidget _handleAppBar() {
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
        );
      case 3:
        return Provider.of<AuthProvider>(context).isAuth
            ? _appBar(
                AppBar().preferredSize.height,
                () => handleNavigateToProfileDetailsScreen(),
              )
            : AppBar(
                title: const Text("Profile"),
              );
      default:
        return AppBar();
    }
  }

  _appBar(height, handleNavigateToProfileDetailsScreen) => PreferredSize(
        preferredSize: Size(
          MediaQuery.of(context).size.width,
          // TODO: Adjust appbar height
          height + 130,
        ),
        child: Stack(
          children: <Widget>[
            Container(
              // Background
              color: Theme.of(context).primaryColor,
              // TODO: Adjust appbar height
              height: height + 90,
              width: MediaQuery.of(context).size.width,
              child: const Center(
                child: Text(
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
                toolbarHeight: 120.0,
                shape: Border.all(
                  width: 0.5,
                  color: Colors.grey,
                ),
                scrolledUnderElevation: 0.0,
                backgroundColor: Colors.white,
                primary: false,
                title: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Consumer<AuthProvider>(
                          builder: (_, AuthProvider authProvider, __) {
                            return Container(
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
                                      color: Colors.grey,
                                      fontSize: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .fontSize,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        Container(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              CircleAvatar(
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
