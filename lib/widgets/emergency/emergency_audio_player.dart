import 'dart:async';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class EmergencyAudioPlayer extends StatefulWidget {
  final String audioWavHttpURL;

  const EmergencyAudioPlayer({
    required this.audioWavHttpURL,
    super.key,
  });

  @override
  State<EmergencyAudioPlayer> createState() => _EmergencyAudioPlayerState();
}

class _EmergencyAudioPlayerState extends State<EmergencyAudioPlayer> {
  final player = AudioPlayer();

  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  List<StreamSubscription> streams = [];

  String returnFileName(String httpPath) {
    List<String> stringArray = httpPath.split("/");
    return stringArray[stringArray.length - 1];
  }

  Future<void> setAudio() async {
    // Load audio from URL
    String url = widget.audioWavHttpURL;
    player.setSourceUrl(url);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setAudio();
    streams.add(player.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    }));

    streams.add(player.onDurationChanged.listen((newDuration) {
      setState(() {
        duration = newDuration;
      });
    }));

    streams.add(player.onPositionChanged.listen((newPosition) {
      setState(() {
        position = newPosition;
      });
    }));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    streams.forEach((element) => element.cancel());
    player.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.symmetric(
              vertical: 10.0,
            ),
            child: Text(
              "File: ${returnFileName(widget.audioWavHttpURL)}",
              style: Theme.of(context).textTheme.labelLarge,
              textAlign: TextAlign.center,
            ),
          ),
          // Slider(
          //   min: 0,
          //   max: duration.inSeconds.toDouble(),
          //   value: position.inSeconds.toDouble(),
          //   onChanged: (double value) async {
          //     final position = Duration(seconds: value.toInt());
          //     await player.seek(position);

          //     // Optional: play audio if was paused
          //     await player.resume();
          //   },
          // ),
          // Padding(
          //   padding: const EdgeInsets.symmetric(
          //     horizontal: 16.0,
          //   ),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: <Widget>[
          //       Text(position.inSeconds.toString()),
          //       Text((duration.inSeconds - position.inSeconds).toString()),
          //     ],
          //   ),
          // ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30.0),
            child: Text(
              position.toString(),
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ),
          const SizedBox(
            height: 10.0,
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
                  String url = widget.audioWavHttpURL;
                  await player.play(UrlSource(url));
                }
              },
            ),
          )
        ],
      ),
    );
  }
}
