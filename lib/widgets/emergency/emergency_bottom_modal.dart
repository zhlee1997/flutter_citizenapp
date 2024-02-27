import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/emergency_provider.dart';

class EmergencyBottomModal extends StatelessWidget {
  final VoidCallback handleProceedNext;
  final int category;

  const EmergencyBottomModal({
    required this.handleProceedNext,
    required this.category,
    super.key,
  });

  String returnCategoryInText(int category) {
    switch (category) {
      case 0:
        return "HARASSMENT";
      case 1:
        return "FIRE/RESCUE";
      case 2:
        return "TRAFFIC ACCIDENT/INJURIES";
      case 3:
        return "THEFT/ROBBERY";
      case 4:
        return "PHYSICAL VIOLENCE";
      case 5:
        return "OTHERS";
      default:
        return "VOICE RECORDING";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      width: double.infinity,
      child: Stack(children: <Widget>[
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.only(
                top: 20.0,
                bottom: 10.0,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 5.0,
              ),
              child: const Text(
                "Are you the one in need of help?",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 10.0),
              child: Text(returnCategoryInText(category)),
            ),
            Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Colors.red,
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () {
                    Provider.of<EmergencyProvider>(context, listen: false)
                        .setOtherText(null);
                    // Emergency provider => yourself: true
                    Provider.of<EmergencyProvider>(context, listen: false)
                        .setCategoryAndYourself(
                      category: category,
                      yourself: true,
                    );
                    handleProceedNext();
                  },
                  child: const Text(
                    "Yes",
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Colors.grey,
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(),
                  onPressed: () {
                    Provider.of<EmergencyProvider>(context, listen: false)
                        .setOtherText(null);
                    // Emergency provider => yourself: false
                    Provider.of<EmergencyProvider>(context, listen: false)
                        .setCategoryAndYourself(
                      category: category,
                      yourself: false,
                    );
                    handleProceedNext();
                  },
                  child: Text(
                    "No",
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20.0,
            )
          ],
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: 60,
              height: 5,
              decoration: const BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
