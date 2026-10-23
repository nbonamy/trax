import 'package:flutter/material.dart';
import 'package:trax/l10n/app_localizations.dart';

import 'trax_colors.dart';

/// Title of a screen that is not an artist: search results or a review.
class HeaderCollectionWidget extends StatelessWidget {
  final String title;
  final int albumCount;
  final int trackCount;
  final String? hint;
  const HeaderCollectionWidget({
    super.key,
    required this.title,
    required this.albumCount,
    required this.trackCount,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context)!;
    final TraxColors colors = TraxColors.of(context);
    return Container(
      width: double.infinity,
      color: colors.background,
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 28,
              letterSpacing: -0.5,
              color: colors.text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            t.albumsAndSongs(albumCount, trackCount),
            style: TextStyle(fontSize: 13, color: colors.muted),
          ),
          if (hint != null) ...[
            const SizedBox(height: 4),
            Text(
              hint!,
              style: TextStyle(fontSize: 12, color: colors.faint),
            ),
          ],
        ],
      ),
    );
  }
}
