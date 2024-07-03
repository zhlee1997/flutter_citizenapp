import 'package:flutter/material.dart';

import '../../screens/subscription/subsription_package_screen.dart';
import '../../utils/app_localization.dart';

class SubscriptionPreviewDialog extends StatelessWidget {
  const SubscriptionPreviewDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Intro Image
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(
                        20.0), // Adjust the radius for the top-left corner
                    topRight: Radius.circular(
                        20.0), // Adjust the radius for the top-right corner
                  ),
                ),
                child: Image.asset(
                  'assets/gif/app_live_video.gif', // Replace with your image path
                  height: 300.0,
                  width: double.infinity,
                  fit: BoxFit.contain,
                ),
              ),
              Positioned(
                right: 0,
                child: IconButton(
                  iconSize: 20.0,
                  icon: Icon(
                    Icons.cancel,
                    color: Colors.grey[400],
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              )
            ],
          ),
          Container(
            alignment: Alignment.centerLeft,
            margin: const EdgeInsets.only(
              top: 16.0,
              left: 16.0,
              right: 10.0,
            ),
            child: Container(
              padding: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: Colors.yellow[100],
                borderRadius: const BorderRadius.all(Radius.circular(5.0)),
              ),
              child: Text(
                "Premium",
                style: TextStyle(
                  fontSize: 13.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.yellow[800],
                ),
              ),
            ),
          ),
          // Intro Title
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(
              top: 10.0,
              left: 16.0,
            ),
            child: Text(
              AppLocalization.of(context)!.translate('subscribe_with_us')!,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
          ),
          // Intro Text
          Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              top: 10.0,
              bottom: 16.0,
              right: 16.0,
            ),
            child: Text(
              AppLocalization.of(context)!.translate('just_in_time_for_you')!,
              textAlign: TextAlign.justify,
            ),
          ),
          // Action Button
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
            ),
            child: OutlinedButton(
              onPressed: () {
                // Close the dialog and navigate to the subscription module
                Navigator.of(context).pop();
                Navigator.of(context)
                    .pushNamed(SubscriptionPackageScreen.routeName);
              },
              style: ButtonStyle(
                side: MaterialStateProperty.all(
                  BorderSide(
                    color: Theme.of(context).primaryColor,
                  ),
                ), // Set border color
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    AppLocalization.of(context)!.translate('subscribe_now')!,
                    style: const TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                  const SizedBox(
                    width: 8.0,
                  ),
                  const Icon(Icons.arrow_forward),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 20.0,
          )
        ],
      ),
    );
  }
}
