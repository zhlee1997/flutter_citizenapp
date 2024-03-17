import 'dart:io';

import 'package:flutter/material.dart';

class CaseDetailBottomBar extends StatelessWidget {
  final String label;
  final String value;

  const CaseDetailBottomBar({
    required this.label,
    required this.value,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10.0),
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '$label',
            style: TextStyle(
              color: Colors.grey,
              fontSize: Platform.isIOS ? 20.0 : 15.0,
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          Text(
            '$value',
            style: TextStyle(
              fontSize: Platform.isIOS ? 25.0 : 20.0,
            ),
          ),
          Divider(
            color: Colors.grey,
            thickness: 1.5,
          )
        ],
      ),
    );
  }
}