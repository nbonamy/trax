import 'dart:collection';

import 'package:flutter/cupertino.dart';
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
  LinkedHashMap<String, List<Track>> _albums = LinkedHashMap();
  @override
  void initState() {
    super.initState();
    _loadAlbums();
  }

  @override
  void didUpdateWidget(BrowserContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadAlbums();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _albums.length,
      itemBuilder: (context, index) {
        String title = _albums.keys.elementAt(index);
        List<Track>? tracks = _albums[title];
        return AlbumWidget(
          title: title,
          tracks: tracks ?? [],
        );
      },
    );
  }

  void _loadAlbums() {
    if (widget.artist == null) {
      setState(() {
        _albums = LinkedHashMap.identity();
      });
    } else {
      setState(() {
        _albums = TraxDatabase.of(context).albums(widget.artist!);
      });
    }
  }
}
