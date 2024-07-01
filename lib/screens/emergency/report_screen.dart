import 'package:flutter/material.dart';

import '../../utils/app_localization.dart';

class ReportScreen extends StatelessWidget {
  final VoidCallback handleVoiceNoteBottomModal;
  final void Function(int) handleEmergencyBottomModal;
  final VoidCallback handleOtherEmergencyBottomModal;

  const ReportScreen({
    required this.handleVoiceNoteBottomModal,
    required this.handleEmergencyBottomModal,
    required this.handleOtherEmergencyBottomModal,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(
            bottom: 10.0,
          ),
          alignment: Alignment.centerLeft,
          child: Text(
            AppLocalization.of(context)!.translate('select_one_for')!,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        GridView(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            childAspectRatio: screenSize.width * 0.0045 / 1,
          ),
          children: <Widget>[
            GestureDetector(
              onTap: () => handleEmergencyBottomModal(0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  image: const DecorationImage(
                    image: AssetImage(
                        "assets/images/pictures/emergency/harassment.jpg"),
                    fit: BoxFit.cover,
                    opacity: 0.3,
                  ),
                ),
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    AppLocalization.of(context)!.translate('harassment')!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      // fontSize: 14.0,
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => handleEmergencyBottomModal(1),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  image: const DecorationImage(
                    image:
                        AssetImage("assets/images/pictures/emergency/fire.jpg"),
                    fit: BoxFit.cover,
                    opacity: 0.3,
                  ),
                ),
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    AppLocalization.of(context)!.translate('fire/rescue')!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      // fontSize: 16.0,
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => handleEmergencyBottomModal(2),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  image: const DecorationImage(
                    image: AssetImage(
                        "assets/images/pictures/emergency/traffic_accident.jpg"),
                    fit: BoxFit.cover,
                    opacity: 0.3,
                  ),
                ),
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    AppLocalization.of(context)!
                        .translate('traffic_accident/injuries')!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      // fontSize: 16.0,
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => handleEmergencyBottomModal(3),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  image: const DecorationImage(
                    image: AssetImage(
                        "assets/images/pictures/emergency/theft.jpg"),
                    fit: BoxFit.cover,
                    opacity: 0.3,
                  ),
                ),
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    AppLocalization.of(context)!.translate('theft/robbery')!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      // fontSize: 16.0,
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => handleEmergencyBottomModal(4),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  image: const DecorationImage(
                    image: AssetImage(
                        "assets/images/pictures/emergency/physical_violence.jpg"),
                    fit: BoxFit.cover,
                    opacity: 0.3,
                  ),
                ),
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    AppLocalization.of(context)!
                        .translate('physical_violence')!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      // fontSize: 16.0,
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: handleOtherEmergencyBottomModal,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  image: const DecorationImage(
                    image: AssetImage(
                        "assets/images/pictures/emergency/others.jpg"),
                    fit: BoxFit.cover,
                    opacity: 0.3,
                  ),
                ),
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    AppLocalization.of(context)!.translate('others')!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      // fontSize: 16.0,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
        Container(
          margin: const EdgeInsets.symmetric(
            vertical: 20.0,
          ),
          alignment: Alignment.center,
          child: Text(
            AppLocalization.of(context)!
                .translate('or_record_your_voice_for_help')!,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        GestureDetector(
          // onTap: () => handleVoiceNoteBottomModal(),
          child: Container(
            width: double.infinity,
            height: screenSize.height * 0.15,
            margin: const EdgeInsets.only(
              bottom: 8.0,
            ),
            // padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: handleVoiceNoteBottomModal,
              style: ElevatedButton.styleFrom(
                elevation: 5.0,
                side: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 0.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.record_voice_over_outlined,
                    size: 27.5,
                    color: Colors.red,
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    AppLocalization.of(context)!.translate('voice_recording')!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      // fontSize: 16.0,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
