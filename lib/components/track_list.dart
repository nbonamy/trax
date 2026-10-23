import 'package:flutter/material.dart';
import 'package:trax/l10n/app_localizations.dart';

import '../model/track.dart';
import '../utils/track_utils.dart';
import 'album.dart';
import 'track.dart';
import 'trax_colors.dart';

class TrackListWidget extends StatelessWidget {
  final TrackList tracks;
  final TrackCallback onSelectTrack;
  final TrackCallback onExecuteTrack;
  final bool shrinkWrap;
  final bool primary;
  final TrackColumns columns;
  const TrackListWidget({
    super.key,
    required this.tracks,
    required this.onSelectTrack,
    required this.onExecuteTrack,
    this.shrinkWrap = true,
    this.primary = true,
    this.columns = const TrackColumns(),
  });

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context)!;
    final TraxColors colors = TraxColors.of(context);
    final bool sameVolume = _areAllSameVolume();
    int previousVolume = -1;

    final TextStyle headerStyle = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: colors.faint,
    );

    final List<Widget> rows = [];
    for (int i = 0; i < tracks.length; i++) {
      if (!sameVolume && tracks[i].volumeIndex != previousVolume) {
        rows.add(_discHeader(tracks[i], i == 0, headerStyle));
      }
      previousVolume = tracks[i].volumeIndex;
      rows.add(TrackWidget(
        track: tracks[i],
        index: i,
        columns: columns,
        onTap: (track) => onSelectTrack(track, tracks),
        onDoubleTap: (track) => onExecuteTrack(track, tracks),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // column titles
        Container(
          height: 26,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: colors.line, width: 0.5)),
          ),
          child: Row(
            children: [
              SizedBox(width: 36, child: Text('#', style: headerStyle)),
              Expanded(child: Text(t.trackColumnTitle, style: headerStyle)),
              if (columns.genre)
                SizedBox(
                  width: 110,
                  child: Text(t.trackColumnGenre, style: headerStyle),
                ),
              if (columns.year)
                SizedBox(
                  width: 56,
                  child: Text(t.trackColumnYear, style: headerStyle),
                ),
              SizedBox(
                width: 112,
                child: Text(t.trackColumnFormat, style: headerStyle),
              ),
              SizedBox(
                width: 48,
                child: Text(
                  t.trackColumnTime,
                  textAlign: TextAlign.right,
                  style: headerStyle,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        ...rows,
      ],
    );
  }

  Widget _discHeader(Track track, bool first, TextStyle style) {
    return Padding(
      padding: EdgeInsets.fromLTRB(12, first ? 8 : 20, 12, 6),
      child: Text('Disc ${track.volumeIndex}'.toUpperCase(), style: style),
    );
  }

  bool _areAllSameVolume() {
    for (Track track in tracks) {
      if (track.volumeIndex != tracks.first.volumeIndex) {
        return false;
      }
    }
    return true;
  }
}
