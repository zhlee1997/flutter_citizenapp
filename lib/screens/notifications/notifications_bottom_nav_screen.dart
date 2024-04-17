import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../providers/auth_provider.dart';
import '../../providers/inbox_provider.dart';
import '../../widgets/sarawakid/login_full_bottom_modal.dart';
import '../../services/inbox_services.dart';
import '../../services/announcement_services.dart';
import '../../models/inbox_model.dart';
import '../../models/announcement_model.dart';
import '../../models/major_announcement_model.dart';
import '../announcement/announcement_detail_screen.dart';
import './notifications_detail_screen.dart';
import '../../utils/app_localization.dart';
import '../../utils/global_dialog_helper.dart';

class NotificationsBottomNavScreen extends StatefulWidget {
  final void Function(bool) setNotificationsState;

  const NotificationsBottomNavScreen({
    required this.setNotificationsState,
    super.key,
  });

  @override
  State<NotificationsBottomNavScreen> createState() =>
      _NotificationsBottomNavScreenState();
}

class _NotificationsBottomNavScreenState
    extends State<NotificationsBottomNavScreen> with TickerProviderStateMixin {
  // Default: select Notifications Tab
  int selected = 1;
  bool _isLoading = false;

  bool _noMoreData = false;
  List<InboxModel> _inboxes = [];
  late ScrollController _scrollController;
  int _pageLocal = 1;
  late SnackBar snackBar;

  bool _majorIsLoading = false;
  bool _majorNoMoreData = false;
  List<MajorAnnouncementModel> _majorAnnouncements = [];
  late ScrollController _majorScrollController;
  int _majorPage = 1;

  final dateFormat = DateFormat('dd MMM');
  final f = DateFormat('yyyy-MM-dd');

  /// Update the read status of message when message is read
  /// Using modifyByIdSelective API
  ///
  /// Receives [idx] as the index of inbox list
  Future<void> inboxRead(int idx) async {
    InboxModel inbox = _inboxes[idx];
    // Navigate to announcement detail screen
    if (inbox.msgType == "7") {
      Map<String, dynamic> msgObj = json.decode(inbox.msgContext);
      Navigator.of(context)
          .pushNamed(AnnouncementDetailScreen.routeName, arguments: {
        'id': msgObj['msgId'],
        'isMajor': true,
      });
    } else {
      Navigator.of(context).pushNamed(
        NotificationsDetailScreen.routeName,
        arguments: inbox.rcvId,
      );
    }

    // modify message status
    try {
      if (inbox.msgReadStatus == "1") {
        return;
      }
      var response = await InboxServices().modifyByIdSelective(inbox.rcvId);
      if (response['status'] == '200') {
        Provider.of<InboxProvider>(context, listen: false).refreshCount();
        setState(() {
          inbox.msgReadStatus = "1";
        });
      }
    } catch (e) {
      print('inboxRead fail');
      throw e;
    }
  }

  /// Delete a message
  /// Using removeById API
  ///
  /// Receives [idx] as the index of inbox list
  Future<void> remove(int idx) async {
    try {
      InboxModel inbox = _inboxes[idx];
      var response = await InboxServices().removeById(inbox.rcvId);
      if (response['status'] == '200') {
        Provider.of<InboxProvider>(context, listen: false).refreshCount();
        setState(() {
          _inboxes.removeAt(idx);
        });
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else {}
    } catch (e) {
      print('delete message failed');
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

  // Announcement API => announcement/queryPageList (annType = 3)
  Future<void> getMajorAnnouncements(int page) async {
    if (_majorIsLoading) {
      return;
    }
    _majorIsLoading = true;
    try {
      var response = await AnnouncementServices().queryPageList(
        '1',
        annType: '3',
        nowTime: f.format(DateTime.now()),
      );
      if (response['status'] == '200') {
        var data = response['data']['list'] as List;

        setState(() {
          if (data.length < 20) {
            _majorNoMoreData = true;
          }

          List<AnnouncementModel> announcements =
              data.map((e) => AnnouncementModel.fromJson(e)).toList();
          announcements.forEach((AnnouncementModel element) {
            var m = MajorAnnouncementModel(
              sid: element.annId,
              image: element.attachmentDtoList.length > 0
                  ? element.attachmentDtoList[0].attFilePath.toString()
                  : '',
              title: AnnouncementModel.getAnnouncementTitle(
                context,
                element,
                isMajorAnnouncement: true,
              ),
              description: AnnouncementModel.getAnnouncementContent(
                context,
                element,
                isMajorAnnouncement: true,
              ),
              date: element.annStartDate,
            );
            _majorAnnouncements.add(m);
          });
        });
      }
      _majorIsLoading = false;
    } catch (e) {
      _majorIsLoading = false;
      print("getMajorAnnouncements fail");
    }
  }

  /// Pull to refresh notifications
  Future<void> _onRefresh() async {
    try {
      _pageLocal = 1;
      await Provider.of<InboxProvider>(context, listen: false)
          .refreshNotificationsProvider();
    } catch (e) {
      print("onRefresh Notification error");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          var maxScroll = _scrollController.position.maxScrollExtent;
          var pixels = _scrollController.position.pixels;
          if (maxScroll == pixels && !_noMoreData) {
            _pageLocal++;
            Provider.of<InboxProvider>(context, listen: false)
                .setNotificationPage(_pageLocal);
            Provider.of<InboxProvider>(context, listen: false)
                .queryNotificationsProvider();
          }
        });
      });
    _majorScrollController = ScrollController()
      ..addListener(() {
        setState(() {
          var maxScroll = _majorScrollController.position.maxScrollExtent;
          var pixels = _majorScrollController.position.pixels;
          if (maxScroll == pixels && !_majorNoMoreData) {
            _majorPage++;
            getMajorAnnouncements(_majorPage);
          }
        });
      });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
        await getMajorAnnouncements(_majorPage);
        await Provider.of<InboxProvider>(context, listen: false)
            .refreshNotificationsProvider();
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    _inboxes = Provider.of<InboxProvider>(context).inboxes;
    _noMoreData = Provider.of<InboxProvider>(context).noMoreData;
    snackBar = SnackBar(
      content: Text(AppLocalization.of(context)!.translate('message_deleted')!),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _scrollController.dispose();
    _majorScrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Provider.of<AuthProvider>(context).isAuth
        ? Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Row(
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: ElevatedButton(
                            onPressed: () {
                              widget.setNotificationsState(false);
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
                                fontWeight:
                                    selected == 0 ? FontWeight.bold : null,
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
                              widget.setNotificationsState(true);
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
                                fontWeight:
                                    selected == 1 ? FontWeight.bold : null,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: selected == 0
                          ? _majorAnnouncements.length == 0
                              ? GlobalDialogHelper().buildCenterNoData(
                                  context,
                                  message: "No major announcements",
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: _majorAnnouncements.length,
                                  itemBuilder: ((context, index) {
                                    return ListTile(
                                      onTap: () {
                                        Navigator.of(context).pushNamed(
                                          AnnouncementDetailScreen.routeName,
                                          arguments: {
                                            'id':
                                                _majorAnnouncements[index].sid,
                                            'isMajor': true
                                          },
                                        ).then((value) {
                                          if (value == true) {
                                            Navigator.of(context).pop();
                                          }
                                        });
                                      },
                                      leading: Container(
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
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                      ),
                                      title: Text(
                                        _majorAnnouncements[index].title,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      subtitle: Text(
                                        _majorAnnouncements[index].description,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                      trailing: Text(
                                        dateFormat.format(DateTime.parse(
                                            _majorAnnouncements[index].date)),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  }),
                                )
                          : _inboxes.length == 0
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    GlobalDialogHelper().buildCenterNoData(
                                      context,
                                      message: AppLocalization.of(context)!
                                          .translate('no_inbox_data')!,
                                    ),
                                    const SizedBox(
                                      height: 20.0,
                                    ),
                                    ElevatedButton(
                                      onPressed: _onRefresh,
                                      child: Text("Refresh"),
                                    )
                                  ],
                                )
                              : RefreshIndicator(
                                  onRefresh: _onRefresh,
                                  child: ListView.builder(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    controller: _scrollController,
                                    // shrinkWrap: true,
                                    itemCount: _inboxes.length + 1,
                                    itemBuilder: ((context, index) {
                                      if (_inboxes.length == index) {
                                        return GlobalDialogHelper()
                                            .buildLinearProgressIndicator(
                                          context: context,
                                          currentLength: _inboxes.length,
                                          noMoreData: _noMoreData,
                                          handleLoadMore: () async {
                                            await Provider.of<InboxProvider>(
                                                    context,
                                                    listen: false)
                                                .queryNotificationsProvider();
                                          },
                                        );
                                      } else {
                                        return Slidable(
                                          endActionPane: ActionPane(
                                            motion: const StretchMotion(),
                                            extentRatio: 0.3,
                                            children: [
                                              SlidableAction(
                                                label:
                                                    AppLocalization.of(context)!
                                                        .translate('delete')!,
                                                backgroundColor: Colors.red,
                                                icon: Icons.delete,
                                                onPressed:
                                                    (BuildContext context) {
                                                  remove(index);
                                                },
                                              ),
                                            ],
                                          ),
                                          child: ListTile(
                                            onTap: () {
                                              // Get message detail
                                              inboxRead(index);
                                            },
                                            leading: Badge(
                                              isLabelVisible: _inboxes[index]
                                                      .msgReadStatus ==
                                                  "0",
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
                                                // TODO: change icon accordingly
                                                child: Icon(
                                                  Icons.payment,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
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
                                                _inboxes[index].msgType == "1"
                                                    ? json.decode(_inboxes[
                                                            index]
                                                        .msgContext)["content"]
                                                    : json.decode(_inboxes[
                                                            index]
                                                        .msgContext)["title"],
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w300,
                                                )),
                                            trailing: Text(
                                              dateFormat.format(DateTime.parse(
                                                  _inboxes[index].createTime)),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                    }),
                                  ),
                                ),
                    )
                  ],
                ),
              ),
              if (_isLoading)
                const Opacity(
                  opacity: 0.5,
                  child: ModalBarrier(dismissible: false, color: Colors.black),
                ),
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ),
            ],
          )
        : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text("Login now to view your notifications"),
                const SizedBox(
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
