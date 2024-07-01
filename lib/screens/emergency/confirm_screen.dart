import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/emergency_provider.dart';
import '../../utils/app_localization.dart';

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
    final screenSize = MediaQuery.of(context).size;

    final String audioPath = Provider.of<EmergencyProvider>(context).audioPath;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(15.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
          ),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.background,
                    radius: 16.0,
                    child: Icon(
                      Icons.tips_and_updates,
                      size: 18.0,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  Text(
                    AppLocalization.of(context)!.translate('note_2')!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 8.0,
              ),
              Text(
                AppLocalization.of(context)!
                    .translate('please_verify_and_check')!,
                style: const TextStyle(
                  fontSize: 13.0,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 20.0,
        ),
        Text(AppLocalization.of(context)!.translate('address_2')!),
        Text(
          Provider.of<EmergencyProvider>(context).address,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 10.0,
        ),
        Text(AppLocalization.of(context)!.translate('location_2')!),
        Text(
          "${Provider.of<EmergencyProvider>(context).latitude}, ${Provider.of<EmergencyProvider>(context).longitude}",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 10.0,
        ),
        Text(AppLocalization.of(context)!.translate('emergency_request_2')!),
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
        if (audioPath.isNotEmpty)
          Text(AppLocalization.of(context)!.translate('attachment')!),
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
        Text(AppLocalization.of(context)!.translate('is_it_you_yourself')!),
        Text(
          Provider.of<EmergencyProvider>(context).yourself ? "YES" : "NO",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 10.0,
        ),
        Text(AppLocalization.of(context)!.translate('remarks')!),
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
