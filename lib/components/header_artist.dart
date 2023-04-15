import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';

import '../utils/consts.dart';
import '../utils/track_utils.dart';

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
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 32, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  TrackUtils.getDisplayArtist(widget.artist),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
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
          const SizedBox(height: 8),
          const Divider(),
          Text(
            '${widget.albums.length} ALBUMS, ${widget.trackCount} SONGS',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black.withOpacity(Consts.fadedOpacity),
            ),
          ),
        ],
      ),
    );
  }
}
