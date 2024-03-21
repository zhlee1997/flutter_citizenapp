import 'package:flutter/material.dart';

import '../emergency/emergency_audio_player.dart';

class EmergencyRecordingFullBottomModal extends StatelessWidget {
  final String audioWavHttpURL;

  const EmergencyRecordingFullBottomModal({
    required this.audioWavHttpURL,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.keyboard_arrow_down,
            size: 35.0,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text("Recording File"),
      ),
      body: SafeArea(
        child: EmergencyAudioPlayer(
          audioWavHttpURL: audioWavHttpURL,
        ),
      ),
    );
  }
}
