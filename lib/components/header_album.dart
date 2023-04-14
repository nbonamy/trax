import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../utils/consts.dart';
import '../utils/time_utils.dart';
import '../utils/track_utils.dart';

class HeaderAlbumWidget extends StatelessWidget {
  final String title;
  final String genre;
  final int year;
  final int duration;
  const HeaderAlbumWidget({
    super.key,
    required this.title,
    required this.genre,
    required this.year,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    AppLocalizations t = AppLocalizations.of(context)!;
    String? genreStr = TrackUtils.getDisplayGenre(genre).toUpperCase();
    String? yearStr = year == 0 ? null : '$year';
    String? durationStr = duration == 0
        ? null
        : duration
            .formatDuration(
              skipHours: true,
              skipSeconds: true,
              suffixMinutes: t.statsDurationMinutes,
            )
            .toUpperCase();

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
          '$genreStr${yearStr == null ? "" : " · $yearStr"}${durationStr == null ? "" : " · $durationStr"}',
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
