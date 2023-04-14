import 'package:flutter/material.dart';

import '../components/artist.dart';
import '../components/database_builder.dart';
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
        builder: (context, database, artists) => ListView.builder(
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
      ),
    );
  }

  void _refresh() {
    setState(() {});
  }
}
