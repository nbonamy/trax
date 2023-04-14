import 'package:flutter/material.dart';

import '../model/track.dart';
import '../utils/consts.dart';
import 'artwork_async.dart';

class AlbumArtworkWidget extends StatelessWidget {
  final Track track;
  final double size;
  final int trackCount;
  final int playtime;
  const AlbumArtworkWidget({
    super.key,
    required this.track,
    required this.size,
    required this.trackCount,
    required this.playtime,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: size == 0
            ? []
            : [
                AsyncArtwork(
                  track: track,
                  size: size,
                ),
                const SizedBox(height: 8),
                Text(
                  '$trackCount SONGS, $playtime MINUTES',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black.withOpacity(Consts.fadedOpacity),
                  ),
                ),
              ],
      ),
    );
  }
}
