import 'package:flutter/material.dart';
import 'package:trax/components/artist.dart';
import 'package:trax/data/database.dart';

class BrowserSidebar extends StatefulWidget {
  final ScrollController scrollController;
  final Function onSelectArtist;
  final String? artist;
  const BrowserSidebar(
      {super.key,
      required this.scrollController,
      required this.onSelectArtist,
      required this.artist});

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
    return ListView.builder(
      itemCount: artists.length,
      itemBuilder: (context, index) => ArtistWidget(
        name: artists[index],
        selected: widget.artist != null && artists[index] == widget.artist,
        onSelectArtist: widget.onSelectArtist,
      ),
      controller: widget.scrollController,
    );
  }

  void _loadArtists() {
    setState(() {
      artists = TraxDatabase.of(context).artists();
    });
  }
}
