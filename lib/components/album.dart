import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../model/track.dart';
import 'album_artwork.dart';
import 'header_album.dart';
import 'track_list.dart';

typedef TrackCallback = void Function(Track, TrackList);

class AlbumWidget extends StatefulWidget {
  final String title;
  final TrackList tracks;
  final TrackCallback onSelectTrack;
  final TrackCallback onExecuteTrack;
  const AlbumWidget({
    super.key,
    required this.title,
    required this.tracks,
    required this.onSelectTrack,
    required this.onExecuteTrack,
  });

  @override
  State<AlbumWidget> createState() => _AlbumWidgetState();
}

class _AlbumWidgetState extends State<AlbumWidget> {
  @override
  Widget build(BuildContext context) {
    int trackCount = widget.tracks.length;
    int filesize =
        widget.tracks.fold(0, (size, track) => size + track.filesize);
    int playtimeMinutes = (widget.tracks
                .fold(0, (time, track) => time + track.safeTags.duration) /
            60)
        .round()
        .toInt();

    AppLocalizations t = AppLocalizations.of(context)!;
    String formatString = widget.tracks.first.formatStringShort;
    String formatDescription = widget.tracks.first.formatDescription;
    for (Track track in widget.tracks) {
      if (track.formatStringShort != formatString) {
        formatString = t.variousFormats;
        formatDescription = '';
        break;
      } else if (track.formatDescription != formatDescription) {
        formatDescription = t.variousFormats;
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 48),
      child: LayoutBuilder(
        builder: (context, constraints) => Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AlbumArtworkWidget(
              track: widget.tracks.first,
              size: _artworkSize(constraints),
              trackCount: trackCount,
              playtime: playtimeMinutes,
              format: '$formatString $formatDescription',
              filesize: filesize,
            ),
            SizedBox(width: _artworkSize(constraints) == 0 ? 0 : 48),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  HeaderAlbumWidget(
                    title: widget.title,
                    genre: widget.tracks.first.safeTags.genre,
                    year: widget.tracks.first.safeTags.year,
                    duration: 0, //widget.tracks.duration,
                  ),
                  const SizedBox(height: 24),
                  TrackListWidget(
                    tracks: widget.tracks,
                    onSelectTrack: widget.onSelectTrack,
                    onExecuteTrack: widget.onExecuteTrack,
                    primary: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _artworkSize(BoxConstraints constraints) {
    double size = constraints.maxWidth / 2 - 50.0;
    return size < 150.0 ? 0.0 : min(size, 300.0);
  }
}
