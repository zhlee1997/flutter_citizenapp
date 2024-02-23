import 'package:flutter/material.dart';

class SubscriptionBenefitCard extends StatelessWidget {
  final List<String> contents;

  const SubscriptionBenefitCard({
    required this.contents,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Container(
      padding: EdgeInsets.only(
        top: screenSize.height * 0.015,
        bottom: screenSize.height * 0.015,
        left: screenSize.height * 0.03,
        right: screenSize.height * 0.03,
      ),
      alignment: Alignment.center,
      // color: Colors.red,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          ...contents.map((e) {
            int index = contents.indexOf(e);
            return Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(
                  top: index == 0 ? 0 : screenSize.height * 0.015,
                ),
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.check_circle,
                        size: 25.0,
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      '$e',
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ],
                ));
          }).toList(),
        ],
      ),
    );
  }
}
