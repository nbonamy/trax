import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:trax/components/header_artist.dart';
import 'package:trax/data/database.dart';
import 'package:trax/model/selection.dart';
import 'package:trax/screens/editor.dart';
import 'package:trax/utils/platform_keyboard.dart';

import '../components/album.dart';
import '../model/menu_actions.dart';
import '../model/track.dart';

class BrowserContent extends StatefulWidget {
  final String? artist;
  final MenuActionStream menuActionStream;
  const BrowserContent({
    super.key,
    this.artist,
    required this.menuActionStream,
  });

  @override
  State<BrowserContent> createState() => _BrowserContentState();
}

class _BrowserContentState extends State<BrowserContent> with MenuHandler {
  static const double _kVerticalPadding = 16.0;
  static const double _kHorizontalPadding = 64.0;
  final ScrollController _controller = ScrollController();
  LinkedHashMap<String, List<Track>> _albums = LinkedHashMap();

  List<Track> get allTracks =>
      _albums.values.fold([], (all, tracks) => [...all, ...tracks]);

  @override
  void initState() {
    super.initState();
    _loadAlbums();
    initMenuSubscription(widget.menuActionStream);
    TraxDatabase.of(context).addListener(_loadAlbums);
  }

  @override
  void didUpdateWidget(BrowserContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller.hasClients) {
      _controller.jumpTo(0.0);
    }
    _loadAlbums();
  }

  @override
  void dispose() {
    cancelMenuSubscription();
    TraxDatabase.of(context).removeListener(_loadAlbums);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.artist == null || _albums.isEmpty) {
      return Container();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: _kVerticalPadding),
      child: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: _kHorizontalPadding),
            child: HeaderArtistWidget(
              artist: widget.artist!,
              albumCount: _albums.length,
              trackCount: _albums.values
                  .fold(0, (count, tracks) => count + tracks.length),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _controller,
              itemCount: _albums.length,
              itemBuilder: (context, index) {
                String title = _albums.keys.elementAt(index);
                List<Track>? tracks = _albums[title];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: _kHorizontalPadding),
                  child: AlbumWidget(
                    title: title,
                    tracks: tracks ?? [],
                    onSelect: _select,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _select(Track track) {
    // extended selection
    if (PlatformKeyboard.selectionExtendActive) {
      _extendSelect(track);
      return;
    }

    SelectionModel selectionModel = SelectionModel.of(context);
    bool selected = selectionModel.contains(track);
    if (PlatformKeyboard.selectionToggleActive) {
      if (selected) {
        selectionModel.remove(track);
      } else {
        selectionModel.add(track);
      }
    } else {
      selectionModel.set([track]);
    }
  }

  void _extendSelect(Track track) {
    SelectionModel selectionModel = SelectionModel.of(context);
    Track? lastSelected = selectionModel.lastSelected;
    if (lastSelected == null) {
      selectionModel.set([track]);
    } else {
      if (!PlatformKeyboard.selectionToggleActive) {
        selectionModel.set([lastSelected], notify: false);
      }
      bool inBetween = false;
      for (List<Track> tracks in _albums.values) {
        for (Track t in tracks) {
          if (inBetween) {
            selectionModel.add(t);
          }
          if (t == track || t == lastSelected) {
            if (inBetween) {
              return;
            }
            inBetween = true;
          }
        }
      }
    }
  }

  void _loadAlbums() {
    if (widget.artist == null) {
      _albums.clear();
      setState(() {});
    } else {
      setState(() {
        _albums = TraxDatabase.of(context).albums(widget.artist!);
      });
    }
  }

  @override
  void onMenuAction(MenuAction action) {
    SelectionModel selectionModel = SelectionModel.of(context);
    switch (action) {
      case MenuAction.editSelectAll:
        selectionModel.set(allTracks);
        break;
      case MenuAction.trackInfo:
        showDialog(
            context: context,
            barrierColor: Colors.transparent,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                content: TagEditorWidget(
                  selection: selectionModel.get,
                  allTracks: allTracks,
                ),
              );
            });
        break;
      default:
        break;
    }
  }
}
