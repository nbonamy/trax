import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'audio_player.dart';

class VolumeControls extends StatelessWidget {
  const VolumeControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayer>(
      builder: (context, audioPlayer, child) => const SizedBox(
        width: 120,
        // child: Row(
        //   children: [
        //     const Icon(
        //       CupertinoIcons.volume_down,
        //       color: AudioPlayerWidget.inactiveColor,
        //       size: 14,
        //     ),
        //     MacosSlider(
        //       value: audioPlayer.volume,
        //       color: const Color.fromRGBO(185, 185, 185, 1.0),
        //       onChanged: ((v) {}),
        //     ),
        //     const Icon(
        //       CupertinoIcons.volume_up,
        //       color: AudioPlayerWidget.inactiveColor,
        //       size: 14,
        //     ),
        //   ],
        // ),
      ),
    );
  }
}
