import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import '../utils/app_localization.dart';
import '../utils/image_network_helper.dart';
import '../models/major_announcement_model.dart';
import '../screens/announcement/announcement_detail_screen.dart';

class MajorDialogHelper extends StatefulWidget {
  final List<MajorAnnouncementModel> majorAnnouncementList;

  const MajorDialogHelper({
    required this.majorAnnouncementList,
    super.key,
  });

  @override
  State<MajorDialogHelper> createState() => _MajorDialogHelperState();
}

class _MajorDialogHelperState extends State<MajorDialogHelper> {
  int _pageNumber = 0;

  List<MajorAnnouncementModel> get majorAnnouncementList =>
      widget.majorAnnouncementList;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          height: 200,
          child: PageView(
              onPageChanged: (int num) {
                if (mounted) {
                  setState(() {
                    _pageNumber = num;
                  });
                }
              },
              children: majorAnnouncementList
                  .map((e) => ImageNetworkHelper.imageNetworkBuilder(
                        url: e.image.isNotEmpty ? e.image : null,
                        fit: BoxFit.cover,
                        height: 200,
                        width: 200,
                      ))
                  .toList()),
        ),
        if (majorAnnouncementList.isNotEmpty)
          Container(
            height: 15,
            margin: const EdgeInsets.only(
              top: 10.0,
            ),
            child: Center(
              child: ListView.builder(
                dragStartBehavior: DragStartBehavior.down,
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: majorAnnouncementList.length,
                itemBuilder: (_, index) => _pageNumber == index
                    ? _pageViewIndicator(true)
                    : _pageViewIndicator(false),
              ),
            ),
          ),
        if (majorAnnouncementList.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
            ),
            margin: const EdgeInsets.symmetric(
              vertical: 10.0,
            ),
            child: Text(
              majorAnnouncementList[_pageNumber].title,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        if (majorAnnouncementList.isNotEmpty)
          Container(
            padding: const EdgeInsets.only(
              left: 10.0,
              right: 10.0,
              bottom: 15.0,
            ),
            child: Text(
              majorAnnouncementList[_pageNumber].description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        const SizedBox(
          height: 10,
        ),
        GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(
              AnnouncementDetailScreen.routeName,
              arguments: {
                'id': majorAnnouncementList[_pageNumber].sid,
                'isMajor': true
              },
            ).then((value) {
              if (value == true) Navigator.of(context).pop();
            });
          },
          child: Container(
            width: double.infinity,
            color: Theme.of(context).primaryColor,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
            ),
            child: Text(
              AppLocalization.of(context)!.translate('find_out')!,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // return page view indicators
  Widget _pageViewIndicator(bool isActive) {
    return SizedBox(
      height: 6,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        height: isActive ? 6 : 4.0,
        width: isActive ? 8 : 4.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive
              ? Theme.of(context).primaryColor.withOpacity(0.75)
              : Colors.grey,
          boxShadow: [
            isActive
                ? BoxShadow(
                    color: Theme.of(context).colorScheme.secondary,
                    blurRadius: 4.0,
                    spreadRadius: 1.0,
                    offset: const Offset(
                      0.0,
                      0.0,
                    ),
                  )
                : const BoxShadow(
                    color: Colors.transparent,
                  )
          ],
        ),
      ),
    );
  }
}
