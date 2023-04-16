import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'audio_player.dart';

class PlaybackControls extends StatelessWidget {
  final Color activeColor = const Color.fromRGBO(106, 106, 106, 1.0);
  final Color inactiveColor = const Color.fromRGBO(198, 198, 198, 1.0);
  const PlaybackControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayer>(
      builder: (context, audioPlayer, child) => Row(
        children: [
          GestureDetector(
            onTap: () => audioPlayer.previous(),
            child: Icon(
              CupertinoIcons.backward_fill,
              color: audioPlayer.canPrevious ? activeColor : inactiveColor,
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () => audioPlayer.playpause(),
            child: Icon(
              audioPlayer.isPlaying
                  ? CupertinoIcons.pause_fill
                  : CupertinoIcons.play_fill,
              color: activeColor,
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => audioPlayer.next(),
            child: Icon(
              CupertinoIcons.forward_fill,
              color: audioPlayer.canNext ? activeColor : inactiveColor,
            ),
          ),
        ],
      ),
    );
  }
}
