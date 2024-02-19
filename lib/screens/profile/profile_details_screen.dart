import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
// import 'package:fluttertoast/fluttertoast.dart';

import '../../models/auth_model.dart';
import '../../services/auth_services.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_localization.dart';
import '../../utils/global_dialog_helper.dart';

class ProfileDetailsScreen extends StatefulWidget {
  static const String routeName = 'profile-details-screen';

  const ProfileDetailsScreen({super.key});

  @override
  State<ProfileDetailsScreen> createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen> {
  late TapGestureRecognizer? _tapGestureRecognizer;

  late String _username;
  late String _fullName;
  late bool _isSubscribe;
  String? _emailAddress;
  String? _mobile;
  String? _address;
  String? _profileImage;
  late AuthModel _authData;
  String? _vipDueDate;

  AuthServices _authServices = AuthServices();

  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(Duration(days: 30));

  /// Launch Sarawak ID Website when tap on 'Sarawak ID' link
  void _handleLaunchWebsite() {
    final Uri _uri =
        Uri.parse("https://sarawakid-tnt.sarawak.gov.my/web/ssov1/login/");
    launchUrl(_uri);
  }

  Future<void> _refreshProfile() async {}

  String formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  @override
  void initState() {
    _tapGestureRecognizer = TapGestureRecognizer()
      ..onTap = _handleLaunchWebsite;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _authData = Provider.of<AuthProvider>(context).auth;
    _vipDueDate = Provider.of<AuthProvider>(context).vipDueDate ?? '---';

    _username = _authData.userName;
    _fullName = _authData.fullName;
    // _isSubscribe = _authData.isSubscribed;

    // TODO: temporary true
    _isSubscribe = true;
    _emailAddress = _authData.email;
    _mobile = _authData.mobile;
    _address = _authData.address;
    _profileImage = _authData.profileImage;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _tapGestureRecognizer!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        // title: Text(AppLocalization.of(context)!.translate('my_profile')!),
        title: Text("Profile Details"),
        actions: <Widget>[
          IconButton(
            onPressed: _refreshProfile,
            icon: Icon(Icons.refresh),
            tooltip: "Refresh profile",
          )
        ],
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            // Container(
            //   width: double.infinity,
            //   margin: const EdgeInsets.only(
            //     top: 10.0,
            //     bottom: 10.0,
            //   ),
            //   child: ListTile(
            //     // isThreeLine: true,
            //     title: Container(
            //       child: Text(
            //         '$_fullName',
            //         softWrap: true,
            //         // style: TextStyle(
            //         //   fontSize: Platform.isIOS ? 18 : 18,
            //         // ),
            //       ),
            //     ),
            //     subtitle: Container(
            //       // margin: EdgeInsets.only(
            //       //   top: screenSize.width * 0.015,
            //       // ),
            //       // child: Column(
            //       //   crossAxisAlignment: CrossAxisAlignment.start,
            //       //   children: [
            //       //     Text('Sarawak ID: $_username'),
            //       //     Container(
            //       //       child: Text(
            //       //         _isSubscribe
            //       //             ? '${AppLocalization.of(context)!.translate('vip_m')!} $_vipDueDate'
            //       //             : AppLocalization.of(context)!
            //       //                 .translate('normal_mem')!,
            //       //         style: TextStyle(
            //       //           fontStyle: FontStyle.italic,
            //       //         ),
            //       //       ),
            //       //     )
            //       //   ],
            //       // ),
            //       child: Text('Sarawak ID: $_username'),
            //     ),
            //     leading: CircleAvatar(
            //       radius: Platform.isIOS ? 30 : 25,
            //       backgroundColor: Theme.of(context).primaryColor,
            //       foregroundImage: _profileImage != null
            //           ? NetworkImage("$_profileImage")
            //           : null,
            //       child: _profileImage != null
            //           ? null
            //           : CircleAvatar(
            //               backgroundColor: Theme.of(context).accentColor,
            //               radius: 26.5,
            //               child: Icon(
            //                 Icons.person,
            //                 size: 35,
            //               ),
            //             ),
            //     ),
            //     trailing: _isSubscribe
            //         ? Container(
            //             padding:
            //                 EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            //             decoration: BoxDecoration(
            //               color: Colors.yellow,
            //               borderRadius: BorderRadius.circular(16),
            //             ),
            //             child: Row(
            //               mainAxisSize: MainAxisSize.min,
            //               children: [
            //                 Icon(
            //                   Icons.star,
            //                   color: Colors.black,
            //                 ),
            //                 SizedBox(width: 4),
            //                 Text(
            //                   'Premium',
            //                   style: TextStyle(
            //                     color: Colors.black,
            //                     fontWeight: FontWeight.bold,
            //                   ),
            //                 ),
            //               ],
            //             ),
            //           )
            //         : TextButton(
            //             child: Text(
            //               "SUBSCRIBE",
            //               style: TextStyle(
            //                 fontSize: Platform.isIOS ? 15 : 13,
            //               ),
            //             ),
            //             onPressed: () {
            //               Navigator.of(context)
            //                   .pushNamed(SubscriptionScreen.routeName);
            //             },
            //           ),
            //   ),
            // ),
            Container(
              height: 260,
              child: Stack(
                children: <Widget>[
                  Image.asset(
                    "assets/images/pictures/kuching_city.jpeg",
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.fill,
                    opacity: const AlwaysStoppedAnimation(0.85),
                  ),
                  Positioned(
                    top: 90.0,
                    left: 20.0,
                    right: 20.0,
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(
                        top: 10.0,
                        bottom: 10.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              CircleAvatar(
                                radius: Platform.isIOS ? 42.5 : 32.5,
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundImage: _profileImage != null
                                    ? NetworkImage("$_profileImage")
                                    : null,
                                child: _profileImage != null
                                    ? null
                                    : CircleAvatar(
                                        radius: 30,
                                        child: Icon(
                                          Icons.person,
                                          size: 50,
                                        ),
                                      ),
                              ),
                              Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.star,
                                  color: Colors.white,
                                  size: 12.5,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            '$_fullName',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          _isSubscribe
                              ? Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.yellow[300],
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.star,
                                        color: Colors.black,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Premium',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ActionChip(
                                  side: BorderSide(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  // padding: EdgeInsets.symmetric(
                                  //   horizontal: 5.0,
                                  // ),
                                  avatar: Icon(
                                    Icons.verified_user,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  label: Text(
                                    "Subscribe",
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  backgroundColor:
                                      Theme.of(context).backgroundColor,
                                  onPressed: () {
                                    // Navigator.of(context)
                                    //     .pushNamed(SubscribeScreen.routeName);
                                  },
                                ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(
                vertical: 5.0,
                horizontal: 10.0,
              ),
              child: ListTile(
                minVerticalPadding: 15.0,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                // tileColor: Theme.of(context).accentColor,
                title: const Text(
                  "Subscription Period:",
                ),
                subtitle: Container(
                  margin: EdgeInsets.only(
                    top: screenSize.width * 0.015,
                  ),
                  child: Text(
                    '${formatDate(startDate)} - ${formatDate(endDate)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(
                vertical: 5.0,
                horizontal: 10.0,
              ),
              child: ListTile(
                minVerticalPadding: 15.0,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                // tileColor: Theme.of(context).accentColor,
                title: Text(
                  "Sarawak ID:",
                ),
                subtitle: Container(
                  margin: EdgeInsets.only(
                    top: screenSize.width * 0.015,
                  ),
                  child: Text(
                    '$_username',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(
                vertical: 5.0,
                horizontal: 10.0,
              ),
              child: ListTile(
                minVerticalPadding: 15.0,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                // tileColor: Theme.of(context).accentColor,
                title: Text(
                  AppLocalization.of(context)!.translate('email_add')! + ":",
                ),
                subtitle: Container(
                  margin: EdgeInsets.only(
                    top: screenSize.width * 0.015,
                  ),
                  child: Text(
                    '$_emailAddress',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(
                vertical: 5.0,
                horizontal: 10.0,
              ),
              child: ListTile(
                minVerticalPadding: 15.0,
                // tileColor: Theme.of(context).accentColor,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                title: Text(
                  AppLocalization.of(context)!.translate('mobile_num')! + ":",
                ),
                subtitle: Container(
                  margin: EdgeInsets.only(
                    top: screenSize.width * 0.015,
                  ),
                  child: Text(
                    '$_mobile',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(
                vertical: 5.0,
                horizontal: 10.0,
              ),
              child: ListTile(
                minVerticalPadding: 15.0,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                // tileColor: Theme.of(context).accentColor,
                title: Text(
                  AppLocalization.of(context)!.translate('address')! + ":",
                ),
                subtitle: Container(
                  margin: EdgeInsets.only(
                    top: screenSize.width * 0.015,
                  ),
                  child: Text(
                    '$_address',
                    softWrap: true,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    // text: AppLocalization.of(context)!.translate('to_edit')!,
                    text: "To edit profile, visit ",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                    text: 'Sarawak ID website',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    recognizer: _tapGestureRecognizer,
                  )
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Consumer<AuthProvider>(
              builder: (BuildContext ctx, AuthProvider authProvider, child) {
                if (authProvider.isAuth &&
                    authProvider.auth.fullName.isNotEmpty &&
                    authProvider.auth.email!.isNotEmpty) {
                  return TextButton(
                    onPressed: () {
                      GlobalDialogHelper().showAlertDialog(
                        context: context,
                        title:
                            AppLocalization.of(context)!.translate('logout')!,
                        message: AppLocalization.of(context)!
                            .translate('do_you_logout')!,
                        yesButtonFunc: () async {
                          Navigator.of(context).pop();
                          Future.delayed(Duration.zero, () async {
                            await GlobalDialogHelper()
                                .buildCircularProgressWithTextCenter(
                              context: context,
                              message: AppLocalization.of(context)!
                                  .translate('logging_out')!,
                            );
                            authProvider
                                .signOut(context)
                                .then((_) => Navigator.of(context).pop());
                          });
                        },
                      );
                    },
                    child: Text(
                      "Log out",
                      style: TextStyle(
                        fontSize: 18.0,
                      ),
                    ),
                  );
                } else {
                  return Container();
                }
              },
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
