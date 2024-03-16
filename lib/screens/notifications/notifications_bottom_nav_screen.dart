import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/sarawakid/login_full_bottom_modal.dart';

class NotificationsBottomNavScreen extends StatefulWidget {
  static const String routeName = 'notifications-bottom-nav-screen';

  const NotificationsBottomNavScreen({super.key});

  @override
  State<NotificationsBottomNavScreen> createState() =>
      _NotificationsBottomNavScreenState();
}

class _NotificationsBottomNavScreenState
    extends State<NotificationsBottomNavScreen> {
  int selected = 1;

  final List<String> items_major =
      List.generate(5, (index) => 'Major Item $index');
  final List<String> items_notification =
      List.generate(5, (index) => 'Notification Item $index');

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

  @override
  Widget build(BuildContext context) {
    return Provider.of<AuthProvider>(context).isAuth
        ? Container(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selected = 0;
                          });
                        },
                        child: Text(
                          "Major",
                          style: TextStyle(
                            color: selected == 0 ? Colors.white : Colors.black,
                            fontWeight: selected == 0 ? FontWeight.bold : null,
                          ),
                        ),
                        style: selected == 0
                            ? ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                              )
                            : ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary
                                    .withOpacity(0.8),
                              ),
                      ),
                    ),
                    SizedBox(
                      width: 8.0,
                    ),
                    Expanded(
                      flex: 1,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selected = 1;
                          });
                        },
                        child: Text(
                          "Notifications",
                          style: TextStyle(
                            color: selected == 1 ? Colors.white : Colors.black,
                            fontWeight: selected == 1 ? FontWeight.bold : null,
                          ),
                        ),
                        style: selected == 1
                            ? ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                              )
                            : ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary
                                    .withOpacity(0.8),
                              ),
                      ),
                    ),
                  ],
                ),
                Container(
                  child: selected == 0
                      ? ListView.builder(
                          shrinkWrap: true,
                          itemCount: items_major.length,
                          itemBuilder: ((context, index) {
                            return ListTile(
                              leading: Badge(
                                smallSize: 10.0,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .inversePrimary
                                        .withOpacity(0.7),
                                  ),
                                  child: Icon(
                                    Icons.payment,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                              title: Text(
                                items_major[index],
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                "Get an instant Travel Insurance quote now.",
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Text(
                                "20 Jan",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: items_notification.length,
                          itemBuilder: ((context, index) {
                            return ListTile(
                              leading: Badge(
                                smallSize: 10.0,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .inversePrimary
                                        .withOpacity(0.7),
                                  ),
                                  child: Icon(
                                    Icons.payment,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                              title: Text(
                                items_notification[index],
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                "Get an instant Travel Insurance quote now.",
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Text(
                                "20 Jan",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }),
                        ),
                )
              ],
            ),
          )
        : Container(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("Login now to view your notifications"),
                  SizedBox(
                    height: 20.0,
                  ),
                  ElevatedButton(
                    onPressed: () => _handleFullScreenLoginBottomModal(context),
                    child: Text("Login Now"),
                  )
                ],
              ),
            ),
          );
  }
}
