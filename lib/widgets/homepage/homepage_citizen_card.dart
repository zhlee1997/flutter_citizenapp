import 'package:flutter/material.dart';

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
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.contain,
                    )
                  : Image.network(
                      imageUrl,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.contain,
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
