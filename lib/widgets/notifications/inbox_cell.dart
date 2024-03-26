import 'dart:io';

import 'package:flutter/material.dart';

class InboxCell extends StatelessWidget {
  final String label;
  final String value;
  final bool isSpaced;

  const InboxCell({
    required this.label,
    required this.value,
    this.isSpaced = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Container(
      width: screenSize.width * 0.9,
      margin: isSpaced
          ? const EdgeInsets.only(
              top: 20.0,
            )
          : null,
      alignment: Alignment.centerLeft,
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label ',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            TextSpan(
              text: value,
              style: TextStyle(
                color: Colors.black,
                fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize,
                fontWeight: FontWeight.w600,
              ),
            )
          ],
        ),
      ),
    );
  }
}
