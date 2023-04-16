// ignore_for_file: prefer_collection_literals

import 'dart:collection';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:trax/audioplayer/audio_player.dart';

import '../components/album.dart';
import '../components/database_builder.dart';
import '../components/header_artist.dart';
import '../data/database.dart';
import '../editor/editor.dart';
import '../model/menu_actions.dart';
import '../model/preferences.dart';
import '../model/selection.dart';
import '../model/track.dart';
import '../processors/saver.dart';
import '../utils/file_utils.dart';
import '../utils/path_utils.dart';
import '../utils/platform_keyboard.dart';

class BrowserContent extends StatefulWidget {
  final String? artist;
  final String? initialAlbum;
  const BrowserContent({
    super.key,
    this.artist,
    this.initialAlbum,
  });

  @override
  State<BrowserContent> createState() => _BrowserContentState();
}

class _BrowserContentState extends State<BrowserContent> with MenuHandler {
  static const double _kVerticalPadding = 16.0;
  static const double _kHorizontalPadding = 64.0;
  final ItemScrollController _itemScrollController = ItemScrollController();
  AlbumList _albums = LinkedHashMap();
  late TraxDatabase database;

  @override
  void initState() {
    super.initState();
    initMenuSubscription();
    database = TraxDatabase.of(context);
    database.addListener(_refresh);
  }

  @override
  void didUpdateWidget(covariant BrowserContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    _itemScrollController.jumpTo(index: 0);
    _albums = AlbumList();
  }

  @override
  void didChangeDependencies() {
    database.removeListener(_refresh);
    database = TraxDatabase.of(context);
    database.addListener(_refresh);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    cancelMenuSubscription();
    database.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() async {
    setState(() {
      _albums = AlbumList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.artist == null) {
      return Container();
    }
    return DatabaseBuilder<AlbumList>(
      future: (database) => database.albums(widget.artist!),
      cachedValue: _albums.isEmpty ? null : _albums,
      builder: (context, database, albums) {
        _albums = albums;
        if (_albums.isEmpty) {
          return Container();
        }
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: _kVerticalPadding),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: _kHorizontalPadding,
                ),
                child: HeaderArtistWidget(
                  artist: widget.artist!,
                  albums: _albums.keys.toList(),
                  trackCount: _albums.allTracks.length,
                  onAlbumSelected: (i) =>
                      _itemScrollController.jumpTo(index: i),
                ),
              ),
              Expanded(
                child: ScrollablePositionedList.builder(
                  itemScrollController: _itemScrollController,
                  initialScrollIndex: max(0,
                      _albums.keys.toList().indexOf(widget.initialAlbum ?? '')),
                  itemCount: _albums.length,
                  itemBuilder: (context, index) {
                    String title = _albums.keys.elementAt(index);
                    TrackList? tracks = _albums[title];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: _kHorizontalPadding,
                      ),
                      child: AlbumWidget(
                        title: title,
                        tracks: tracks ?? [],
                        onSelectTrack: _select,
                        onExecuteTrack: _execute,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _select(Track track, TrackList siblings) {
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

  void _execute(Track track, TrackList siblings) {
    AudioPlayer audioPlayer = AudioPlayer.of(context);
    audioPlayer.play(
      siblings,
      initialIndex: siblings.indexOf(track),
    );
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
      for (TrackList tracks in _albums.values) {
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

  @override
  void onMenuAction(MenuAction action) {
    SelectionModel selectionModel = SelectionModel.of(context);
    switch (action) {
      case MenuAction.fileReveal:
        _revealInFinder();
        break;
      case MenuAction.editSelectAll:
        selectionModel.set(_albums.allTracks);
        break;
      case MenuAction.editDelete:
        _deleteFiles(
          selectionModel.get.map((t) => t.filename).toList(),
          Preferences.of(context).musicFolder,
        );
        break;
      case MenuAction.trackInfo:
        _showEditor(EditorMode.edit, selectionModel.get, _albums.allTracks);
        break;
      default:
        break;
    }
  }

  _revealInFinder() {
    SelectionModel selectionModel = SelectionModel.of(context);
    if (selectionModel.get.length != 1) return;
    Process.run('open', ['-R', selectionModel.get.first.filename]);
  }

  _deleteFiles(List<String> files, String rootFolder) async {
    bool? rc = await FileUtils.confirmDelete(context, files);
    if (rc != null && rc) {
      for (String filename in files) {
        // delete from database
        database.delete(filename, notify: false);

        // check if directory empty
        PathUtils.deleteEmptyFolder(p.dirname(filename), rootFolder);
      }
      database.notify();
    }
  }

  void _showEditor(
    EditorMode editorMode,
    TrackList selection,
    TrackList allTracks,
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
            selection: selection,
            allTracks: allTracks,
          ),
        );
      },
    );
  }
}
