import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'audio_player.dart';
import 'controls.dart';
import 'panel.dart';
import 'volume.dart';

class AudioPlayerWidget extends StatefulWidget {
  static const Color activeColor = Color.fromRGBO(106, 106, 106, 1.0);
  static const inactiveColor = Color.fromRGBO(198, 198, 198, 1.0);
  const AudioPlayerWidget({super.key});

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayer>(
      builder: (context, audioPlayer, child) => Flex(
        direction: Axis.horizontal,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          PlaybackControls(),
          AudioPanel(),
          VolumeControls(),
        ],
      ),
    );
  }
}
