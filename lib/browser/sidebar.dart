import 'package:flutter/material.dart';

import '../components/artist.dart';
import '../data/database.dart';

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
  List<String> artists = [];
  @override
  void initState() {
    super.initState();
    _loadArtists();
    TraxDatabase.of(context).addListener(_loadArtists);
  }

  @override
  void dispose() {
    TraxDatabase.of(context).removeListener(_loadArtists);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: ListView.builder(
        controller: widget.scrollController,
        itemCount: artists.length,
        itemBuilder: (context, index) {
          String artist = artists[index];
          return ArtistWidget(
            name: artist,
            selected: widget.artist != null && artist == widget.artist,
            onSelectArtist: widget.onSelectArtist,
          );
        },
      ),
    );
  }

  void _loadArtists() {
    setState(() {
      artists = TraxDatabase.of(context).artists();
    });
  }
}
