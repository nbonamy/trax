import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:taglib_ffi/taglib_ffi.dart';
import 'package:trax/components/artwork.dart';
import 'package:trax/components/header_album.dart';
import 'package:trax/components/track_list.dart';

import '../model/track.dart';

class AlbumWidget extends StatefulWidget {
  final String title;
  final List<Track> tracks;
  final Function onSelect;
  const AlbumWidget({
    super.key,
    required this.title,
    required this.tracks,
    required this.onSelect,
  });

  @override
  State<AlbumWidget> createState() => _AlbumWidgetState();
}

class _AlbumWidgetState extends State<AlbumWidget> {
  final TagLib _tagLib = TagLib();
  late Uint8List? _artworkBytes;

  @override
  void initState() {
    super.initState();
    _getArtwork();
  }

  @override
  void didUpdateWidget(AlbumWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _getArtwork();
  }

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
            if (_artworkBytes != null)
              ArtworkWidget(
                size: _artworkSize(constraints),
                bytes: _artworkBytes!,
                trackCount: trackCount,
                playtime: playtimeMinutes,
              )
            else
              SizedBox(
                width: _artworkSize(constraints),
                height: _artworkSize(constraints),
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
                  ),
                  const SizedBox(height: 24),
                  TrackListWidget(
                    tracks: widget.tracks,
                    onSelect: widget.onSelect,
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

  void _getArtwork() {
    setState(() {
      _artworkBytes = _tagLib.getArtworkBytes(widget.tracks.first.filename);
    });
  }
}
