import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:trax/components/artist.dart';
import 'package:trax/data/database.dart';

import '../utils/events.dart';

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
  String? _statusMessage;
  @override
  void initState() {
    super.initState();
    _loadArtists();
    TraxDatabase.of(context).addListener(_loadArtists);
    eventBus.on().listen(onEvent);
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
          ),
        ),
        if (_statusMessage != null)
          Column(
            children: [
              const Divider(),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _statusMessage!,
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: LoadingAnimationWidget.staggeredDotsWave(
                      color: Colors.black.withOpacity(0.8),
                      size: 12,
                    ),
                  ),
                ],
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

  void onEvent(event) {
    if (event is BackgroundActionStartEvent &&
        event.action == BackgroundAction.scan) {
      setState(() => _statusMessage = 'Scanning audio files');
    }
    if (event is BackgroundActionEndEvent &&
        event.action == BackgroundAction.scan) {
      setState(() => _statusMessage = null);
    }
  }
}
