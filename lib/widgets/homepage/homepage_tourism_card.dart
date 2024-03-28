import 'package:flutter/material.dart';

import '../../screens/announcement/announcement_detail_screen.dart';

class HomepageTourismCard extends StatelessWidget {
  final bool useDefault;
  final String? annId;
  final String imageUrl;
  final String title;
  final String subtitle;

  const HomepageTourismCard({
    this.useDefault = false,
    this.annId,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: annId != null
          ? () {
              Navigator.of(context).pushNamed(
                AnnouncementDetailScreen.routeName,
                arguments: {
                  'id': annId,
                  'isMajor': false,
                },
              );
            }
          : null,
      child: Container(
        margin: const EdgeInsets.only(
          bottom: 15.0,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0), // Set the border radius
          border: Border.all(
            color: Colors.grey, // Set the border color
            width: 0.5, // Set the border width
          ),
        ),
        child: Row(
          children: <Widget>[
            Flexible(
              flex: 1,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  bottomLeft: Radius.circular(10.0),
                ),
                child: useDefault
                    ? Image.asset(
                        imageUrl,
                        fit: BoxFit.cover,
                      )
                    : Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            Flexible(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 5.0,
                    ),
                    SizedBox(
                      width: screenSize.width * 0.67,
                      child: Text(
                        subtitle,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
