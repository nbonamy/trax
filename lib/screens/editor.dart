import 'dart:collection';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:taglib_ffi/taglib_ffi.dart';
import 'package:trax/utils/consts.dart';
import 'package:trax/utils/track_utils.dart';

import '../model/track.dart';

class TagEditorWidget extends StatefulWidget {
  final UnmodifiableListView<Track> selection;
  final List<Track> allTracks;
  const TagEditorWidget({
    super.key,
    required this.selection,
    required this.allTracks,
  });

  @override
  State<TagEditorWidget> createState() => _TagEditorWidgetState();
}

class _TagEditorWidgetState extends State<TagEditorWidget> {
  static const kDialogBorderRadius = 8.0;
  static const kArtworkSize = 80.0;

  final TagLib _tagLib = TagLib();

  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _albumController;
  late TextEditingController _artistController;
  late TextEditingController _performerController;
  late TextEditingController _composerController;
  late TextEditingController _yearController;
  late TextEditingController _volumeIndexController;
  late TextEditingController _trackIndexController;
  late TextEditingController _copyrightController;
  late TextEditingController _commentController;

  late String _activeTitle;
  late String _activeAlbum;
  late String _activeArtist;
  late String _activeGenre;
  Uint8List? _artworkBytes;

  int _activeIndex = -1;

  bool get singleTrackMode => widget.selection.length == 1;

  @override
  void initState() {
    super.initState();

    // do some init
    if (singleTrackMode) {
      _activeIndex = widget.allTracks.indexOf(widget.selection.first);
    }

    // now load data
    loadData();
  }

  void loadData() {
    if (singleTrackMode) {
      loadTrackData(widget.allTracks.elementAt(_activeIndex));
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
    _activeGenre = track.safeTags.genre;

    // need tags
    _artworkBytes = _tagLib.getArtworkBytes(track.filename);
    _titleController = TextEditingController(text: track.safeTags.title);
    _albumController = TextEditingController(text: track.safeTags.album);
    _artistController = TextEditingController(text: track.safeTags.artist);
    _performerController =
        TextEditingController(text: track.safeTags.performer);
    _composerController = TextEditingController(text: track.safeTags.composer);
    _yearController = TextEditingController(text: track.displayYear);
    _volumeIndexController =
        TextEditingController(text: track.displayVolumeIndex);
    _trackIndexController =
        TextEditingController(text: track.displayTrackIndex);
    _copyrightController =
        TextEditingController(text: track.safeTags.copyright);
    _commentController = TextEditingController(text: track.safeTags.comment);
  }

  void loadTracksData(List<Track> tracks) {
    // init with 1st track
    Track ref = tracks.first;
    loadTrackData(ref);

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
      if (track.safeTags.title != ref.safeTags.title) {
        _titleController = TextEditingController(text: '');
      }
      if (track.safeTags.album != ref.safeTags.album) {
        _albumController = TextEditingController(text: '');
      }
      if (track.safeTags.artist != ref.safeTags.artist) {
        _artistController = TextEditingController(text: '');
      }
      if (track.safeTags.performer != ref.safeTags.performer) {
        _performerController = TextEditingController(text: '');
      }
      if (track.safeTags.composer != ref.safeTags.composer) {
        _composerController = TextEditingController(text: '');
      }
      if (track.safeTags.genre != ref.safeTags.genre) {
        _activeGenre = '';
      }
      if (track.displayYear != ref.displayYear) {
        _yearController = TextEditingController(text: '');
      }
      if (track.displayVolumeIndex != ref.displayVolumeIndex) {
        _volumeIndexController = TextEditingController(text: '');
      }
      if (track.displayTrackIndex != ref.displayTrackIndex) {
        _trackIndexController = TextEditingController(text: '');
      }
      if (track.safeTags.copyright != ref.safeTags.copyright) {
        _copyrightController = TextEditingController(text: '');
      }
      if (track.safeTags.comment != ref.safeTags.comment) {
        _commentController = TextEditingController(text: '');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // needed
    AppLocalizations t = AppLocalizations.of(context)!;
    String mixedTextPlaceholder = singleTrackMode ? '' : 'Mixed';
    String mixedNumPlaceholder = singleTrackMode ? '' : '-';

    // genre
    List<String> genres = List.from(Consts.genres);
    if (genres.contains(_activeGenre) == false) {
      genres.add(_activeGenre);
    }

    return Container(
      width: 500,
      height: 520,
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
      child: Form(
        key: _formKey,
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
                        Text(
                          _activeTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                        Text(
                          _activeArtist,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _activeAlbum,
                          overflow: TextOverflow.ellipsis,
                        ),
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
                    Table(
                      columnWidths: const {
                        0: FixedColumnWidth(100.0),
                        1: FlexColumnWidth(),
                      },
                      children: [
                        _textFieldRow(
                          'title',
                          _titleController,
                          placeholder: mixedTextPlaceholder,
                        ),
                        _textFieldRow(
                          'artist',
                          _performerController,
                          placeholder: mixedTextPlaceholder,
                        ),
                        _textFieldRow(
                          'album',
                          _albumController,
                          placeholder: mixedTextPlaceholder,
                        ),
                        _textFieldRow(
                          'album artist',
                          _artistController,
                          placeholder: mixedTextPlaceholder,
                        ),
                        _textFieldRow(
                          'composer',
                          _composerController,
                          placeholder: mixedTextPlaceholder,
                        ),
                        _dropDowndRow(
                          'genre',
                          value: _activeGenre,
                          values: genres,
                          onChanged: (_) {},
                        ),
                        _textFieldRow(
                          'year',
                          _yearController,
                          placeholder: mixedNumPlaceholder,
                          keyboardType: TextInputType.number,
                          maxLength: 4,
                        ),
                        _textFieldRow(
                          'disc number',
                          _volumeIndexController,
                          placeholder: mixedNumPlaceholder,
                          keyboardType: TextInputType.number,
                        ),
                        _textFieldRow(
                          'track',
                          _trackIndexController,
                          placeholder: mixedNumPlaceholder,
                          keyboardType: TextInputType.number,
                        ),
                        _textFieldRow(
                          'copyright',
                          _copyrightController,
                          placeholder: mixedTextPlaceholder,
                        ),
                        _textFieldRow(
                          'comment',
                          _commentController,
                          placeholder: mixedTextPlaceholder,
                          minLines: 3,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      if (singleTrackMode) ...[
                        _actionButton(
                            '〈', _activeIndex == 0 ? null : _prevTrack,
                            noBorder: true),
                        const SizedBox(width: 4),
                        _actionButton(
                          '〉',
                          _activeIndex == widget.allTracks.length - 1
                              ? null
                              : _nextTrack,
                          noBorder: true,
                        ),
                        const Spacer(),
                      ],
                      _actionButton(
                          t.cancel, () => Navigator.of(context).pop()),
                      const SizedBox(width: 8),
                      _actionButton(
                        t.ok,
                        () => Navigator.of(context).pop(),
                        defaultButton: true,
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _nextTrack() {
    _activeIndex++;
    loadData();
  }

  void _prevTrack() {
    _activeIndex--;
    loadData();
  }

  TableRow _textFieldRow(
    String label,
    TextEditingController controller, {
    String? placeholder,
    TextInputType? keyboardType,
    int? maxLength,
    int? minLines,
  }) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6, right: 4),
          child: Text(
            label,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 13,
              color: Color.fromRGBO(125, 125, 125, 1.0),
            ),
          ),
        ),
        MacosTextField(
          padding: const EdgeInsets.symmetric(
            vertical: 2.0,
            horizontal: 4.0,
          ),
          keyboardType: keyboardType,
          maxLength: maxLength,
          controller: controller,
          placeholder: placeholder,
          minLines: minLines,
          maxLines: minLines,
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color.fromRGBO(192, 192, 192, 1.0),
              width: 0.8,
            ),
          ),
          focusedDecoration: BoxDecoration(
            border: Border.all(
              color: const Color.fromRGBO(197, 216, 249, 1.0),
              width: 0.8,
            ),
          ),
        ),
      ],
    );
  }

  TableRow _dropDowndRow(
    String label, {
    required String value,
    required List<String> values,
    required ValueChanged? onChanged,
  }) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 3, right: 4),
          child: Text(
            label,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 13,
              color: Color.fromRGBO(125, 125, 125, 1.0),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              MacosPopupButton(
                value: value,
                items: values
                    .map((i) => MacosPopupMenuItem(value: i, child: Text(i)))
                    .toList(),
                onChanged: onChanged,
              ),
            ],
          ),
        ),
      ],
    );
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
