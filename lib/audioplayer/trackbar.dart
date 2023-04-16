import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:provider/provider.dart';

import 'audio_player.dart';

class TrackBar extends StatelessWidget {
  const TrackBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayer>(
      builder: (context, audioPlayer, child) => StreamBuilder(
        stream: audioPlayer.progressStream,
        builder: (context, snapshot) {
          double value = clampDouble(
            snapshot.hasData ? (snapshot.data ?? 0) : 0,
            0.0,
            1.0,
          );
          return Visibility(
            visible: !audioPlayer.isStopped,
            child: GestureDetector(
              onTapUp: (details) {
                final RenderBox box = context.findRenderObject() as RenderBox;
                double progress = details.localPosition.dx / box.size.width;
                audioPlayer.seekTo(progress);
              },
              child: ProgressBar(
                value: value * 100,
                trackColor: const Color.fromRGBO(115, 115, 115, 1.0),
                height: 3,
              ),
            ),
          );
        },
      ),
    );
  }
}
