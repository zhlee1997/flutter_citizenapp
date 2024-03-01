import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/announcement_model.dart';
import '../../utils/app_localization.dart';
import '../../utils/image_network_helper.dart';
import '../../providers/language_provider.dart';
import '../../services/announcement_services.dart';

class AnnouncementDetailScreen extends StatefulWidget {
  static const routeName = 'announcement-detail-screen';

  const AnnouncementDetailScreen({super.key});

  @override
  State<AnnouncementDetailScreen> createState() =>
      _AnnouncementDetailScreenState();
}

class _AnnouncementDetailScreenState extends State<AnnouncementDetailScreen> {
  AnnouncementModel? _announcement;
  late String? iconPath;
  late var arguments;

  List<String> photoCarousel = [];
  int pageNumber = 1;

  final AnnouncementServices _announcementServices = AnnouncementServices();

  /// Get announcement details when screen first renders
  /// Using queryAnnouncementDetail API
  Future<void> getAnnouncementDetail() async {
    var response =
        await _announcementServices.queryAnnouncementDetail(arguments['id']);

    if (response['status'] == '200') {
      setState(() {
        _announcement = AnnouncementModel.fromJson(response['data']);

        if (_announcement != null) {
          List<String> normalPaths = [];
          _announcement!.attachmentDtoList.forEach((element) {
            if (element.attFileType == '3') {
              iconPath = element.attFilePath;
            }
            if (element.attFileType == '2') {
              normalPaths.add(element.attFilePath);
            }
          });
          photoCarousel = normalPaths;
        }
      });
    }
  }

  /// Determine the language of the announcement title based on current language code
  ///
  /// Returns the announcement title
  String getAnnouncementTitle() {
    String languageCode =
        Provider.of<LanguageProvider>(context).locale.languageCode;
    if (languageCode == 'en') {
      return _announcement!.annTitleEn;
    } else if (languageCode == 'zh') {
      return _announcement!.annTitleZh != ''
          ? _announcement!.annTitleZh
          : _announcement!.annTitleEn;
    } else {
      return _announcement!.annTitleMs != ''
          ? _announcement!.annTitleMs
          : _announcement!.annTitleEn;
    }
  }

  /// Determine the language of the announcement content based on current language code
  ///
  /// Returns the announcement content
  String getAnnouncementContent() {
    String languageCode =
        Provider.of<LanguageProvider>(context).locale.languageCode;
    if (languageCode == 'en') {
      return _announcement!.annMessageEn;
    } else if (languageCode == 'zh') {
      return _announcement!.annMessageZh != ''
          ? _announcement!.annTitleZh
          : _announcement!.annTitleEn;
    } else {
      return _announcement!.annMessageMs != ''
          ? _announcement!.annTitleMs
          : _announcement!.annTitleEn;
    }
  }

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      // Accessing the arguments passed to the modal route
      arguments = ModalRoute.of(context)!.settings.arguments;
      getAnnouncementDetail();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final totalNumber = photoCarousel.length;

    // TODO: should show no data illustration
    if (_announcement == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
              AppLocalization.of(context)!.translate('announcement_detail')!),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
            AppLocalization.of(context)!.translate('announcement_detail')!),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            if (photoCarousel.length > 0)
              Container(
                  height: screenSize.height * 0.3,
                  child: Stack(
                    children: <Widget>[
                      PageView.builder(
                        itemCount: photoCarousel.length,
                        onPageChanged: (int currentPageNumber) {
                          setState(() {
                            pageNumber = currentPageNumber + 1;
                          });
                        },
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemBuilder: (ctx, idx) =>
                            ImageNetworkHelper.imageNetworkBuilder(
                          url: photoCarousel[idx],
                          height: screenSize.height * 0.25,
                          width: double.infinity,
                          fit: BoxFit.fill,
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Chip(
                          label: Text('$pageNumber/$totalNumber'),
                        ),
                      ),
                    ],
                  )),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 15.0,
                vertical: 10.0,
              ),
              child: Text(
                getAnnouncementTitle(),
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            arguments['isMajor']
                ? Container()
                : Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15.0,
                      vertical: 10.0,
                    ),
                    child: ListTile(
                      leading: iconPath == null
                          ? Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(width: 0.5),
                              ),
                              child: Icon(
                                Icons.person,
                                color: Colors.black54,
                                size: 25,
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(width: 0.5),
                              ),
                              child: CircleAvatar(
                                radius: 30.0,
                                backgroundColor: Colors.transparent,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(30),
                                  child: CachedNetworkImage(
                                    imageUrl: iconPath!,
                                  ),
                                ),
                              ),
                            ),
                      title: Text(
                        _announcement!.annAuthor,
                        style: TextStyle(
                          fontSize: 18.0,
                        ),
                      ),
                      subtitle: Container(
                        margin: const EdgeInsets.only(top: 5.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              _announcement!.annStartDate,
                              style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 30.0,
                vertical: 15.0,
              ),
              child: Linkify(
                onOpen: (link) async {
                  final Uri uri = Uri.parse(link.url);
                  await launchUrl(uri);
                },
                text: getAnnouncementContent(),
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontSize: 18.0,
                  height: 1.7,
                ),
              ),
            ),
            SizedBox(
              height: 50,
            )
          ],
        ),
      ),
    );
  }
}
