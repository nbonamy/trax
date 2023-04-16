import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../components/artwork_async.dart';
import '../utils/track_utils.dart';
import 'audio_player.dart';
import 'trackbar.dart';
import 'widget.dart';

class AudioPanel extends StatelessWidget {
  final double borderRadius = 2.0;
  const AudioPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 600,
      decoration: BoxDecoration(
        border: Border.all(
          color: CupertinoColors.lightBackgroundGray,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Consumer<AudioPlayer>(
        builder: (context, audioPlayer, child) => Row(
          children: [
            AsyncArtwork(
              track: audioPlayer.current,
              size: 50,
              radius: borderRadius,
              placeholder: Container(
                height: 50,
                width: 50,
                color: const Color.fromRGBO(233, 233, 233, 1.0),
                child: const Icon(
                  CupertinoIcons.music_note_2,
                  color: AudioPlayerWidget.inactiveColor,
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    audioPlayer.current?.displayTitle ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${audioPlayer.current?.displayPerformer ?? ''} - ${audioPlayer.current?.displayAlbum ?? ''}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const SizedBox(
                    width: double.infinity,
                    child: TrackBar(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
