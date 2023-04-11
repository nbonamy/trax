import 'dart:collection';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:taglib_ffi/taglib_ffi.dart';
import 'package:trax/utils/file_utils.dart';

import '../components/album.dart';
import '../components/header_artist.dart';
import '../data/database.dart';
import '../editor/editor.dart';
import '../model/menu_actions.dart';
import '../model/selection.dart';
import '../model/track.dart';
import '../processors/saver.dart';
import '../utils/events.dart';
import '../utils/platform_keyboard.dart';

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
      case MenuAction.fileImport:
        _import();
        break;
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

  void _import() async {
    // get some files
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: true,
      allowedExtensions: ['mp3', 'm4a', 'flac'],
    );
    if (result == null) return;

    // we need to parse them
    List<Track> tracks = [];
    TagLib tagLib = TagLib();
    eventBus.fire(BackgroundActionStartEvent(BackgroundAction.import));
    for (String? filepath in result.paths) {
      if (filepath == null) continue;
      Track track = Track.parse(filepath, tagLib);
      tracks.add(track);
    }
    eventBus.fire(BackgroundActionEndEvent(BackgroundAction.import));

    // now show import
    _showEditor(EditorMode.import, UnmodifiableListView(tracks), []);
  }

  void _showEditor(
    EditorMode editorMode,
    UnmodifiableListView<Track> selection,
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
