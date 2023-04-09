import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:taglib_ffi/taglib_ffi.dart';
import 'package:trax/components/track.dart';

import '../model/track.dart';

class AlbumWidget extends StatefulWidget {
  final String title;
  final List<Track> tracks;
  const AlbumWidget({
    super.key,
    required this.title,
    required this.tracks,
  });

  @override
  State<AlbumWidget> createState() => _AlbumWidgetState();
}

class _AlbumWidgetState extends State<AlbumWidget> {
  final TagLib _tagLib = TagLib();
  late Uint8List _artworkBytes;

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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 64),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 350,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.memory(
                    _artworkBytes,
                    width: 350,
                    height: 350,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.tracks.length.toString()} SONGS',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 48),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${widget.tracks.first.safeTags.genre.toUpperCase()} · ${widget.tracks.first.safeTags.year}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black.withOpacity(0.4),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 24),
                ListView.separated(
                  shrinkWrap: true,
                  primary: false,
                  //physics: ScrollPhysics.,
                  //controller: widget.controller,
                  itemCount: widget.tracks.length + 2,
                  itemBuilder: (context, index) {
                    if (index == 0 || index > widget.tracks.length) {
                      //<= here is problem
                      return Container();
                    } else {
                      return TrackWidget(
                        track: widget.tracks[index - 1],
                      );
                    }
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const Divider(height: 0.5);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _getArtwork() {
    setState(() {
      _artworkBytes = _tagLib.getArtworkBytes(widget.tracks.first.filename)!;
    });
  }
}
