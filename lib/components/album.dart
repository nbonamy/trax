import 'dart:math';

import 'package:flutter/material.dart';
import 'package:taglib_ffi/taglib_ffi.dart';

import '../model/track.dart';
import 'album_artwork.dart';
import 'header_album.dart';
import 'track_list.dart';

class AlbumWidget extends StatefulWidget {
  final String title;
  final TrackList tracks;
  final Function onSelectTrack;
  final Function onExecuteTrack;
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
  final TagLib _tagLib = TagLib();

  @override
  Widget build(BuildContext context) {
    int trackCount = widget.tracks.length;
    int playtimeMinutes = (widget.tracks
                .fold(0, (time, track) => time + track.safeTags.duration) /
            60)
        .round()
        .toInt();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 48),
      child: LayoutBuilder(
        builder: (context, constraints) => Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder(
              future: _tagLib.getArtworkBytes(widget.tracks.first.filename),
              builder: (context, snapshot) => AlbumArtworkWidget(
                size: _artworkSize(constraints),
                bytes: snapshot.data,
                trackCount: trackCount,
                playtime: playtimeMinutes,
              ),
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
                    duration: widget.tracks.duration,
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
