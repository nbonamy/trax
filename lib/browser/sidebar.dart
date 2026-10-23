import 'package:flutter/material.dart';
import 'package:trax/l10n/app_localizations.dart';

import '../components/artist.dart';
import '../components/database_builder.dart';
import '../components/letter_rail.dart';
import '../data/database.dart';
import '../model/track.dart';
import '../utils/track_utils.dart';

/// A row of the source list: either a group caption or an artist.
class SidebarEntry {
  final String? header;
  final String? artist;
  final String? letter;
  const SidebarEntry.header(this.header)
      : artist = null,
        letter = null;
  const SidebarEntry.artist(this.artist, {this.letter}) : header = null;

  bool get isHeader => header != null;
}

/// Library entries first (Home, Compilations), then artists A to Z.
List<SidebarEntry> buildSidebarEntries(
  List<String> artists, {
  required String libraryLabel,
  required String artistsLabel,
}) {
  final List<SidebarEntry> entries = [
    SidebarEntry.header(libraryLabel),
    const SidebarEntry.artist(Track.kArtistsHome),
  ];
  if (artists.contains(Track.kArtistCompilations)) {
    entries.add(const SidebarEntry.artist(Track.kArtistCompilations));
  }
  entries.add(SidebarEntry.header(artistsLabel));
  for (final String artist in artists) {
    if (artist == Track.kArtistCompilations) continue;
    entries.add(SidebarEntry.artist(artist, letter: sidebarLetter(artist)));
  }
  return entries;
}

/// "The Alan Parsons Project" is filed under A, "2Pac" under #.
String sidebarLetter(String artist) {
  final String sortable = TrackUtils.getSortableArtist(artist).trim();
  if (sortable.isEmpty) return '#';
  final String first = sortable.substring(0, 1).toUpperCase();
  return RegExp(r'^[A-Z]$').hasMatch(first) ? first : '#';
}

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
  static const double _kRowExtent = ArtistWidget.kHeight + 2;
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
    AppLocalizations t = AppLocalizations.of(context)!;
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: DatabaseBuilder(
        future: (database) => database.artists(),
        cachedValue: _artists.isEmpty ? null : _artists,
        builder: (context, database, artists) {
          _artists = artists;
          final List<SidebarEntry> entries = buildSidebarEntries(
            artists,
            libraryLabel: t.sidebarLibrary,
            artistsLabel: t.sidebarArtists,
          );

          // first row of each letter, to jump to
          final Map<String, int> letterIndex = {};
          for (int i = 0; i < entries.length; i++) {
            final String? letter = entries[i].letter;
            if (letter != null) letterIndex.putIfAbsent(letter, () => i);
          }

          return Stack(
            children: [
              ListView.builder(
                controller: widget.scrollController,
                padding: const EdgeInsets.only(right: 16, bottom: 16),
                itemExtent: _kRowExtent,
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final SidebarEntry entry = entries[index];
                  if (entry.isHeader) {
                    return SidebarSectionHeader(label: entry.header!);
                  }
                  final String artist = entry.artist!;
                  return ArtistWidget(
                    name: artist,
                    selected: widget.artist != null && artist == widget.artist,
                    onSelectArtist: widget.onSelectArtist,
                  );
                },
              ),
              if (letterIndex.length > 3)
                Positioned(
                  top: 4,
                  right: 0,
                  bottom: 4,
                  width: 14,
                  child: LetterRail(
                    letters: letterIndex.keys.toList(),
                    onSelected: (letter) => _jumpTo(letterIndex[letter]!),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _jumpTo(int index) {
    if (!widget.scrollController.hasClients) return;
    final ScrollPosition position = widget.scrollController.position;
    widget.scrollController.animateTo(
      (index * _kRowExtent).clamp(0.0, position.maxScrollExtent),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
    );
  }

  void _refresh() {
    setState(() {
      _artists = [];
    });
  }
}
