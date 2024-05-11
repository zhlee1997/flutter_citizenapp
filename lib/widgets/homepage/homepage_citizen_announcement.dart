import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../models/announcement_model.dart';
import '../../providers/language_provider.dart';
import './homepage_citizen_card.dart';
import '../../screens/announcement/announcement_detail_screen.dart';

class HomepageCitizenAnnouncement extends StatelessWidget {
  final bool citizenShimmer;
  final List<AnnouncementModel> citizenAnnouncements;

  const HomepageCitizenAnnouncement({
    required this.citizenShimmer,
    required this.citizenAnnouncements,
    super.key,
  });

  // return title of announcement based on language code
  String getAnnouncementTitle(int idx, BuildContext context) {
    String languageCode =
        Provider.of<LanguageProvider>(context).locale.languageCode;
    if (languageCode == 'en') {
      return citizenAnnouncements[idx].annTitleEn;
    } else if (languageCode == 'zh') {
      return citizenAnnouncements[idx].annTitleZh != ''
          ? citizenAnnouncements[idx].annTitleZh
          : citizenAnnouncements[idx].annTitleEn;
    } else {
      return citizenAnnouncements[idx].annTitleMs != ''
          ? citizenAnnouncements[idx].annTitleMs
          : citizenAnnouncements[idx].annTitleEn;
    }
  }

  String getAnnouncementContent(int idx, BuildContext context) {
    String languageCode =
        Provider.of<LanguageProvider>(context).locale.languageCode;
    if (languageCode == 'en') {
      return citizenAnnouncements[idx].annMessageEn;
    } else if (languageCode == 'zh') {
      return citizenAnnouncements[idx].annMessageZh != ''
          ? citizenAnnouncements[idx].annMessageZh
          : citizenAnnouncements[idx].annMessageEn;
    } else {
      return citizenAnnouncements[idx].annMessageMs != ''
          ? citizenAnnouncements[idx].annMessageMs
          : citizenAnnouncements[idx].annMessageEn;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    if (citizenAnnouncements.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(
          vertical: 10.0,
        ),
        child: Center(
          child: Column(
            children: <Widget>[
              SvgPicture.asset(
                "assets/images/svg/no_data.svg",
                width: screenSize.width * 0.25,
                height: screenSize.width * 0.25,
                semanticsLabel: 'No Data Logo',
              ),
              const SizedBox(
                height: 10.0,
              ),
              const Text("No announcement"),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 5.0,
        mainAxisSpacing: 5.0,
        childAspectRatio: 0.75 / 1,
      ),
      itemCount: citizenShimmer ? 6 : citizenAnnouncements.length,
      itemBuilder: (ctx, i) {
        List<AttachmentDtoList> citizenPhoto = citizenAnnouncements[i]
            .attachmentDtoList
            .where((photo) => photo.attFileType == '2')
            .toList();
        if (citizenShimmer) {
          return Shimmer.fromColors(
            baseColor: Colors.white,
            highlightColor: Colors.transparent,
            child: const HomepageCitizenCard(
              useDefaultImage: true,
              imageUrl: "assets/images/icon/sioc.png",
              title: "Loading...",
              subtitle: "Loading...",
              onTap: null,
            ),
          );
        }
        return citizenPhoto.isEmpty
            ? HomepageCitizenCard(
                useDefaultImage: true,
                imageUrl: "assets/images/icon/sioc.png",
                title: getAnnouncementTitle(i, context),
                subtitle: getAnnouncementContent(i, context),
                onTap: () => Navigator.of(context).pushNamed(
                  AnnouncementDetailScreen.routeName,
                  arguments: {
                    'id': citizenAnnouncements[i].annId,
                    'isMajor': false
                  },
                ),
              )
            : HomepageCitizenCard(
                imageUrl: citizenPhoto[0].attFilePath,
                title: getAnnouncementTitle(i, context),
                subtitle: getAnnouncementContent(i, context),
                onTap: () => Navigator.of(context).pushNamed(
                  AnnouncementDetailScreen.routeName,
                  arguments: {
                    'id': citizenAnnouncements[i].annId,
                    'isMajor': false
                  },
                ),
              );
      },
    );
  }
}
