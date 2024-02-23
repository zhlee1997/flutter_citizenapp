import 'dart:io' show Platform;

import 'package:flutter/material.dart';

// import '../../screens/payment/payment_detail_screen.dart';

class PaymentLogo extends StatelessWidget {
  final String title;
  final String text;
  final String imageUrl;

  const PaymentLogo(this.title, this.text, this.imageUrl);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        // Navigator.of(context).pushNamed(
        //   PaymentDetailScreen.routeName,
        //   arguments: {
        //     'title': title,
        //     'imageUrl': imageUrl,
        //     'text': text,
        //   },
        // );
      },
      child: Container(
        margin: const EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: Container(
                padding: const EdgeInsets.all(13.0),
                width: Platform.isIOS ? 90 : screenSize.width * 0.3,
                height: Platform.isIOS ? 90 : screenSize.width * 0.24,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(width: 0.5),
                ),
                child: Image.asset(
                  imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(
                top: 10.0,
              ),
              child: Text(
                text,
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
        // color: Colors.red,
      ),
    );
  }
}
