import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:trax/components/header_artist.dart';
import 'package:trax/data/database.dart';

import '../components/album.dart';
import '../model/track.dart';

class BrowserContent extends StatefulWidget {
  final String? artist;
  const BrowserContent({super.key, this.artist});

  @override
  State<BrowserContent> createState() => _BrowserContentState();
}

class _BrowserContentState extends State<BrowserContent> {
  final ScrollController _controller = ScrollController();
  LinkedHashMap<String, List<Track>> _albums = LinkedHashMap();
  @override
  void initState() {
    super.initState();
    _loadAlbums();
    TraxDatabase.of(context).addListener(_loadAlbums);
  }

  @override
  void didUpdateWidget(BrowserContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller.hasClients) {
      _controller.jumpTo(0.0);
    }
    _loadAlbums();
  }

  @override
  void dispose() {
    TraxDatabase.of(context).removeListener(_loadAlbums);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.artist == null || _albums.isEmpty) {
      return Container();
    }
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 32, horizontal: 96),
      child: Column(
        children: [
          HeaderArtistWidget(
            artist: widget.artist!,
            albumCount: _albums.length,
            trackCount: _albums.values
                .fold(0, (count, tracks) => count + tracks.length),
          ),
          Expanded(
            child: ListView.builder(
              controller: _controller,
              itemCount: _albums.length,
              itemBuilder: (context, index) {
                String title = _albums.keys.elementAt(index);
                List<Track>? tracks = _albums[title];
                return AlbumWidget(
                  title: title,
                  tracks: tracks ?? [],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _loadAlbums() {
    if (widget.artist == null) {
      _albums.clear();
      setState(() {});
    } else {
      setState(() {
        _albums = TraxDatabase.of(context).albums(widget.artist!);
      });
    }
  }
}
