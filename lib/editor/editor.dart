import 'dart:collection';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:taglib_ffi/taglib_ffi.dart';
import 'package:trax/data/database.dart';
import 'package:trax/processors/saver.dart';

import '../model/menu_actions.dart';
import '../model/preferences.dart';
import '../model/track.dart';
import '../utils/track_utils.dart';
import 'artwork.dart';
import 'details.dart';
import 'file.dart';
import 'lyrics.dart';

class TagEditorWidget extends StatefulWidget {
  static const String kMixedValueStr = '__mixed__';
  static const int kMixedValueInt = -1;

  final MenuActionStream menuActionStream;
  final UnmodifiableListView<Track> selection;
  final List<Track> allTracks;
  const TagEditorWidget({
    super.key,
    required this.menuActionStream,
    required this.selection,
    required this.allTracks,
  });

  @override
  State<TagEditorWidget> createState() => _TagEditorWidgetState();
}

class _TagEditorWidgetState extends State<TagEditorWidget> with MenuHandler {
  static const kDialogBorderRadius = 8.0;
  static const kArtworkSize = 80.0;

  final TagLib _tagLib = TagLib();

  final GlobalKey<EditorDetailsWidgetState> _detailsKey = GlobalKey();
  final GlobalKey<EditorArtworkWidgetState> _artworkKey = GlobalKey();
  final GlobalKey<EditorLyricsWidgetState> _lyricsKey = GlobalKey();

  late String _activeTitle;
  late String _activeAlbum;
  late String _activeArtist;
  Uint8List? _artworkBytes;

  int _activeIndex = -1;
  late Tags tags;

  bool get singleTrackMode => widget.selection.length == 1;

  Track? get currentTrack =>
      singleTrackMode ? widget.allTracks.elementAt(_activeIndex) : null;

  final _tabsController = MacosTabController(
    initialIndex: 0,
    length: 4,
  );

  @override
  void initState() {
    super.initState();
    initMenuSubscription(widget.menuActionStream);

    // do some init
    if (singleTrackMode) {
      _activeIndex = widget.allTracks.indexOf(widget.selection.first);
    }

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
    _artworkBytes = _tagLib.getArtworkBytes(track.filename);

    // now copy tags
    tags = Tags.copy(track.safeTags);
  }

  void loadTracksData(List<Track> tracks) {
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

      // now compare each field
      if (track.safeTags.title != tags.title) {
        tags.title = TagEditorWidget.kMixedValueStr;
      }
      if (track.safeTags.album != tags.album) {
        tags.album = TagEditorWidget.kMixedValueStr;
      }
      if (track.safeTags.artist != tags.artist) {
        tags.artist = TagEditorWidget.kMixedValueStr;
      }
      if (track.safeTags.performer != tags.performer) {
        tags.performer = TagEditorWidget.kMixedValueStr;
      }
      if (track.safeTags.composer != tags.composer) {
        tags.composer = TagEditorWidget.kMixedValueStr;
      }
      if (track.safeTags.genre != tags.genre) {
        tags.genre = TagEditorWidget.kMixedValueStr;
      }
      if (track.safeTags.year != tags.year) {
        tags.year = TagEditorWidget.kMixedValueInt;
      }
      if (track.safeTags.volumeIndex != tags.volumeIndex) {
        tags.volumeIndex = TagEditorWidget.kMixedValueInt;
      }
      if (track.safeTags.trackIndex != tags.trackIndex) {
        tags.trackIndex = TagEditorWidget.kMixedValueInt;
      }
      if (track.safeTags.copyright != tags.copyright) {
        tags.copyright = TagEditorWidget.kMixedValueStr;
      }
      if (track.safeTags.comment != tags.comment) {
        tags.comment = TagEditorWidget.kMixedValueStr;
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
    return Container(
      width: 500,
      height: 565,
      decoration: BoxDecoration(
          border: Border.all(
            color: const Color.fromRGBO(238, 232, 230, 1.0),
            width: 0.25,
          ),
          borderRadius: const BorderRadius.all(
            Radius.circular(kDialogBorderRadius),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(170, 170, 170, 1),
              spreadRadius: 8,
              blurRadius: 24,
            )
          ]),
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color.fromRGBO(238, 232, 230, 1.0),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(kDialogBorderRadius),
                topRight: Radius.circular(kDialogBorderRadius),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(2.0),
                  child: Image.memory(
                    _artworkBytes!,
                    width: kArtworkSize,
                    height: kArtworkSize,
                    fit: BoxFit.contain,
                  ),
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
                            style: _activeTitle.isEmpty
                                ? activeHeaderStyle
                                : null),
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
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(kDialogBorderRadius),
                  bottomRight: Radius.circular(kDialogBorderRadius),
                ),
              ),
              child: Column(
                children: [
                  MacosTabView(
                    padding: const EdgeInsets.only(top: 36),
                    controller: _tabsController,
                    tabs: const [
                      MacosTab(label: 'Details'),
                      MacosTab(label: 'Artwork'),
                      MacosTab(label: 'Lyrics'),
                      MacosTab(label: 'File'),
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
                        bytes: null,
                        singleTrackMode: singleTrackMode,
                      ),
                      EditorLyricsWidget(
                        key: _lyricsKey,
                        singleTrackMode: singleTrackMode,
                      ),
                      EditorFileWidget(
                        singleTrackMode: singleTrackMode,
                      ),
                    ]
                        .map(
                          (w) => Container(
                            color: CupertinoColors.white,
                            child: w,
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    if (singleTrackMode) ...[
                      _actionButton(
                        '〈',
                        _canPrev() ? _prevTrack : null,
                        noBorder: true,
                      ),
                      const SizedBox(width: 4),
                      _actionButton(
                        '〉',
                        _canNext() ? _nextTrack : null,
                        noBorder: true,
                      ),
                      const Spacer(),
                    ],
                    _actionButton(t.cancel, _onClose),
                    const SizedBox(width: 8),
                    _actionButton(t.ok, _onSave, defaultButton: true),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onSave() async {
    if (await _save()) {
      _onClose();
    }
  }

  void _onClose() {
    Navigator.of(context).pop();
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
      return _saveSingle();
    } else {
      return _saveMultiple();
    }
  }

  Future<bool> _saveSingle() async {
    if (currentTrack == null) return false;
    Tags? updatedTags = _detailsKey.currentState?.tags;
    TagSaver tagSaver = TagSaver(
      _tagLib,
      TraxDatabase.of(context),
      Preferences.of(context).musicFolder,
    );
    return await tagSaver.update(currentTrack!, updatedTags, null);
  }

  Future<bool> _saveMultiple() async {
    return false;
  }

  @override
  void onMenuAction(MenuAction action) {
    if (action == MenuAction.trackPrevious) {
      _prevTrack();
    } else if (action == MenuAction.trackNext) {
      _nextTrack();
    }
  }

  Widget _actionButton(
    String label,
    VoidCallback? onPressed, {
    bool defaultButton = false,
    bool noBorder = false,
  }) {
    PushButton button = PushButton(
      buttonSize: ButtonSize.large,
      padding: EdgeInsets.symmetric(
        vertical: 2,
        horizontal: noBorder ? 0 : 24,
      ),
      color: defaultButton ? null : CupertinoColors.white,
      disabledColor: CupertinoColors.white,
      onPressed: onPressed,
      child: Text(label),
    );
    if (defaultButton || noBorder) {
      return button;
    } else {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: CupertinoColors.lightBackgroundGray),
        ),
        child: button,
      );
    }
  }
}
