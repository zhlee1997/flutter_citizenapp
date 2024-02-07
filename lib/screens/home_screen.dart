import 'package:flutter/material.dart';
import 'package:flutter_citizenapp/screens/home_page.dart';
import 'package:flutter_citizenapp/screens/notifications/notifications_bottom_nav_screen.dart';
import 'package:flutter_citizenapp/screens/profile/profile_bottom_nav_screen.dart';
import 'package:flutter_citizenapp/screens/sarawakid/sarawakid_screen.dart';
import 'package:flutter_citizenapp/screens/services/services_bottom_nav_screen.dart';

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

  void handleNavigateSarawakIDScreen() =>
      Navigator.of(context).pushNamed(SarawakIDScreen.routeName);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
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
            icon: const Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(
              Icons.apps,
              color: Theme.of(context).colorScheme.primary,
            ),
            icon: const Icon(Icons.apps_outlined),
            label: 'Services',
          ),
          NavigationDestination(
            selectedIcon: Badge(
              child: Icon(
                Icons.notifications,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            icon: const Badge(child: Icon(Icons.notifications_outlined)),
            label: 'Notifications',
          ),
          NavigationDestination(
            selectedIcon: Badge(
              label: const Text("2"),
              child: Icon(
                Icons.account_circle,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            icon: const Badge(
              label: Text('2'),
              child: Icon(
                Icons.account_circle_outlined,
              ),
            ),
            label: 'Profile',
          ),
        ],
      ),
      appBar: _handleAppBar(),
      body: _screens[_currentPageIndex],
    );
  }

  AppBar _handleAppBar() {
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
            // decoration: BoxDecoration(
            //   color: Colors.grey[300],
            //   shape: BoxShape.circle,
            // ),
            child: Image.asset(
              "assets/images/icon/sarawak_logo.png",
              width: 50,
              height: 50,
              fit: BoxFit.contain,
            ),
          ),
          title: GestureDetector(
            child: Text(
              "Login Now to CitizenApp",
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 16.0,
              ),
            ),
            onTap: () {
              handleNavigateSarawakIDScreen();
            },
          ),
          actions: [
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
                onPressed: () {
                  handleNavigateSarawakIDScreen();
                },
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
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text("Services"),
              Text(
                "Choose the services we offer",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: Theme.of(context).textTheme.labelLarge!.fontSize,
                ),
              )
            ],
          ),
        );
      case 2:
        return AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text("Notifications"),
              Text(
                "Get notified by the notifications",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: Theme.of(context).textTheme.labelLarge!.fontSize,
                ),
              )
            ],
          ),
        );
      case 3:
        return AppBar(
            title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text("Profile"),
            Text(
              "Select your profile settings",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: Theme.of(context).textTheme.labelLarge!.fontSize,
              ),
            )
          ],
        ));
      default:
        return AppBar();
    }
  }
}
