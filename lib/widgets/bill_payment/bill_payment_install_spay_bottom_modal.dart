import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class BillPaymentInstallSPayBottomModal extends StatelessWidget {
  const BillPaymentInstallSPayBottomModal({super.key});

  void openStore() {
    if (Platform.isAndroid || Platform.isIOS) {
      final appId =
          Platform.isAndroid ? 'my.gov.sarawak.paybills' : '1250845042';
      final url = Uri.parse(
        Platform.isAndroid
            ? "market://details?id=$appId"
            : "https://apps.apple.com/app/id$appId",
      );
      launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "S Pay Global not installed",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton.filledTonal(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.clear_outlined),
              )
            ],
          ),
          const SizedBox(height: 10.0),
          Image.asset("assets/images/pictures/spay/spay-not-installed-ad.jpeg"),
          const SizedBox(height: 5.0),
          Text(
            "Please install and login S Pay Global before able to proceed with the payment.",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 10.0),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: openStore,
              child: Text("Install Now"),
              style: OutlinedButton.styleFrom(
                  side: BorderSide(
                color: Theme.of(context).colorScheme.primary,
              )),
            ),
          )
        ],
      ),
    );
  }
}
