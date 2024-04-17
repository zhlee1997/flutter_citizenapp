import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../models/announcement_model.dart';
import '../../services/announcement_services.dart';
import '../../providers/language_provider.dart';
import './announcement_detail_screen.dart';
import '../../utils/global_dialog_helper.dart';

class CitizenAnnouncementsScreen extends StatefulWidget {
  static const String routeName = "citizen-announcements-screen";

  const CitizenAnnouncementsScreen({super.key});

  @override
  State<CitizenAnnouncementsScreen> createState() =>
      _CitizenAnnouncementsScreenState();
}

class _CitizenAnnouncementsScreenState
    extends State<CitizenAnnouncementsScreen> {
  var _isLoading = false;
  late bool _isInitLoading;

  int _page = 1;
  bool _noMoreData = false;
  late ScrollController _scrollController;

  List<AnnouncementModel> _announcements = [];

  Future<void> _getCitizenAnnouncements(int page) async {
    if (_isLoading) {
      return;
    }
    _isLoading = true;
    try {
      var response =
          await AnnouncementServices().queryPageList('$page', annType: '1');

      if (response['status'] == '200') {
        var data = response['data']['list'] as List;
        setStateIfMounted(() {
          if (data.length < 20) {
            _noMoreData = true;
          }

          if (page == 1) {
            _announcements =
                data.map((e) => AnnouncementModel.fromJson(e)).toList();
          } else {
            _announcements.addAll(
                data.map((e) => AnnouncementModel.fromJson(e)).toList());
          }
        });
      }
      _isLoading = false;
      _isInitLoading = false;
    } catch (e) {
      print("_getCitizenAnnouncements error: ${e.toString()}");
      _isLoading = false;
      _isInitLoading = false;
    }
  }

  /// Determine the language of the announcement title based on current language code
  ///
  /// Receives [idx] as the index of announcement list
  /// Returns the announcement title
  String getAnnouncementTitle(int idx) {
    String languageCode =
        Provider.of<LanguageProvider>(context).locale.languageCode;
    if (languageCode == 'en') {
      return _announcements[idx].annTitleEn;
    } else if (languageCode == 'zh') {
      return _announcements[idx].annTitleZh != ''
          ? _announcements[idx].annTitleZh
          : _announcements[idx].annTitleEn;
    } else {
      return _announcements[idx].annTitleMs != ''
          ? _announcements[idx].annTitleMs
          : _announcements[idx].annTitleEn;
    }
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  void _handleNavigateToAnnouncementDetail(BuildContext context, int index) {
    Navigator.of(context).pushNamed(
      AnnouncementDetailScreen.routeName,
      arguments: {
        'id': _announcements[index].annId,
        'isMajor': false,
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // TODO: GET CITIZEN ANN API
    // TODO: LOADING STATE
    // TODO: INFINITE SCROLL
    _isInitLoading = true;
    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          // infinite scrolling
          var maxScroll = _scrollController.position.maxScrollExtent;
          var pixels = _scrollController.position.pixels;
          if (maxScroll == pixels && !_noMoreData) {
            // execute when scroll up
            _page++;
            _getCitizenAnnouncements(_page);
          }
        });
      });
    _getCitizenAnnouncements(_page);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: _isInitLoading
          ? GlobalDialogHelper().showLoadingSpinner()
          : CustomScrollView(
              controller: _scrollController,
              slivers: <Widget>[
                SliverAppBar(
                  expandedHeight: screenSize.height * 0.25,
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  flexibleSpace: FlexibleSpaceBar(
                    title: const Text("Citizen Announcements"),
                    background: Image.asset(
                      "assets/images/pictures/announcement/citizen_announcement.jpg",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(8.0),
                  sliver: SliverList.separated(
                    itemCount: _announcements.length,
                    itemBuilder: (context, index) {
                      AnnouncementModel announcement = _announcements[index];
                      List<AttachmentDtoList> citizenPhoto = announcement
                          .attachmentDtoList
                          .where((photo) => photo.attFileType == '2')
                          .toList();

                      return Container(
                        margin: const EdgeInsets.only(top: 10.0),
                        child: ListTile(
                          leading: SizedBox(
                            width: screenSize.width * 0.25,
                            height: screenSize.width * 0.25,
                            child: citizenPhoto.isNotEmpty
                                ? Image.network(
                                    citizenPhoto[0].attFilePath,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, url, error) =>
                                        SvgPicture.asset(
                                      "assets/images/svg/undraw_page_not_found.svg",
                                      fit: BoxFit.cover,
                                      semanticsLabel: 'Not Found Logo',
                                    ),
                                  )
                                : Image.asset(
                                    "assets/images/icon/sioc.png",
                                    // fit: BoxFit.cover,
                                  ),
                          ),
                          title: Text(
                            getAnnouncementTitle(index),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          onTap: () {
                            // navigate to announcement detail screen
                            _handleNavigateToAnnouncementDetail(context, index);
                          },
                        ),
                      );
                    },
                    separatorBuilder: (context, index) => const Divider(
                      thickness: 0.5,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
