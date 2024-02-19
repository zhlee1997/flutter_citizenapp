import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_citizenapp/providers/auth_provider.dart';
import 'package:provider/provider.dart';

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
    'Mandarin',
    'Bahasa Malaysia',
  ];

  int _selectedFruit = 0;
  // TODO
  late bool isLogin;

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
  void didChangeDependencies() {
    isLogin = Provider.of<AuthProvider>(context).isAuth;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(10.0),
      child: Column(
        children: <Widget>[
          if (!isLogin)
            GestureDetector(
              onTap: () {
                print("login now pressed");
              },
              child: Container(
                padding: EdgeInsets.all(10.0),
                child: Row(
                  children: <Widget>[
                    CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                    SizedBox(
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
              color: Theme.of(context).dividerColor.withOpacity(0.05),
            ),
          Container(
            padding: EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.symmetric(
                    vertical: 10.0,
                  ),
                  child: Text(
                    "App Settings",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize:
                          Theme.of(context).textTheme.titleMedium!.fontSize,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.notifications_outlined,
                          size: 30.0,
                        ),
                        SizedBox(
                          width: 15.0,
                        ),
                        Text(
                          "Push Notifications",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    Transform.scale(
                      scaleY: 0.75,
                      scaleX: 0.85,
                      child: Switch(
                          value: notification,
                          onChanged: (bool value) {
                            setState(() {
                              notification = value;
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
                        Icon(
                          Icons.music_note_outlined,
                          size: 30.0,
                        ),
                        SizedBox(
                          width: 15.0,
                        ),
                        Text(
                          "Screen Music",
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
                          }),
                    ),
                  ],
                ),
                // SizedBox(
                // height: 5.0,
                // ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.translate_outlined,
                          size: 30.0,
                        ),
                        SizedBox(
                          width: 15.0,
                        ),
                        Text(
                          "Language",
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
                                });
                              },
                              children: List<Widget>.generate(
                                  _fruitNames.length, (int index) {
                                return Center(child: Text(_fruitNames[index]));
                              }),
                            ),
                          ),
                          child: Text(
                            _fruitNames[_selectedFruit],
                            // style: TextStyle(
                            // fontWeight: FontWeight.bold,
                            // ),
                          ),
                        ),
                        // Icon(
                        //   Icons.arrow_right_outlined,
                        //   size: 25.0,
                        // )
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
          Divider(
            thickness: 5.0,
            color: Theme.of(context).dividerColor.withOpacity(0.05),
          ),
          Container(
            padding: EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.symmetric(
                    vertical: 10.0,
                  ),
                  child: Text(
                    "App Support",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize:
                          Theme.of(context).textTheme.titleMedium!.fontSize,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(
                    vertical: 10.0,
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.star_border_outlined,
                        size: 30.0,
                      ),
                      SizedBox(
                        width: 15.0,
                      ),
                      Text("Send Feedback")
                    ],
                  ),
                ),
                Divider(),
                Container(
                  margin: EdgeInsets.symmetric(
                    vertical: 10.0,
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.description_outlined,
                        size: 30.0,
                      ),
                      SizedBox(
                        width: 15.0,
                      ),
                      Text("Terms and Conditions")
                    ],
                  ),
                ),
                Divider(),
                Container(
                  margin: EdgeInsets.symmetric(
                    vertical: 10.0,
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.remove_red_eye_outlined,
                        size: 30.0,
                      ),
                      SizedBox(
                        width: 15.0,
                      ),
                      Text("Privacy Policy")
                    ],
                  ),
                ),
                Divider(),
                Container(
                  margin: EdgeInsets.symmetric(
                    vertical: 10.0,
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.info_outline,
                        size: 30.0,
                      ),
                      SizedBox(
                        width: 15.0,
                      ),
                      Text("About CitizenApp")
                    ],
                  ),
                ),
                Divider(),
                Container(
                  margin: EdgeInsets.symmetric(
                    vertical: 10.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Icon(
                            Icons.copy,
                            size: 30.0,
                          ),
                          SizedBox(
                            width: 15.0,
                          ),
                          Text("App Version")
                        ],
                      ),
                      Container(
                        child: Text(
                          "v3.3.1",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(
            thickness: 5.0,
            color: Theme.of(context).dividerColor.withOpacity(0.05),
          ),
        ],
      ),
    );
  }
}
