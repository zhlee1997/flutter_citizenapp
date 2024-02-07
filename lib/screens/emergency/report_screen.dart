import 'package:flutter/material.dart';

class ReportScreen extends StatelessWidget {
  final VoidCallback handleVoiceNoteBottomModal;
  final VoidCallback handleEmergencyBottomModal;
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
            "Select any for emergency request",
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        GestureDetector(
          onTap: () => handleVoiceNoteBottomModal(),
          child: Container(
            width: double.infinity,
            height: screenSize.height * 0.175,
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
            child: const Center(
              child: Text(
                "Voice Recording",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
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
              onTap: handleEmergencyBottomModal,
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
                child: const Center(
                  child: Text(
                    "Harassment",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: handleEmergencyBottomModal,
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
                child: const Center(
                  child: Text(
                    "Fire/Rescue",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: handleEmergencyBottomModal,
              child: Container(
                child: Center(
                  child: Text(
                    "Traffic Accident/Injuries",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  image: DecorationImage(
                    image: AssetImage(
                        "assets/images/pictures/emergency/traffic_accident.jpg"),
                    fit: BoxFit.cover,
                    opacity: 0.3,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: handleEmergencyBottomModal,
              child: Container(
                child: Center(
                  child: Text(
                    "Theft/Robbery",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  image: DecorationImage(
                    image: AssetImage(
                        "assets/images/pictures/emergency/theft.jpg"),
                    fit: BoxFit.cover,
                    opacity: 0.3,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: handleEmergencyBottomModal,
              child: Container(
                child: Center(
                  child: Text(
                    "Physical Violence",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  image: DecorationImage(
                    image: AssetImage(
                        "assets/images/pictures/emergency/physical_violence.jpg"),
                    fit: BoxFit.cover,
                    opacity: 0.3,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: handleOtherEmergencyBottomModal,
              child: Container(
                child: Center(
                  child: Text(
                    "Others",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  image: DecorationImage(
                    image: AssetImage(
                        "assets/images/pictures/emergency/others.jpg"),
                    fit: BoxFit.cover,
                    opacity: 0.3,
                  ),
                ),
              ),
            )
          ],
        ),
        Container(
          margin: EdgeInsets.only(
            top: 10.0,
          ),
          child: Text(
            "You have 2 requests left per day",
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        )
      ],
    );
  }
}
