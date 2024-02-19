import 'package:flutter/widgets.dart';

import './screens/sarawakid/sarawakid_screen.dart';

import './screens/talikhidmat/new_case_screen.dart';

import './screens/notifications/notifications_bottom_nav_screen.dart';

import './screens/services/services_bottom_nav_screen.dart';

import './screens/profile/profile_bottom_nav_screen.dart';
import './screens/profile/profile_details_screen.dart';

import './screens/emergency/emergency_screen.dart';

import './screens/home_screen.dart';

final Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{
  NewCaseScreen.routeName: (ctx) => const NewCaseScreen(),
  HomeScreen.routeName: (ctx) => const HomeScreen(),
  NotificationsBottomNavScreen.routeName: (ctx) =>
      const NotificationsBottomNavScreen(),
  ServicesBottomNavScreen.routeName: (ctx) => const ServicesBottomNavScreen(),
  ProfileBottomNavScreen.routeName: (ctx) => const ProfileBottomNavScreen(),
  ProfileDetailsScreen.routeName: (ctx) => const ProfileDetailsScreen(),
  SarawakIDScreen.routeName: (ctx) => const SarawakIDScreen(),
  EmergencyScreen.routeName: (ctx) => const EmergencyScreen(),
};
