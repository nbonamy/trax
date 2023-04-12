import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:trax/utils/file_utils.dart';

import '../components/album.dart';
import '../components/header_artist.dart';
import '../data/database.dart';
import '../editor/editor.dart';
import '../model/menu_actions.dart';
import '../model/selection.dart';
import '../model/track.dart';
import '../processors/saver.dart';
import '../utils/platform_keyboard.dart';

class BrowserContent extends StatefulWidget {
  final String? artist;
  final String? initialAlbum;
  final MenuActionStream menuActionStream;
  const BrowserContent({
    super.key,
    this.artist,
    this.initialAlbum,
    required this.menuActionStream,
  });

  @override
  State<BrowserContent> createState() => _BrowserContentState();
}

class _BrowserContentState extends State<BrowserContent> with MenuHandler {
  static const double _kVerticalPadding = 16.0;
  static const double _kHorizontalPadding = 64.0;
  final ItemScrollController _itemScrollController = ItemScrollController();
  LinkedHashMap<String, List<Track>> _albums = LinkedHashMap();
  TraxDatabase? database;

  List<Track> get allTracks =>
      _albums.values.fold([], (all, tracks) => [...all, ...tracks]);

  @override
  void initState() {
    super.initState();
    _loadAlbums();
    initMenuSubscription(widget.menuActionStream);
    database = TraxDatabase.of(context);
    database?.addListener(_loadAlbums);
  }

  @override
  void didUpdateWidget(BrowserContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadAlbums();
  }

  @override
  void didChangeDependencies() {
    database?.removeListener(_loadAlbums);
    database = TraxDatabase.of(context);
    database?.addListener(_loadAlbums);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    cancelMenuSubscription();
    database?.removeListener(_loadAlbums);
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
            child: ScrollablePositionedList.builder(
              itemScrollController: _itemScrollController,
              initialScrollIndex: widget.initialAlbum == null
                  ? 0
                  : max(0, _albums.keys.toList().indexOf(widget.initialAlbum!)),
              itemCount: _albums.length,
              itemBuilder: (context, index) {
                String title = _albums.keys.elementAt(index);
                List<Track>? tracks = _albums[title];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: _kHorizontalPadding,
                  ),
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
      case MenuAction.editDelete:
        _deleteFiles(
          TraxDatabase.of(context),
          selectionModel.get.map((t) => t.filename).toList(),
        );
        break;
      case MenuAction.trackInfo:
        _showEditor(EditorMode.edit, selectionModel.get, allTracks);
        break;
      default:
        break;
    }
  }

  _deleteFiles(TraxDatabase database, List<String> files) async {
    bool? rc = await FileUtils.confirmDelete(context, files);
    if (rc != null && rc) {
      for (String filename in files) {
        database.delete(filename, notify: false);
      }
      database.notify();
    }
  }

  void _showEditor(
    EditorMode editorMode,
    List<Track> selection,
    List<Track> allTracks,
  ) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          child: TagEditorWidget(
            editorMode: editorMode,
            menuActionStream: widget.menuActionStream,
            selection: selection,
            allTracks: allTracks,
          ),
        );
      },
    );
  }
}
