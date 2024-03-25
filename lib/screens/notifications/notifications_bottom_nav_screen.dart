import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/sarawakid/login_full_bottom_modal.dart';
import '../../services/inbox_services.dart';
import '../../models/inbox_model.dart';

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
  bool _isLoading = false;
  bool _noMoreData = false;
  List<InboxModel> _inboxes = [];
  late bool _isInitLoading;
  late ScrollController _scrollController;
  int _page = 1;

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

  /// Get inbox list when screen first renders
  /// When infinite scrolling
  /// Using queryPageList API
  ///
  /// Receives [page] as the number of pagination
  Future<void> getNotifications(int page) async {
    if (_isLoading) {
      return;
    }
    _isLoading = true;
    try {
      var response = await InboxServices().queryInboxPageList('$page');
      if (response['status'] == '200') {
        var data = response['data']['list'] as List;
        setState(() {
          if (data.length < 20) {
            _noMoreData = true;
          }

          if (page == 1) {
            _inboxes = data.map((e) => InboxModel.fromJson(e)).toList();
          } else {
            _inboxes.addAll(data.map((e) => InboxModel.fromJson(e)).toList());
          }
        });
      }
      _isLoading = false;

      if (_isInitLoading) {
        setState(() {
          _isInitLoading = false;
        });
      }
    } catch (e) {
      _isLoading = false;
      print('getNotifications fail');
      throw e;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _isInitLoading = true;
    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          var maxScroll = _scrollController.position.maxScrollExtent;
          var pixels = _scrollController.position.pixels;
          if (maxScroll == pixels && !_noMoreData) {
            _page++;
            getNotifications(_page);
          }
        });
      });
    getNotifications(_page);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _scrollController.dispose();
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
                        child: Text(
                          "Major",
                          style: TextStyle(
                            color: selected == 0
                                ? Colors.white
                                : Theme.of(context).colorScheme.secondary,
                            fontWeight: selected == 0 ? FontWeight.bold : null,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
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
                        child: Text(
                          "Notifications",
                          style: TextStyle(
                            color: selected == 1
                                ? Colors.white
                                : Theme.of(context).colorScheme.secondary,
                            fontWeight: selected == 1 ? FontWeight.bold : null,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  child: selected == 0
                      ? ListView.builder(
                          controller: _scrollController,
                          shrinkWrap: true,
                          itemCount: items_major.length,
                          itemBuilder: ((context, index) {
                            return ListTile(
                              leading: Badge(
                                smallSize: 8.0,
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
                                    Icons.announcement_outlined,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                              title: Text(
                                items_major[index],
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Text(
                                "Get an instant Travel Insurance quote now.",
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.w300,
                                ),
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
                          itemCount: _inboxes.length,
                          itemBuilder: ((context, index) {
                            return ListTile(
                              onTap: () {
                                // TODO: Get message detail
                                // inboxRead(index);
                              },
                              leading: Badge(
                                smallSize: 8.0,
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
                                _inboxes[index].msgTitle,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Text(
                                  json.decode(
                                      _inboxes[index].msgContext)["content"],
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w300,
                                  )),
                              trailing: Text(
                                _inboxes[index].createTime,
                                style: const TextStyle(
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
        : Center(
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
          );
  }
}
