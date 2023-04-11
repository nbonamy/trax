import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:taglib_ffi/taglib_ffi.dart';

import '../utils/consts.dart';
import '../utils/track_utils.dart';
import 'editor.dart';

class EditorDetailsWidget extends StatefulWidget {
  final Tags tags;
  final bool singleTrackMode;
  const EditorDetailsWidget({
    super.key,
    required this.tags,
    required this.singleTrackMode,
  });

  @override
  State<EditorDetailsWidget> createState() => _EditorDetailsWidgetState();
}

class _EditorDetailsWidgetState extends State<EditorDetailsWidget> {
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

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void didUpdateWidget(EditorDetailsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    loadData();
  }

  void loadData() {
    _titleController = TextEditingController(text: widget.tags.title);
    _albumController = TextEditingController(text: widget.tags.album);
    _artistController = TextEditingController(text: widget.tags.artist);
    _performerController = TextEditingController(text: widget.tags.performer);
    _composerController = TextEditingController(text: widget.tags.composer);
    _yearController = TextEditingController(
        text: widget.tags.year == TagEditorWidget.kMixedValueInt
            ? TagEditorWidget.kMixedValueStr
            : TrackUtils.getDisplayInteger(widget.tags.year));
    _volumeIndexController = TextEditingController(
        text: widget.tags.volumeIndex == TagEditorWidget.kMixedValueInt
            ? TagEditorWidget.kMixedValueStr
            : TrackUtils.getDisplayInteger(widget.tags.volumeIndex));
    _trackIndexController = TextEditingController(
        text: widget.tags.trackIndex == TagEditorWidget.kMixedValueInt
            ? TagEditorWidget.kMixedValueStr
            : TrackUtils.getDisplayInteger(widget.tags.trackIndex));
    _copyrightController = TextEditingController(text: widget.tags.copyright);
    _commentController = TextEditingController(text: widget.tags.comment);
  }

  @override
  Widget build(BuildContext context) {
    // needed
    AppLocalizations t = AppLocalizations.of(context)!;
    String mixedTextPlaceholder = widget.singleTrackMode ? '' : t.tagsMixed;
    String mixedNumPlaceholder = widget.singleTrackMode ? '' : '-';

    // genre
    List<String> genres = List.from(Consts.genres);
    if (genres.contains(widget.tags.genre) == false) {
      genres.add(widget.tags.genre);
    }

    // return
    return Column(children: [
      Table(
        columnWidths: const {
          0: FixedColumnWidth(100.0),
          1: FlexColumnWidth(),
        },
        children: [
          _textFieldRow(
            t.tagTitle,
            _titleController,
            placeholder: mixedTextPlaceholder,
          ),
          _textFieldRow(
            t.tagPerformer,
            _performerController,
            placeholder: mixedTextPlaceholder,
          ),
          _textFieldRow(
            t.tagAlbum,
            _albumController,
            placeholder: mixedTextPlaceholder,
          ),
          _textFieldRow(
            t.tagArtist,
            _artistController,
            placeholder: mixedTextPlaceholder,
          ),
          _textFieldRow(
            t.tagComposer,
            _composerController,
            placeholder: mixedTextPlaceholder,
          ),
          _dropDowndRow(
            t.tagGenre,
            value: widget.tags.genre,
            values: genres,
            onChanged: (_) {},
          ),
          _textFieldRow(
            t.tagYear,
            _yearController,
            placeholder: mixedNumPlaceholder,
            keyboardType: TextInputType.number,
            maxLength: 4,
          ),
          _textFieldRow(
            t.tagVolumeIndex,
            _volumeIndexController,
            placeholder: mixedNumPlaceholder,
            keyboardType: TextInputType.number,
          ),
          _textFieldRow(
            t.tagTrackIndex,
            _trackIndexController,
            placeholder: mixedNumPlaceholder,
            keyboardType: TextInputType.number,
          ),
          _textFieldRow(
            t.tagCopyright,
            _copyrightController,
            placeholder: mixedTextPlaceholder,
          ),
          _textFieldRow(
            t.tagComment,
            _commentController,
            placeholder: mixedTextPlaceholder,
            minLines: 3,
          ),
        ],
      ),
    ]);
  }

  TableRow _textFieldRow(
    String label,
    TextEditingController controller, {
    String? placeholder,
    TextInputType? keyboardType,
    int? maxLength,
    int? minLines,
  }) {
    // check controller value
    bool isMixed = false;
    if (controller.text == TagEditorWidget.kMixedValueStr) {
      isMixed = true;
      controller.text = '';
    }
    return TableRow(
      children: [
        _formLabel(label, 6),
        MacosTextField(
          padding: const EdgeInsets.symmetric(
            vertical: 2.0,
            horizontal: 4.0,
          ),
          keyboardType: keyboardType,
          maxLength: maxLength,
          controller: controller,
          placeholder: isMixed ? placeholder : null,
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
        _formLabel(label, 3),
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

  Widget _formLabel(String label, double paddingTop) {
    return Padding(
      padding: EdgeInsets.only(top: paddingTop, right: 4),
      child: Text(
        label.toLowerCase(),
        textAlign: TextAlign.right,
        style: const TextStyle(
          fontSize: 13,
          color: Color.fromRGBO(125, 125, 125, 1.0),
        ),
      ),
    );
  }
}
