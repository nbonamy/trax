import 'package:extended_wrap/extended_wrap.dart';
import 'package:flutter/cupertino.dart';
import 'package:trax/l10n/app_localizations.dart';

import '../model/track.dart';
import '../utils/events.dart';
import '../utils/track_utils.dart';
import 'artwork_async.dart';
import 'database_builder.dart';
import 'trax_colors.dart';

/// "FLAC · lossless" or "MP3 181 kbps": what an album is made of.
class FormatChip {
  final String text;
  const FormatChip(this.text);

  static FormatChip? of(Track track, {required String losslessLabel}) {
    if (track.tags == null || track.format == Format.notAudio) return null;
    final String name = track.formatStringShort;
    if (Track.isBitrateFormat(track.format)) {
      final int bitrate = track.safeTags.bitrate;
      return FormatChip(bitrate > 0 ? '$name $bitrate kbps' : name);
    }
    return FormatChip('$name \u00b7 $losslessLabel');
  }
}

class RecentlyAddedWidget extends StatelessWidget {
  const RecentlyAddedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return DatabaseBuilder(
      future: (database) => database.recents(20),
      builder: (context, database, recents) => ExtendedWrap(
        maxLines: 2,
        spacing: 24,
        runSpacing: 28,
        clipBehavior: Clip.hardEdge,
        children: recents.keys
            .toList()
            .map((a) => _RecentCard(track: recents[a]!.first))
            .toList(),
      ),
    );
  }
}

class _RecentCard extends StatefulWidget {
  static const double kSize = 176;
  final Track track;
  const _RecentCard({required this.track});

  @override
  State<_RecentCard> createState() => _RecentCardState();
}

class _RecentCardState extends State<_RecentCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context)!;
    final TraxColors colors = TraxColors.of(context);
    final Track track = widget.track;
    final FormatChip? chip =
        FormatChip.of(track, losslessLabel: t.recentLossless);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => eventBus.fire(SelectArtistAlbumEvent(
          track.safeTags.compilation
              ? Track.kArtistCompilations
              : track.safeTags.artist,
          track.safeTags.album,
        )),
        child: SizedBox(
          width: _RecentCard.kSize,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedScale(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                scale: _hovered ? 1.035 : 1,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: colors.shadow.withValues(
                          alpha: _hovered ? 0.5 : 0.25,
                        ),
                        blurRadius: _hovered ? 22 : 8,
                        offset: Offset(0, _hovered ? 10 : 2),
                      ),
                    ],
                  ),
                  child: AsyncArtwork(
                    track: track,
                    size: _RecentCard.kSize,
                    radius: 8,
                    defaultPlaceholderBorderColor: colors.line,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                track.displayAlbum,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: colors.text,
                  decoration: TextDecoration.none,
                ),
              ),
              Text(
                track.displayAlbumArtist,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: colors.muted,
                  decoration: TextDecoration.none,
                ),
              ),
              if (chip != null)
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: colors.hover,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      chip.text,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: colors.text,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
