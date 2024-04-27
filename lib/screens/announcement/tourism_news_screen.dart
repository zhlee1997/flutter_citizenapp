import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../models/announcement_model.dart';
import '../../services/announcement_services.dart';
import '../../providers/language_provider.dart';
import './announcement_detail_screen.dart';
import '../../utils/global_dialog_helper.dart';

class TourismNewsScreen extends StatefulWidget {
  static const String routeName = "tourism-news-screen";

  const TourismNewsScreen({super.key});

  @override
  State<TourismNewsScreen> createState() => _TourismNewsScreenState();
}

class _TourismNewsScreenState extends State<TourismNewsScreen> {
  var _isLoading = false;
  late bool _isInitLoading;

  int _page = 1;
  bool _noMoreData = false;
  late ScrollController _scrollController;

  List<AnnouncementModel> _news = [];

  Future<void> _getTourismNews(int page) async {
    if (_isLoading) {
      return;
    }
    _isLoading = true;
    try {
      var response =
          await AnnouncementServices().queryPageList('$page', annType: '2');

      if (response['status'] == '200') {
        var data = response['data']['list'] as List;
        setStateIfMounted(() {
          if (data.length < 20) {
            _noMoreData = true;
          }

          if (page == 1) {
            _news = data.map((e) => AnnouncementModel.fromJson(e)).toList();
          } else {
            _news.addAll(
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
      return _news[idx].annTitleEn;
    } else if (languageCode == 'zh') {
      return _news[idx].annTitleZh != ''
          ? _news[idx].annTitleZh
          : _news[idx].annTitleEn;
    } else {
      return _news[idx].annTitleMs != ''
          ? _news[idx].annTitleMs
          : _news[idx].annTitleEn;
    }
  }

  String getAnnouncementDescription(int idx) {
    String languageCode =
        Provider.of<LanguageProvider>(context).locale.languageCode;
    if (languageCode == 'en') {
      return _news[idx].annMessageEn;
    } else if (languageCode == 'zh') {
      return _news[idx].annMessageZh != ''
          ? _news[idx].annMessageZh
          : _news[idx].annMessageEn;
    } else {
      return _news[idx].annMessageMs != ''
          ? _news[idx].annMessageMs
          : _news[idx].annMessageEn;
    }
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  void _handleNavigateToAnnouncementDetail(BuildContext context, int index) {
    Navigator.of(context).pushNamed(
      AnnouncementDetailScreen.routeName,
      arguments: {
        'id': _news[index].annId,
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
            _getTourismNews(_page);
          }
        });
      });
    _getTourismNews(_page);
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
                    title: const Text("Tourism News"),
                    background: Image.asset(
                      "assets/images/pictures/announcement/tourism_news.jpg",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.all(8.0),
                  sliver: SliverList.separated(
                    itemCount: _news.length,
                    itemBuilder: (context, index) {
                      AnnouncementModel news = _news[index];
                      List<AttachmentDtoList> tourismPhoto = news
                          .attachmentDtoList
                          .where((photo) => photo.attFileType == '2')
                          .toList();
                      return Container(
                        // margin: EdgeInsets.only(top: 10.0),
                        child: ListTile(
                          leading: SizedBox(
                            width: screenSize.width * 0.25,
                            height: screenSize.width * 0.25,
                            child: tourismPhoto.isNotEmpty
                                ? Image.network(
                                    tourismPhoto[0].attFilePath,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, url, error) =>
                                        Image.asset(
                                      "assets/images/icon/sioc.png",
                                      fit: BoxFit.fill,
                                    ),
                                  )
                                : Image.asset(
                                    "assets/images/icon/sioc.png",
                                    fit: BoxFit.fill,
                                  ),
                          ),
                          title: Text(
                            getAnnouncementTitle(index),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          subtitle: Text(
                            getAnnouncementDescription(index),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
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
                )
              ],
            ),
    );
  }
}
