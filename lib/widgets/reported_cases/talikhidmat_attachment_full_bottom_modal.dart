import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../../models/case_model.dart';

class TalikhidmatAttachmentFullBottomModal extends StatelessWidget {
  final int numberOfAttachment;
  final List<AttachmentModel> attachmentURLs;

  const TalikhidmatAttachmentFullBottomModal({
    required this.numberOfAttachment,
    required this.attachmentURLs,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.keyboard_arrow_down,
            size: 35.0,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text("Attachment File"),
        bottom: PreferredSize(
            preferredSize: Size.fromHeight(screenSize.height * 0.025),
            child: Text(
                "$numberOfAttachment ${numberOfAttachment > 1 ? "Images" : "Image"}")),
      ),
      body: SafeArea(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
              child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 20,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5,
                    ),
                    itemCount: attachmentURLs.length,
                    itemBuilder: (context, index) {
                      return RawMaterialButton(
                        child: CachedNetworkImage(
                          imageUrl: attachmentURLs[index].attFilePath,
                          fit: BoxFit.contain,
                          height: 300,
                          width: 300,
                          placeholder: (BuildContext context, String url) =>
                              Container(
                            color: Theme.of(context).colorScheme.secondary,
                            padding: const EdgeInsets.all(8.0),
                            child: const CircularProgressIndicator.adaptive(
                              strokeWidth: 2.0,
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Theme.of(context).colorScheme.secondary,
                            child: const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                            ),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GalleryWidget(
                                urlImages: attachmentURLs
                                    .map((e) => e.attFilePath)
                                    .toList(),
                                index: index,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  )))
        ],
      )),
    );
  }
}

class GalleryWidget extends StatefulWidget {
  final List<String> urlImages;
  final int index;
  final PageController pageController;

  // ignore: use_key_in_widget_constructors
  GalleryWidget({
    required this.urlImages,
    this.index = 0,
  }) : pageController = PageController(initialPage: index);

  @override
  State<GalleryWidget> createState() => _GalleryWidgetState();
}

class _GalleryWidgetState extends State<GalleryWidget> {
  var urlImage;
  int currentPageIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentPageIndex = widget.pageController.initialPage + 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
            'Image Gallery ($currentPageIndex/${widget.urlImages.length})'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: PhotoViewGallery.builder(
              pageController: widget.pageController,
              itemCount: widget.urlImages.length,
              onPageChanged: (int index) {
                setState(() {
                  currentPageIndex = index + 1;
                });
              },
              builder: (context, index) {
                urlImage = widget.urlImages[index];
                return PhotoViewGalleryPageOptions(
                  imageProvider: NetworkImage(urlImage),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
