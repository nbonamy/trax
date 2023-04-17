import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:taglib_ffi/taglib_ffi.dart';

import '../components/artwork_async.dart';
import '../components/button.dart';
import '../components/dialog.dart';
import '../components/draggable_dialog.dart';
import '../components/tab_view.dart';
import '../data/database.dart';
import '../model/editable_tags.dart';
import '../model/menu_actions.dart';
import '../model/preferences.dart';
import '../model/track.dart';
import '../processors/saver.dart';
import '../utils/artwork_provider.dart';
import '../utils/track_utils.dart';
import 'artwork.dart';
import 'details.dart';
import 'file.dart';
import 'lyrics.dart';

class TagEditorWidget extends StatefulWidget {
  final TrackList selection;
  final EditorMode editorMode;
  final TrackList allTracks;
  final Function? onComplete;
  final bool notify;
  const TagEditorWidget({
    super.key,
    required this.editorMode,
    required this.selection,
    this.allTracks = const [],
    this.notify = true,
    this.onComplete,
  });

  @override
  State<TagEditorWidget> createState() => _TagEditorWidgetState();

  static void show(
    BuildContext context,
    EditorMode editorMode,
    TrackList selection, {
    TrackList allTracks = const [],
    Function? onComplete,
    bool notify = true,
  }) {
    // check
    if (selection.isEmpty) {
      return;
    }

    // show
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
            onComplete: onComplete,
            notify: notify,
          ),
        );
      },
    );
  }
}

class _TagEditorWidgetState extends State<TagEditorWidget> with MenuHandler {
  static const kArtworkSize = 80.0;

  final TagLib _tagLib = TagLib();

  final GlobalKey<EditorDetailsWidgetState> _detailsKey = GlobalKey();
  final GlobalKey<EditorArtworkWidgetState> _artworkKey = GlobalKey();
  final GlobalKey<EditorLyricsWidgetState> _lyricsKey = GlobalKey();

  late String _activeTitle;
  late String _activeAlbum;
  late String _activeArtist;
  late EditableTags tags;

  int _activeIndex = -1;

  bool get singleTrackMode =>
      widget.editorMode == EditorMode.edit && widget.selection.length == 1;

  Track? get currentTrack =>
      singleTrackMode ? widget.allTracks.elementAt(_activeIndex) : null;

  late MacosTabController _tabsController;

  @override
  void initState() {
    super.initState();
    initMenuSubscription();

    // do some init
    if (singleTrackMode) {
      _activeIndex = widget.allTracks.indexOf(widget.selection.first);
    }

    // other
    _tabsController = MacosTabController(
      initialIndex: 0,
      length: singleTrackMode ? 4 : 3,
    );

    // now load data
    loadData();
  }

  @override
  void dispose() {
    cancelMenuSubscription();
    super.dispose();
  }

  void loadData() {
    if (singleTrackMode) {
      loadTrackData(currentTrack!);
    } else {
      loadTracksData(widget.selection);
    }
    setState(() {});
  }

  void loadTrackData(Track track) {
    // easy
    _activeTitle = track.displayTitle;
    _activeAlbum = track.displayAlbum;
    _activeArtist = track.displayArtist;

    // now copy tags
    tags = EditableTags.fromTags(track.safeTags);
  }

  void loadTracksData(TrackList tracks) {
    // init with 1st track
    loadTrackData(tracks.first);

    // now iterate
    for (Track track in tracks) {
      // 1st check header information
      if (track.displayTitle != _activeTitle) {
        _activeTitle = '';
      }
      if (track.displayAlbum != _activeAlbum) {
        _activeAlbum = '';
      }
      if (track.displayArtist != _activeArtist) {
        _activeArtist = '';
      }

      // get editable tags
      EditableTags editableTags = track.editableTags;

      // now compare each field
      if (editableTags.title != tags.title) {
        tags.title = TagSaver.kMixedValueStr;
      }
      if (editableTags.album != tags.album) {
        tags.album = TagSaver.kMixedValueStr;
      }
      if (editableTags.artist != tags.artist) {
        tags.artist = TagSaver.kMixedValueStr;
      }
      if (editableTags.performer != tags.performer) {
        tags.performer = TagSaver.kMixedValueStr;
      }
      if (editableTags.composer != tags.composer) {
        tags.composer = TagSaver.kMixedValueStr;
      }
      if (editableTags.genre != tags.genre) {
        tags.genre = TagSaver.kMixedValueStr;
      }
      if (editableTags.year != tags.year) {
        tags.year = TagSaver.kMixedValueInt;
      }
      if (editableTags.volumeIndex != tags.volumeIndex) {
        tags.volumeIndex = TagSaver.kMixedValueInt;
      }
      if (editableTags.volumeCount != tags.volumeCount) {
        tags.volumeIndex = TagSaver.kMixedValueInt;
      }
      if (editableTags.trackIndex != tags.trackIndex) {
        tags.trackIndex = TagSaver.kMixedValueInt;
      }
      if (editableTags.trackCount != tags.trackCount) {
        tags.trackCount = TagSaver.kMixedValueInt;
      }
      if (editableTags.editedCompilation != tags.editedCompilation) {
        tags.editedCompilation = null;
      }
      if (editableTags.copyright != tags.copyright) {
        tags.copyright = TagSaver.kMixedValueStr;
      }
      if (editableTags.comment != tags.comment) {
        tags.comment = TagSaver.kMixedValueStr;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // needed
    AppLocalizations t = AppLocalizations.of(context)!;

    // one of header text will be bold
    TextStyle activeHeaderStyle = const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 24,
    );

    // return
    return DraggableDialog(
      width: 500,
      height: 585,
      preferenceKey: 'editor.alignment',
      header: Row(
        children: [
          AsyncArtwork(
            track: currentTrack,
            size: kArtworkSize,
            radius: 4.0,
            defaultPlaceholderBorderColor: CupertinoColors.systemGrey3,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_activeTitle.isNotEmpty)
                  Text(
                    _activeTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: activeHeaderStyle,
                  ),
                if (_activeAlbum.isNotEmpty)
                  Text(_activeAlbum,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _activeTitle.isEmpty ? activeHeaderStyle : null),
                if (_activeArtist.isNotEmpty)
                  Text(_activeArtist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _activeTitle.isEmpty && _activeAlbum.isEmpty
                          ? activeHeaderStyle
                          : null),
              ],
            ),
          ),
        ],
      ),
      body: TabView(
        controller: _tabsController,
        labels: [
          t.editorDetails,
          t.editorArtwork,
          t.editorLyrics,
          if (singleTrackMode) t.editorFile,
        ],
        children: [
          EditorDetailsWidget(
            key: _detailsKey,
            tags: tags,
            singleTrackMode: singleTrackMode,
            onComplete: _onSave,
          ),
          EditorArtworkWidget(
            key: _artworkKey,
            track: currentTrack,
          ),
          EditorLyricsWidget(
            key: _lyricsKey,
            track: currentTrack,
          ),
          if (singleTrackMode)
            EditorFileWidget(
              track: currentTrack!,
            ),
        ],
      ),
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (singleTrackMode) ...[
            Button(
              '〈',
              _canPrev() ? _prevTrack : null,
              noBorder: true,
            ),
            const SizedBox(width: 4),
            Button(
              '〉',
              _canNext() ? _nextTrack : null,
              noBorder: true,
            ),
            const Spacer(),
          ],
          Button(t.cancel, _onClose),
          const SizedBox(width: 8),
          Button(t.ok, _onSave, defaultButton: true),
        ],
      ),
    );
  }

  void _onClose() {
    Navigator.of(context).pop();
  }

  void _onSave() async {
    if (await _save()) {
      widget.onComplete?.call();
      _onClose();
    } else {
      _showError();
    }
  }

  void _showError() {
    AppLocalizations t = AppLocalizations.of(context)!;
    TraxDialog.inform(
      context: context,
      message: t.saveError,
    );
  }

  bool _canPrev() {
    return (singleTrackMode && _activeIndex > 0);
  }

  bool _canNext() {
    return (singleTrackMode && _activeIndex < widget.allTracks.length - 1);
  }

  void _prevTrack() {
    if (_canPrev()) {
      _save();
      _activeIndex--;
      loadData();
    }
  }

  void _nextTrack() {
    if (_canNext()) {
      _save();
      _activeIndex++;
      loadData();
    }
  }

  Future<bool> _save() {
    if (singleTrackMode) {
      return _doSave([currentTrack!]);
    } else {
      return _doSave(widget.selection);
    }
  }

  Future<bool> _doSave(TrackList tracks) async {
    // check if everything available
    if (_detailsKey.currentState == null ||
        _artworkKey.currentState == null ||
        _lyricsKey.currentState == null) {
      return false;
    }

    // get the data
    EditableTags updatedTags = _detailsKey.currentState!.tags;
    Uint8List? updatedArtwork = _artworkKey.currentState?.bytes;
    String? updatedLyrics = _lyricsKey.currentState?.lyrics;

    // saver
    TagSaver tagSaver = TagSaver(
      _tagLib,
      TraxDatabase.of(context),
      Preferences.of(context),
    );

    // iterate
    for (Track track in tracks) {
      if (track.tags == null) continue;
      Tags initialTags = Tags.copy(track.tags!);
      tagSaver.mergeTags(initialTags, updatedTags);
      bool rc = await tagSaver.update(
        Preferences.of(context),
        ArtworkProvider.of(context),
        widget.editorMode,
        track,
        initialTags,
        updatedArtwork,
        updatedLyrics,
        notify: widget.notify && widget.selection.last == track,
      );
      if (!rc) return false;
    }

    // done
    return true;
  }

  @override
  void onMenuAction(MenuAction action) async {
    if (action == MenuAction.trackPrevious) {
      _prevTrack();
    } else if (action == MenuAction.trackNext) {
      _nextTrack();
    }
  }
}
