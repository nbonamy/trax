import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:trax/l10n/app_localizations.dart';

import '../utils/track_utils.dart';
import 'trax_colors.dart';

class HeaderArtistWidget extends StatefulWidget {
  final String artist;
  final List<String> albums;
  final int trackCount;
  final Function onAlbumSelected;
  const HeaderArtistWidget({
    super.key,
    required this.artist,
    required this.albums,
    required this.trackCount,
    required this.onAlbumSelected,
  });

  @override
  State<HeaderArtistWidget> createState() => _HeaderArtistWidgetState();
}

class _HeaderArtistWidgetState extends State<HeaderArtistWidget> {
  String _selectedAlbum = '';

  @override
  void initState() {
    super.initState();
    _selectedAlbum = widget.albums.first;
  }

  @override
  void didUpdateWidget(covariant HeaderArtistWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _selectedAlbum = widget.albums.first;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context)!;
    final TraxColors colors = TraxColors.of(context);
    return Container(
      color: colors.background,
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  TrackUtils.getDisplayArtist(widget.artist),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 28,
                    letterSpacing: -0.5,
                    color: colors.text,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  t.albumsAndSongs(widget.albums.length, widget.trackCount),
                  style: TextStyle(fontSize: 13, color: colors.muted),
                ),
              ],
            ),
          ),
          if (widget.albums.length > 1)
            MacosPopupButton(
              items: widget.albums
                  .map((e) => MacosPopupMenuItem(value: e, child: Text(e)))
                  .toList(),
              value: _selectedAlbum,
              onChanged: (a) {
                if (a != null) {
                  widget.onAlbumSelected(widget.albums.indexOf(a));
                  setState(() => _selectedAlbum = a);
                }
              },
            ),
        ],
      ),
    );
  }
}
