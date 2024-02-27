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
        const Text("NAME"),
        Text(
          "Steven Bong",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 10.0,
        ),
        const Text("SARAWAK ID"),
        Text(
          "S127354",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 10.0,
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
            audioPath,
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
          Provider.of<EmergencyProvider>(context).otherText ?? "No remarks",
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
