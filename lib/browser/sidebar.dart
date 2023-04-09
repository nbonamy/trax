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
    return Column(
      children: [
        Expanded(
          child: ScrollConfiguration(
            behavior:
                ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: SingleChildScrollView(
              controller: widget.scrollController,
              child: Column(
                children: artists
                    .map<Widget>(
                      (artist) => ArtistWidget(
                        name: artist,
                        selected:
                            widget.artist != null && artist == widget.artist,
                        onSelectArtist: widget.onSelectArtist,
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ),
        if (true)
          Column(
            children: const [
              Divider(),
              SizedBox(height: 4),
              Text(
                'Scanning audio files...',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
      ],
    );
  }

  void _loadArtists() {
    setState(() {
      artists = TraxDatabase.of(context).artists();
    });
  }
}
