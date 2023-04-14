import 'package:flutter/material.dart';

import '../components/artist.dart';
import '../components/database_builder.dart';
import '../data/database.dart';
import '../model/track.dart';

class BrowserSidebar extends StatefulWidget {
  final ScrollController scrollController;
  final Function onSelectArtist;
  final String? artist;
  const BrowserSidebar({
    super.key,
    required this.scrollController,
    required this.onSelectArtist,
    required this.artist,
  });

  @override
  State<BrowserSidebar> createState() => _BrowserSidebarState();
}

class _BrowserSidebarState extends State<BrowserSidebar> {
  List<String> _artists = [];

  @override
  void initState() {
    super.initState();
    TraxDatabase.of(context).addListener(_refresh);
  }

  @override
  void dispose() {
    TraxDatabase.of(context).removeListener(_refresh);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: DatabaseBuilder(
        future: (database) => database.artists(),
        cachedValue: _artists.isEmpty ? null : _artists,
        builder: (context, database, artists) {
          _artists = artists;
          return ListView.builder(
            controller: widget.scrollController,
            itemCount: artists.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return ArtistWidget(
                  name: Track.kArtistsHome,
                  selected: widget.artist == Track.kArtistsHome,
                  onSelectArtist: widget.onSelectArtist,
                );
              } else {
                String artist = artists[index - 1];
                return ArtistWidget(
                  name: artist,
                  selected: widget.artist != null && artist == widget.artist,
                  onSelectArtist: widget.onSelectArtist,
                );
              }
            },
          );
        },
      ),
    );
  }

  void _refresh() {
    setState(() {
      _artists = [];
    });
  }
}
