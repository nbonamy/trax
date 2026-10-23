import 'package:flutter/material.dart';
import 'package:trax/l10n/app_localizations.dart';

import '../utils/num_utils.dart';
import '../utils/track_utils.dart';
import 'trax_colors.dart';

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
    TraxColors colors = TraxColors.of(context);
    String genreStr = TrackUtils.getDisplayGenre(genre);
    String? yearStr = year == 0 ? null : '$year';
    String? durationStr = duration == 0
        ? null
        : duration
            .formatDuration(
              skipHours: true,
              skipSeconds: true,
              suffixMinutes: t.statsDurationMinutes,
            )
            .trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          TrackUtils.getDisplayAlbum(title),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            letterSpacing: -0.2,
            color: colors.text,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$genreStr${yearStr == null ? "" : " · $yearStr"}${durationStr == null ? "" : " · $durationStr"}',
          style: TextStyle(fontSize: 12, color: colors.muted),
        ),
      ],
    );
  }
}
