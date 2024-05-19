import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

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
  String? iconPath;
  late var arguments;

  List<String> photoCarousel = [];
  int pageNumber = 1;

  final AnnouncementServices _announcementServices = AnnouncementServices();

  /// Get announcement details when screen first renders
  /// Using queryAnnouncementDetail API
  Future<void> getAnnouncementDetail() async {
    try {
      var response =
          await _announcementServices.queryAnnouncementDetail(arguments['id']);

      if (response['status'] == '200' && mounted) {
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
    } catch (e) {
      print("getAnnouncementDetail error: ${e.toString()}");
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
          ? _announcement!.annMessageZh
          : _announcement!.annMessageEn;
    } else {
      return _announcement!.annMessageMs != ''
          ? _announcement!.annMessageMs
          : _announcement!.annMessageEn;
    }
  }

  String formatDateTime(String dateTime) {
    final DateFormat formatter = DateFormat("E, MMM d, yyyy");
    final String formattedDate = formatter.format(DateTime.parse(dateTime));
    return formattedDate;
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                left: 20.0,
                right: 20.0,
                // bottom: 10.0,
                top: 15.0,
              ),
              child: Text(
                getAnnouncementTitle(),
                textAlign: TextAlign.left,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(fontWeight: FontWeight.bold),
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
                          ? CircleAvatar(
                              radius: 23.0,
                              child: Icon(
                                Icons.person,
                                color: Theme.of(context).colorScheme.primary,
                                size: 28.0,
                              ),
                            )
                          : CircleAvatar(
                              backgroundColor:
                                  Theme.of(context).colorScheme.background,
                              radius: 23.0,
                              child: CachedNetworkImage(
                                placeholder: (BuildContext context,
                                        String url) =>
                                    const CircularProgressIndicator.adaptive(
                                  strokeWidth: 2.0,
                                ),
                                imageUrl: iconPath!,
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    CircleAvatar(
                                  radius: 23.0,
                                  child: Icon(
                                    Icons.error,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    size: 28.0,
                                  ),
                                ),
                              ),
                            ),
                      title: Text(
                        "By ${_announcement!.annAuthor}",
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "Published on ${formatDateTime(_announcement!.annStartDate)}",
                        style: TextStyle(
                          fontSize:
                              Theme.of(context).textTheme.bodyMedium!.fontSize,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),
            if (photoCarousel.isNotEmpty)
              SizedBox(
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
                ),
              ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: photoCarousel.isNotEmpty ? 25.0 : 5.0,
              ),
              child: Linkify(
                onOpen: (link) async {
                  final Uri uri = Uri.parse(link.url);
                  await launchUrl(uri);
                },
                text: getAnnouncementContent(),
                style: const TextStyle(
                  fontSize: 18.0,
                  height: 1.7,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(
              height: 50,
            )
          ],
        ),
      ),
    );
  }
}
