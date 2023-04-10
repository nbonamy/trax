import 'package:flutter/material.dart';

import '../utils/consts.dart';
import '../utils/track_utils.dart';

class HeaderArtistWidget extends StatelessWidget {
  final String artist;
  final int albumCount;
  final int trackCount;
  const HeaderArtistWidget({
    super.key,
    required this.artist,
    required this.albumCount,
    required this.trackCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 32, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            TrackUtils.getDisplayArtist(artist),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 8),
          const Divider(),
          Text(
            '$albumCount ALBUMS, $trackCount SONGS',
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
