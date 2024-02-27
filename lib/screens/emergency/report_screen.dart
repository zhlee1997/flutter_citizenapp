import 'package:flutter/material.dart';

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
          child: const Text(
            "Method 1: Select one for emergency request",
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        GridView(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            childAspectRatio: 1.35 / 1,
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
                child: const Center(
                  child: Text(
                    "HARASSMENT",
                    textAlign: TextAlign.center,
                    style: TextStyle(
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
                child: const Center(
                  child: Text(
                    "FIRE/RESCUE",
                    textAlign: TextAlign.center,
                    style: TextStyle(
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
                child: const Center(
                  child: Text(
                    "TRAFFIC ACCIDENT/INJURIES",
                    textAlign: TextAlign.center,
                    style: TextStyle(
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
                child: const Center(
                  child: Text(
                    "THEFT/ROBBERY",
                    textAlign: TextAlign.center,
                    style: TextStyle(
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
                child: const Center(
                  child: Text(
                    "PHYSICAL VIOLENCE",
                    textAlign: TextAlign.center,
                    style: TextStyle(
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
                child: const Center(
                  child: Text(
                    "OTHERS",
                    textAlign: TextAlign.center,
                    style: TextStyle(
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
            vertical: 10.0,
          ),
          alignment: Alignment.centerLeft,
          child: const Text(
            "Method 2: Record your voice for help",
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        GestureDetector(
          onTap: () => handleVoiceNoteBottomModal(),
          child: Container(
            width: double.infinity,
            height: screenSize.height * 0.15,
            margin: const EdgeInsets.only(
              bottom: 8.0,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              image: const DecorationImage(
                image: AssetImage(
                    "assets/images/pictures/emergency/voice_recording.jpg"),
                fit: BoxFit.cover,
                opacity: 0.3,
              ),
            ),
            padding: const EdgeInsets.all(8.0),
            child: const Center(
              child: Text(
                "VOICE RECORDING",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
