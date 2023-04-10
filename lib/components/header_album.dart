import 'package:flutter/material.dart';

import '../utils/consts.dart';
import '../utils/track_utils.dart';

class HeaderAlbumWidget extends StatelessWidget {
  final String title;
  final String genre;
  final int year;
  const HeaderAlbumWidget({
    super.key,
    required this.title,
    required this.genre,
    required this.year,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          TrackUtils.getDisplayAlbum(title),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '${TrackUtils.getDisplayGenre(genre).toUpperCase()} ${year != 0 ? '· $year' : ''}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black.withOpacity(Consts.fadedOpacity),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
