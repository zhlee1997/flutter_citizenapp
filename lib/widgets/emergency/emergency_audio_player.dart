import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class EmergencyAudioPlayer extends StatefulWidget {
  const EmergencyAudioPlayer({super.key});

  @override
  State<EmergencyAudioPlayer> createState() => _EmergencyAudioPlayerState();
}

class _EmergencyAudioPlayerState extends State<EmergencyAudioPlayer> {
  final player = AudioPlayer();

  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    setAudio();

    player.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });

    player.onDurationChanged.listen((newDuration) {
      setState(() {
        duration = newDuration;
      });
    });

    player.onPositionChanged.listen((newPosition) {
      setState(() {
        position = newPosition;
      });
    });
  }

  Future<void> setAudio() async {
    // Repeat song when completed
    // player.setReleaseMode(ReleaseMode.loop);

    // Load audio from URL
    String url =
        "https://www.chosic.com/wp-content/uploads/2021/04/The-Inspiration-mp3(chosic.com).mp3";
    player.setSourceUrl(url);
  }

  @override
  void dispose() {
    player.dispose();

    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.symmetric(
            vertical: 10.0,
          ),
          child: Text(
            "File: my_recording_20240205.wav",
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        Slider(
          min: 0,
          max: duration.inSeconds.toDouble(),
          value: position.inSeconds.toDouble(),
          onChanged: (double value) async {
            final position = Duration(seconds: value.toInt());
            await player.seek(position);

            // Optional: play audio if was paused
            await player.resume();
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(position.inSeconds.toString()),
              Text((duration.inSeconds - position.inSeconds).toString()),
            ],
          ),
        ),
        CircleAvatar(
          radius: 35,
          child: IconButton(
            icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
            iconSize: 50,
            onPressed: () async {
              if (isPlaying) {
                await player.pause();
              } else {
                String url =
                    "https://www.chosic.com/wp-content/uploads/2021/04/The-Inspiration-mp3(chosic.com).mp3";
                await player.play(UrlSource(url));
              }
            },
          ),
        )
      ],
    );
  }
}
