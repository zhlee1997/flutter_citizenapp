import 'package:flutter/widgets.dart';

import './screens/sarawakid/sarawakid_screen.dart';

import './screens/talikhidmat/new_case_screen.dart';

import './screens/notifications/notifications_bottom_nav_screen.dart';

import './screens/services/services_bottom_nav_screen.dart';

import './screens/profile/profile_bottom_nav_screen.dart';
import './screens/profile/profile_details_screen.dart';

import './screens/emergency/emergency_screen.dart';
import './screens/emergency/recording_screen.dart';

import './screens/bill_payment/bill_payment_screen.dart';

import './screens/announcement/announcement_detail_screen.dart';
import './screens/announcement/citizen_announcements_screen.dart';
import './screens/announcement/tourism_news_screen.dart';

import './screens/subscription/subsription_package_screen.dart';
import './screens/subscription/subscription_checkout_screen.dart';
import './screens/subscription/subscription_choose_screen.dart';
import './screens/subscription/subscription_map_screen.dart';
import './screens/subscription/subscription_video_screen.dart';
import './screens/subscription/subscription_list_screen.dart';
import './screens/subscription/subscription_result_screen.dart';

import './screens/traffic/traffic_images_list_screen.dart';

import './screens/support/privacy_policy_screen.dart';
import './screens/support/terms_and_conditions_screen.dart';
import './screens/support/send_feedback_screen.dart';

import './screens/home_screen.dart';
import './screens/onboarding_screen.dart';

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
  BillPaymentScreen.routeName: (ctx) => const BillPaymentScreen(),
  AnnouncementDetailScreen.routeName: (ctx) => const AnnouncementDetailScreen(),
  PrivacyPolicyScreen.routeName: (ctx) => const PrivacyPolicyScreen(),
  TermsAndConditionsScreen.routeName: (ctx) => const TermsAndConditionsScreen(),
  SendFeedbackScreen.routeName: (ctx) => const SendFeedbackScreen(),
  SubscriptionPackageScreen.routeName: (ctx) =>
      const SubscriptionPackageScreen(),
  SubscriptionCheckoutScreen.routeName: (ctx) =>
      const SubscriptionCheckoutScreen(),
  CitizenAnnouncementsScreen.routeName: (ctx) =>
      const CitizenAnnouncementsScreen(),
  TourismNewsScreen.routeName: (ctx) => const TourismNewsScreen(),
  OnboardingScreen.routeName: (ctx) => const OnboardingScreen(),
  RecordingScreen.routeName: (ctx) => const RecordingScreen(),
  SubscriptionChooseScreen.routeName: (ctx) => const SubscriptionChooseScreen(),
  SubscriptionMapScreen.routeName: (ctx) => const SubscriptionMapScreen(),
  SubscriptionVideoScreen.routeName: (ctx) => const SubscriptionVideoScreen(),
  SubscriptionListScreen.routeName: (ctx) => const SubscriptionListScreen(),
  SubscriptionResultScreen.routeName: (ctx) => const SubscriptionResultScreen(),
  TrafficImagesListScreen.routeName: (ctx) => const TrafficImagesListScreen(),
};
