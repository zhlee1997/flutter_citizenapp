import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomepageCitizenCard extends StatelessWidget {
  final bool useDefaultImage;
  final String imageUrl;
  final String title;
  final String subtitle;
  final void Function()? onTap;

  const HomepageCitizenCard({
    this.useDefaultImage = false,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: useDefaultImage
                  ? Image.asset(
                      imageUrl,
                      height: screenSize.width * 0.33,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Image.network(
                      imageUrl,
                      height: screenSize.width * 0.33,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, url, error) => SvgPicture.asset(
                        "assets/images/svg/undraw_page_not_found.svg",
                        height: screenSize.width * 0.33,
                        fit: BoxFit.cover,
                        semanticsLabel: 'Not Found Logo',
                      ),
                    ),
            ),
            Container(
              margin: const EdgeInsets.only(
                top: 7.5,
                bottom: 5.0,
              ),
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              subtitle,
              maxLines: 3,
            )
          ],
        ),
      ),
    );
  }
}
