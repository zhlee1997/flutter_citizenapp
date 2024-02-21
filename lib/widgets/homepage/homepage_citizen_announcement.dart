import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../models/announcement_model.dart';
import "../../providers/language_provider.dart";
import './homepage_citizen_card.dart';

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

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    // if (citizenShimmer) {
    //   return Container(
    //     padding: const EdgeInsets.only(
    //       left: 15.0,
    //       right: 15.0,
    //     ),
    //     child: Shimmer.fromColors(
    //       child: ListView.separated(
    //         itemBuilder: (ctx, i) => ListTile(
    //           title: Container(
    //             height: 25,
    //             color: Colors.white,
    //           ),
    //           subtitle: Container(
    //             color: Colors.white,
    //             height: 15,
    //           ),
    //         ),
    //         shrinkWrap: true,
    //         itemCount: 3,
    //         separatorBuilder: (ctx, i) => Padding(
    //           padding: const EdgeInsets.all(4.0),
    //         ),
    //       ),
    //       baseColor: Theme.of(context).colorScheme.secondary,
    //       highlightColor: Theme.of(context).colorScheme.background,
    //     ),
    //   );
    // }

    // if (citizenAnnouncements.length == 0) {
    //   return Container(
    //     padding: const EdgeInsets.only(
    //       left: 15.0,
    //       right: 15.0,
    //     ),
    //     child: ListView.separated(
    //       physics: const NeverScrollableScrollPhysics(),
    //       shrinkWrap: true,
    //       itemBuilder: (ctx, i) => HomeAnnouncementCard(
    //         title: '',
    //         dateTime: '',
    //         onClickCard: () {},
    //       ),
    //       separatorBuilder: (ctx, i) => Padding(
    //         padding: const EdgeInsets.all(4.0),
    //       ),
    //       itemCount: 3,
    //     ),
    //   );
    // }

    if (citizenAnnouncements.isEmpty) {
      return Container(
        margin: EdgeInsets.symmetric(
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
              SizedBox(
                height: 10.0,
              ),
              Text("No announcement"),
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
        if (citizenShimmer) {
          return Shimmer.fromColors(
            baseColor: Colors.white,
            highlightColor: Colors.transparent,
            child: HomepageCitizenCard(
              useDefaultImage: true,
              imageUrl: "assets/images/icon/sioc.png",
              title: "Loading...",
              subtitle: "Loading...",
              onTap: () {},
            ),
          );
        }
        return citizenAnnouncements[i].attachmentDtoList.isEmpty
            ? HomepageCitizenCard(
                useDefaultImage: true,
                imageUrl: "assets/images/icon/sioc.png",
                title: getAnnouncementTitle(i, context),
                subtitle: citizenAnnouncements[i].annStartDate,
                onTap: () {
                  // Navigator.of(context).pushNamed(
                  //   AnnouncementDetailScreen.routeName,
                  //   arguments: {
                  //     'id': citizenAnnouncements[i].annId,
                  //     'isMajor': false
                  //   },
                  // );
                },
              )
            : HomepageCitizenCard(
                imageUrl:
                    citizenAnnouncements[i].attachmentDtoList[0].attFilePath,
                title: getAnnouncementTitle(i, context),
                subtitle: citizenAnnouncements[i].annStartDate,
                onTap: () {
                  // Navigator.of(context).pushNamed(
                  //   AnnouncementDetailScreen.routeName,
                  //   arguments: {
                  //     'id': citizenAnnouncements[i].annId,
                  //     'isMajor': false
                  //   },
                  // );
                },
              );
      },
    );
  }
}
