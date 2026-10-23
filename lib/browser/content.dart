import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:trax/audioplayer/audio_player.dart';
import 'package:trax/audioplayer/glass_player.dart';
import 'package:trax/l10n/app_localizations.dart';
import 'package:trax/utils/track_utils.dart';

import '../components/album.dart';
import '../components/database_builder.dart';
import '../components/header_artist.dart';
import '../components/header_collection.dart';
import '../components/track.dart' show TrackColumns;
import '../components/trax_colors.dart';
import '../data/database.dart';
import '../editor/editor.dart';
import '../model/library_health.dart';
import '../model/library_query.dart';
import '../model/menu_actions.dart';
import '../model/preferences.dart';
import '../model/selection.dart';
import '../model/track.dart';
import '../processors/saver.dart';
import '../processors/tagger.dart';
import '../screens/transcoder.dart';
import '../utils/file_utils.dart';
import '../utils/path_utils.dart';
import '../utils/platform_keyboard.dart';

/// An artist's albums, the results of a search, or the data of a review:
/// the same album + track table, fed by a different query.
class BrowserContent extends StatefulWidget {
  final String? artist;
  final String? initialAlbum;
  final String? query;
  final ReviewKind? review;
  final VoidCallback? onBack;
  const BrowserContent({
    super.key,
    this.artist,
    this.initialAlbum,
    this.query,
    this.review,
    this.onBack,
  });

  bool get isCollection => artist == null;

  @override
  State<BrowserContent> createState() => _BrowserContentState();
}

class _BrowserContentState extends State<BrowserContent> with MenuHandler {
  static const double _kVerticalPadding = 16.0;
  static const double _kHorizontalPadding = 64.0;
  final ItemScrollController _itemScrollController = ItemScrollController();
  List<AlbumGroup> _groups = [];
  late TraxDatabase database;
  Track? _extendSelectionBase;

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
    if (_itemScrollController.isAttached) {
      _itemScrollController.jumpTo(index: 0);
    }
    _extendSelectionBase = null;
    _groups = [];
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

  // @override
  // void setState(VoidCallback fn) {
  //   super.setState(fn);
  // }

  void _refresh() async {
    setState(() {
      _groups = [];
    });
  }

  TrackList get _allTracks => _groups.fold<TrackList>(
        [],
        (all, group) => [...all, ...group.tracks],
      );

  Future<List<AlbumGroup>> _load(TraxDatabase database) async {
    if (widget.review != null) {
      return LibraryQuery.groupAlbums(
        await database.reviewTracks(widget.review!),
      );
    }
    if (widget.artist == null) {
      return LibraryQuery.groupAlbums(
        await database.searchTracks(widget.query ?? ''),
      );
    }
    final AlbumList albums = await database.albums(widget.artist!);
    return albums.entries
        .map((e) => AlbumGroup(widget.artist!, e.key, e.value))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.artist == null && widget.review == null) {
      if ((widget.query ?? '').trim().isEmpty) return Container();
    }
    final AppLocalizations t = AppLocalizations.of(context)!;
    return DatabaseBuilder<List<AlbumGroup>>(
      future: _load,
      cachedValue: _groups.isEmpty ? null : _groups,
      builder: (context, database, groups) {
        _groups = groups;
        if (groups.isEmpty && !widget.isCollection) {
          return Container();
        }
        final TrackList all = _allTracks;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: _kVerticalPadding),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: _kHorizontalPadding,
                ),
                child: widget.isCollection
                    ? HeaderCollectionWidget(
                        title: _collectionTitle(t),
                        albumCount: groups.length,
                        trackCount: all.length,
                        hint: _collectionHint(t),
                        onBack: widget.onBack,
                      )
                    : HeaderArtistWidget(
                        artist: widget.artist!,
                        albums: groups.map((g) => g.album).toList(),
                        trackCount: all.length,
                        onAlbumSelected: (i) =>
                            _itemScrollController.jumpTo(index: i),
                      ),
              ),
              Expanded(
                child: groups.isEmpty
                    ? _emptyState(t)
                    : ScrollablePositionedList.builder(
                        itemScrollController: _itemScrollController,
                        padding: const EdgeInsets.only(
                          bottom: GlassPlayerBar.kContentInset,
                        ),
                        initialScrollIndex: max(
                            0,
                            groups
                                .map((g) => g.album)
                                .toList()
                                .indexOf(widget.initialAlbum ?? '')),
                        itemCount: groups.length,
                        itemBuilder: (context, index) {
                          final AlbumGroup group = groups[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: _kHorizontalPadding,
                            ),
                            child: AlbumWidget(
                              title: group.album,
                              artist: widget.isCollection ? group.artist : null,
                              columns: _columns,
                              tracks: group.tracks,
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

  /// In a review the column that holds the problem is on screen.
  TrackColumns get _columns {
    switch (widget.review) {
      case ReviewKind.mixedGenres:
        return const TrackColumns(genre: true);
      case ReviewKind.noYear:
        return const TrackColumns(year: true);
      case null:
        return const TrackColumns();
    }
  }

  String _collectionTitle(AppLocalizations t) {
    switch (widget.review) {
      case ReviewKind.mixedGenres:
        return t.reviewMixedGenresTitle;
      case ReviewKind.noYear:
        return t.reviewNoYearTitle;
      case null:
        return t.searchResultsTitle(widget.query!.trim());
    }
  }

  String? _collectionHint(AppLocalizations t) {
    switch (widget.review) {
      case ReviewKind.mixedGenres:
        return t.reviewMixedGenresHint;
      case ReviewKind.noYear:
        return t.reviewNoYearHint;
      case null:
        return null;
    }
  }

  Widget _emptyState(AppLocalizations t) {
    final String text = widget.review != null
        ? t.tidyAllGood
        : t.searchNoResults(widget.query!.trim());
    return Padding(
      padding: const EdgeInsets.all(_kHorizontalPadding),
      child: Align(
        alignment: Alignment.topLeft,
        child:
            Text(text, style: TextStyle(color: TraxColors.of(context).muted)),
      ),
    );
  }

  void _execute(Track track, TrackList siblings) {
    AudioPlayer audioPlayer = AudioPlayer.of(context);
    audioPlayer.play(
      siblings,
      initialIndex: siblings.indexOf(track),
    );
  }

  void _select(Track track, TrackList siblings) {
    if (PlatformKeyboard.selectionExtendActive) {
      _extendSelect(track);
    } else {
      _normalSelect(track);
    }
  }

  void _normalSelect(Track track) {
    SelectionModel selectionModel = SelectionModel.of(context);
    if (PlatformKeyboard.selectionToggleActive) {
      selectionModel.toggle(track);
    } else {
      selectionModel.set([track]);
    }
    _extendSelectionBase = track;
  }

  void _extendSelect(Track track) {
    // if we have no base then normal select
    if (_extendSelectionBase == null) {
      _normalSelect(track);
      return;
    }

    // reset if not toggle
    SelectionModel selectionModel = SelectionModel.of(context);
    if (!PlatformKeyboard.selectionToggleActive) {
      selectionModel.clear(notify: false);
    }

    // we need base and track indexes
    int baseIndex = _allTracks.indexOf(_extendSelectionBase!);
    int trackIndex = _allTracks.indexOf(track);
    int rangeStart = min(baseIndex, trackIndex);
    int rangeEnd = max(baseIndex, trackIndex) + 1;

    // now add all
    _allTracks
        .getRange(rangeStart, rangeEnd)
        .forEach((t) => selectionModel.add(t, notify: false));
    selectionModel.notify();
  }

  @override
  void onMenuAction(MenuAction action) {
    SelectionModel selectionModel = SelectionModel.of(context);
    switch (action) {
      case MenuAction.fileReveal:
        _revealInFinder();
        break;
      case MenuAction.editSelectAllAlbum:
        _selectAllAlbum();
        break;
      case MenuAction.editSelectAllArtist:
        _selectAllArtist();
        break;
      case MenuAction.editDelete:
        _deleteFiles(
          selectionModel.get.map((t) => t.filename).toList(),
          Preferences.of(context).musicFolder,
        );
        break;
      case MenuAction.trackInfo:
        _showEditor(EditorMode.edit, selectionModel.get, _allTracks);
        break;
      case MenuAction.trackCleanupTitles:
        _cleanupTitles(selectionModel.get);
        break;
      case MenuAction.trackTranscode:
        _showTranscoder(selectionModel.get);
        break;
      default:
        break;
    }
  }

  void _selectAllAlbum() {
    SelectionModel selectionModel = SelectionModel.of(context);
    List<Track> selection = selectionModel.get;
    if (selection.isEmpty) {
      _selectAllArtist();
      return;
    }
    String album = selection.first.displayAlbum;
    for (int i = 1; i < selection.length; i++) {
      if (selection[i].displayAlbum != album) {
        //_selectAllArtist();
        return;
      }
    }

    // ok all tracks are from same album so let's select them all
    selectionModel
        .set(_allTracks.where((t) => t.displayAlbum == album).toList());
  }

  void _selectAllArtist() {
    SelectionModel selectionModel = SelectionModel.of(context);
    selectionModel.set(_allTracks);
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
    TagEditorWidget.show(
      context,
      editorMode,
      selection,
      allTracks: allTracks,
    );
  }

  void _cleanupTitles(TrackList selection) {
    Tagger tagger = Tagger(context, database);
    tagger.cleanupTitles(selection);
  }

  void _showTranscoder(
    TrackList selection,
  ) {
    TranscoderWidget.show(
      context,
      selection: selection,
    );
  }
}
