import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/emergency_provider.dart';

class ConfirmScreen extends StatelessWidget {
  const ConfirmScreen({super.key});

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

  /// Determine the type of description message based on selected case
  /// The description message will be submitted via sendRequest()
  ///
  /// Returns description message
  String returnRemarksInText(BuildContext context, int categoryIndex) {
    if (categoryIndex == 0) {
      return 'You reported Harassment';
    } else if (categoryIndex == 1) {
      return 'You reported Fire/Rescue';
    } else if (categoryIndex == 2) {
      return 'You reported Traffic Accident/Injuries';
    } else if (categoryIndex == 3) {
      return 'You reported Theft/Robbery';
    } else if (categoryIndex == 4) {
      return 'You reported Physical Violence';
    } else if (categoryIndex == 5) {
      return Provider.of<EmergencyProvider>(context).otherText ?? "No remarks";
    } else {
      return "You submitted Voice Recording";
    }
  }

  @override
  Widget build(BuildContext context) {
    final String audioPath = Provider.of<EmergencyProvider>(context).audioPath;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Note: Please verify and check the information below before submission",
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(
          height: 20.0,
        ),
        const Text("ADDRESS"),
        Text(
          Provider.of<EmergencyProvider>(context).address,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 10.0,
        ),
        const Text("LOCATION"),
        Text(
          "${Provider.of<EmergencyProvider>(context).latitude}, ${Provider.of<EmergencyProvider>(context).longitude}",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 10.0,
        ),
        const Text("EMERGENCY REQUEST"),
        Text(
          returnCategoryInText(
              Provider.of<EmergencyProvider>(context).category),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (audioPath.isNotEmpty)
          const SizedBox(
            height: 10.0,
          ),
        if (audioPath.isNotEmpty) const Text("ATTACHMENT"),
        if (audioPath.isNotEmpty)
          Text(
            audioPath.substring(audioPath.lastIndexOf("/"), audioPath.length),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        const SizedBox(
          height: 10.0,
        ),
        const Text("IS IT YOU YOURSELF?"),
        Text(
          Provider.of<EmergencyProvider>(context).yourself ? "YES" : "NO",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 10.0,
        ),
        const Text("REMARKS"),
        Text(
          returnRemarksInText(
            context,
            Provider.of<EmergencyProvider>(context).category,
          ),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 20.0,
        ),
      ],
    );
  }
}
