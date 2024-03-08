import 'package:flutter/material.dart';

import '../model/track.dart';
import '../utils/consts.dart';
import '../utils/num_utils.dart';
import 'artwork_async.dart';

class AlbumArtworkWidget extends StatelessWidget {
  final Track track;
  final double size;
  final int trackCount;
  final int playtime;
  final String format;
  final int filesize;
  const AlbumArtworkWidget({
    super.key,
    required this.track,
    required this.size,
    required this.trackCount,
    required this.playtime,
    required this.format,
    required this.filesize,
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
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black.withOpacity(Consts.fadedOpacity),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  format.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black.withOpacity(Consts.fadedOpacity),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  filesize.formatFilesize(),
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
