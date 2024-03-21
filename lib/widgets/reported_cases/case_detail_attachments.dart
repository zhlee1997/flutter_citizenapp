import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../models/case_model.dart';
import '../../utils/app_localization.dart';
import '../../utils/global_dialog_helper.dart';

class CaseDetailAttachments extends StatelessWidget {
  final List<AttachmentModel>? imageList;

  const CaseDetailAttachments({
    required this.imageList,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Container(
      margin: const EdgeInsets.only(top: 15.0),
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalization.of(context)!.translate('attachments')!,
            style: TextStyle(
              color: Colors.grey,
              fontSize: Platform.isIOS ? 18.0 : 15.0,
            ),
          ),
          const SizedBox(
            height: 10.0,
          ),
          SizedBox(
            width: double.infinity,
            height: imageList!.length > 0 ? screenSize.height * 0.1 : null,
            child: imageList!.length > 0
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    children: [
                      ...imageList!.map(
                        (e) => GestureDetector(
                          onTap: () => GlobalDialogHelper()
                              .showPhotoGallery(context, e.attFilePath),
                          child: Container(
                            margin: const EdgeInsets.only(right: 10.0),
                            child: CachedNetworkImage(
                              imageUrl: e.attFilePath,
                            ),
                          ),
                        ),
                      )
                    ],
                  )
                : Text(
                    'None',
                    style: TextStyle(
                      fontSize: Platform.isIOS ? 18.0 : 15.0,
                    ),
                  ),
          ),
          const Divider(
            color: Colors.grey,
            thickness: 1,
          ),
        ],
      ),
    );
  }
}
