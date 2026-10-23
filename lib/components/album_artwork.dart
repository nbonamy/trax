import 'package:flutter/material.dart';
import 'package:trax/l10n/app_localizations.dart';

import '../model/track.dart';
import '../utils/num_utils.dart';
import 'artwork_async.dart';
import 'trax_colors.dart';

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
    final AppLocalizations t = AppLocalizations.of(context)!;
    final TraxColors colors = TraxColors.of(context);
    final TextStyle style = TextStyle(fontSize: 12, color: colors.muted);
    return SizedBox(
      width: size,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: size == 0
            ? []
            : [
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: colors.shadow.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: AsyncArtwork(
                    track: track,
                    size: size,
                    defaultPlaceholderBorderColor: colors.line,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  '${t.statsTracks(trackCount)}, $playtime${t.statsDurationMinutes.trimRight()}',
                  style: style,
                ),
                const SizedBox(height: 3),
                Text(format.trim(), style: style),
                const SizedBox(height: 3),
                Text(filesize.formatFilesize(), style: style),
              ],
      ),
    );
  }
}
