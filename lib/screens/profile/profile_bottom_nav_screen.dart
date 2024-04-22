import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/sarawakid/login_full_bottom_modal.dart';
import '../../screens/support/privacy_policy_screen.dart';
import '../../screens/support/terms_and_conditions_screen.dart';
import '../../screens/support/send_feedback_screen.dart';
import '../../screens/reported_cases/emergency_cases_screen.dart';
import '../../screens/reported_cases/talikhidmat_cases_screen.dart';
import '../../screens/transaction/transaction_history_screen.dart';
import '../../utils/notification/push_notification.dart';
import '../../utils/app_localization.dart';

class ProfileBottomNavScreen extends StatefulWidget {
  static const String routeName = 'profile-bottom-nav-screen';

  const ProfileBottomNavScreen({super.key});

  @override
  State<ProfileBottomNavScreen> createState() => _ProfileBottomNavScreenState();
}

class _ProfileBottomNavScreenState extends State<ProfileBottomNavScreen> {
  bool notification = true;
  bool music = true;

  final double _kItemExtent = 32.0;
  final List<String> _fruitNames = <String>[
    'English',
    'Bahasa Malaysia',
    '中文',
  ];

  late String languageCode;

  int _selectedFruit = 0;
  late bool isLogin;
  String appVersion = "";
  bool isLoading = false;

  PushNotification _pushNotification = PushNotification();

  // return app version in drawer
  Future<void> _getAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        appVersion = packageInfo.version;
      });
    } catch (e) {
      print('checkAppVersion error');
      throw e;
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

  Future<void> _handleReportedCasesBottomModal() async {
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(
                height: 10.0,
              ),
              Container(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Choose the reported cases",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              ListTile(
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context)
                      .pushNamed(TalikhidmatCasesScreen.routeName);
                },
                leading: const CircleAvatar(
                  child: Icon(Icons.feedback_outlined),
                ),
                title: const Text("Talikhidmat Cases"),
                trailing: Icon(
                  Icons.arrow_circle_right_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              ListTile(
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context)
                      .pushNamed(EmergencyCasesScreen.routeName);
                },
                leading: const CircleAvatar(
                  child: Icon(Icons.sos),
                ),
                title: const Text("Emergency Cases"),
                trailing: Icon(
                  Icons.arrow_circle_right_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),
            ],
          ),
        );
      },
    );
  }

  // This shows a CupertinoModalPopup with a reasonable fixed height which hosts CupertinoPicker.
  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6.0),
        // The Bottom margin is provided to align the popup above the system navigation bar.
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        // Provide a background color for the popup.
        color: CupertinoColors.systemBackground.resolveFrom(context),
        // Use a SafeArea widget to avoid system overlaps.
        child: SafeArea(
          top: false,
          child: child,
        ),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getAppVersion();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    isLogin = Provider.of<AuthProvider>(context).isAuth;
    languageCode = Provider.of<LanguageProvider>(context).locale.languageCode;
    if (languageCode == "en") {
      _selectedFruit = 0;
    } else if (languageCode == "ms") {
      _selectedFruit = 1;
    } else {
      _selectedFruit = 2;
    }
    music = Provider.of<SettingsProvider>(context).isSplashScreenMusicEnabled;
    notification =
        Provider.of<SettingsProvider>(context).isPushNotificationEnabled;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: <Widget>[
          if (!isLogin)
            GestureDetector(
              onTap: () => _handleFullScreenLoginBottomModal(context),
              child: Container(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: <Widget>[
                    const CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                    const SizedBox(
                      width: 15.0,
                    ),
                    Text(
                      "Login Now",
                      style: Theme.of(context).textTheme.titleMedium,
                    )
                  ],
                ),
              ),
            ),
          if (!isLogin)
            Divider(
              thickness: 5.0,
              color: Theme.of(context).dividerColor.withOpacity(0.1),
            ),
          if (isLogin)
            Container(
              padding: const EdgeInsets.only(
                bottom: 10.0,
                left: 10.0,
                right: 10.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(
                      bottom: 10.0,
                    ),
                    child: Text(
                      AppLocalization.of(context)!.translate('app_services')!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize:
                            Theme.of(context).textTheme.titleMedium!.fontSize,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  GestureDetector(
                    onTap: _handleReportedCasesBottomModal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            const Icon(
                              Icons.info_outline_rounded,
                              size: 30.0,
                            ),
                            const SizedBox(
                              width: 15.0,
                            ),
                            Text(
                              AppLocalization.of(context)!
                                  .translate('reported_cases')!,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        Icon(
                          Icons.arrow_right_alt_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context)
                        .pushNamed(TransactionHistoryScreen.routeName),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            const Icon(
                              Icons.wallet_outlined,
                              size: 30.0,
                            ),
                            const SizedBox(
                              width: 15.0,
                            ),
                            Text(
                              AppLocalization.of(context)!
                                  .translate('transaction_hist')!,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        Icon(
                          Icons.arrow_right_alt_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          if (isLogin)
            Divider(
              thickness: 5.0,
              color: Theme.of(context).dividerColor.withOpacity(0.1),
            ),
          Container(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 10.0,
                  ),
                  child: Text(
                    AppLocalization.of(context)!.translate('app_settings')!,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize:
                          Theme.of(context).textTheme.titleMedium!.fontSize,
                    ),
                  ),
                ),
                if (isLogin)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          const Icon(
                            Icons.notifications_outlined,
                            size: 30.0,
                          ),
                          const SizedBox(
                            width: 15.0,
                          ),
                          Text(
                            AppLocalization.of(context)!
                                .translate('push_notifications')!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      Transform.scale(
                        scaleY: 0.75,
                        scaleX: 0.85,
                        child: Switch(
                            value: notification,
                            onChanged: isLoading
                                ? null
                                : (bool value) async {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    if (value) {
                                      _pushNotification
                                          .setFirebase(true)
                                          .then((_) {
                                        setState(() {
                                          notification = value;
                                          Provider.of<SettingsProvider>(context,
                                                  listen: false)
                                              .enablePushNotification();
                                        });
                                      });
                                    } else {
                                      _pushNotification
                                          .setFirebase(false)
                                          .then((_) {
                                        setState(() {
                                          notification = value;
                                          Provider.of<SettingsProvider>(context,
                                                  listen: false)
                                              .disablePushNotification();
                                        });
                                      });
                                    }
                                    setState(() {
                                      isLoading = false;
                                    });
                                  }),
                      ),
                    ],
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        const Icon(
                          Icons.music_note_outlined,
                          size: 30.0,
                        ),
                        const SizedBox(
                          width: 15.0,
                        ),
                        Text(
                          AppLocalization.of(context)!
                              .translate('screen_music')!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    Transform.scale(
                      scaleY: 0.75,
                      scaleX: 0.85,
                      child: Switch(
                          value: music,
                          onChanged: (bool value) {
                            setState(() {
                              music = value;
                            });
                            if (value) {
                              Provider.of<SettingsProvider>(context,
                                      listen: false)
                                  .enableSplashScreenMusic();
                            } else {
                              Provider.of<SettingsProvider>(context,
                                      listen: false)
                                  .disableSplashScreenMusic();
                            }
                          }),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        const Icon(
                          Icons.translate_outlined,
                          size: 30.0,
                        ),
                        const SizedBox(
                          width: 15.0,
                        ),
                        Text(
                          AppLocalization.of(context)!.translate('language')!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        CupertinoButton(
                          onPressed: () => _showDialog(
                            CupertinoPicker(
                              magnification: 1.22,
                              squeeze: 1.2,
                              useMagnifier: true,
                              itemExtent: _kItemExtent,
                              // This sets the initial item.
                              scrollController: FixedExtentScrollController(
                                initialItem: _selectedFruit,
                              ),
                              // This is called when selected item is changed.
                              onSelectedItemChanged: (int selectedItem) {
                                setState(() {
                                  _selectedFruit = selectedItem;
                                  if (selectedItem == 0) {
                                    Provider.of<LanguageProvider>(
                                      context,
                                      listen: false,
                                    ).changeLanguage('en', 'US');
                                  } else if (selectedItem == 1) {
                                    Provider.of<LanguageProvider>(
                                      context,
                                      listen: false,
                                    ).changeLanguage('ms', 'MY');
                                  } else {
                                    Provider.of<LanguageProvider>(
                                      context,
                                      listen: false,
                                    ).changeLanguage('zh', 'CN');
                                  }
                                });
                              },
                              children: List<Widget>.generate(
                                  _fruitNames.length, (int index) {
                                return Center(
                                  child: Text(_fruitNames[index]),
                                );
                              }),
                            ),
                          ),
                          child: Text(
                            _fruitNames[_selectedFruit],
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
          Divider(
            thickness: 5.0,
            color: Theme.of(context).dividerColor.withOpacity(0.1),
          ),
          Container(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 10.0,
                  ),
                  child: Text(
                    AppLocalization.of(context)!.translate('app_support')!,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize:
                          Theme.of(context).textTheme.titleMedium!.fontSize,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context)
                      .pushNamed(SendFeedbackScreen.routeName),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 10.0,
                    ),
                    child: Row(
                      children: <Widget>[
                        const Icon(
                          Icons.star_border_outlined,
                          size: 30.0,
                        ),
                        const SizedBox(
                          width: 15.0,
                        ),
                        Text(AppLocalization.of(context)!
                            .translate('send_feedback')!)
                      ],
                    ),
                  ),
                ),
                const Divider(),
                GestureDetector(
                  onTap: () => Navigator.of(context)
                      .pushNamed(TermsAndConditionsScreen.routeName),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 10.0,
                    ),
                    child: Row(
                      children: <Widget>[
                        const Icon(
                          Icons.description_outlined,
                          size: 30.0,
                        ),
                        const SizedBox(
                          width: 15.0,
                        ),
                        Text(AppLocalization.of(context)!
                            .translate('terms_cond')!)
                      ],
                    ),
                  ),
                ),
                const Divider(),
                GestureDetector(
                  onTap: () => Navigator.of(context)
                      .pushNamed(PrivacyPolicyScreen.routeName),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 10.0,
                    ),
                    child: Row(
                      children: <Widget>[
                        const Icon(
                          Icons.remove_red_eye_outlined,
                          size: 30.0,
                        ),
                        const SizedBox(
                          width: 15.0,
                        ),
                        Text(AppLocalization.of(context)!
                            .translate('privacy_poli')!)
                      ],
                    ),
                  ),
                ),
                const Divider(),
                GestureDetector(
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationVersion: appVersion,
                      applicationIcon: SizedBox(
                        width: 60,
                        height: 60,
                        child: Image.asset(
                          'assets/images/icon/app_logo.png',
                        ),
                      ),
                      applicationLegalese:
                          "CitizenApp is powered by Sarawak Integrated Operation Centre (SIOC).",
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 10.0,
                    ),
                    child: Row(
                      children: <Widget>[
                        const Icon(
                          Icons.info_outline,
                          size: 30.0,
                        ),
                        const SizedBox(
                          width: 15.0,
                        ),
                        Text(AppLocalization.of(context)!
                            .translate('about_app')!)
                      ],
                    ),
                  ),
                ),
                const Divider(),
                Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 10.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          const Icon(
                            Icons.copy,
                            size: 30.0,
                          ),
                          const SizedBox(
                            width: 15.0,
                          ),
                          Text(AppLocalization.of(context)!
                              .translate('app_vers')!)
                        ],
                      ),
                      Text(
                        appVersion,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(
            thickness: 5.0,
            color: Theme.of(context).dividerColor.withOpacity(0.1),
          ),
        ],
      ),
    );
  }
}
