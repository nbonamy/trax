import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:taglib_ffi/taglib_ffi.dart';

import '../utils/consts.dart';
import '../utils/track_utils.dart';
import 'editor.dart';

extension Int on TextEditingController {
  int get intValue => num.tryParse(text)?.toInt() ?? 0;
}

class EditorDetailsWidget extends StatefulWidget {
  final Tags tags;
  final bool singleTrackMode;
  final VoidCallback onComplete;
  const EditorDetailsWidget({
    super.key,
    required this.tags,
    required this.singleTrackMode,
    required this.onComplete,
  });

  @override
  State<EditorDetailsWidget> createState() => EditorDetailsWidgetState();
}

class EditorDetailsWidgetState extends State<EditorDetailsWidget> {
  late Tags _tags;
  late TextEditingController _titleController;
  late TextEditingController _albumController;
  late TextEditingController _artistController;
  late TextEditingController _performerController;
  late TextEditingController _composerController;
  late TextEditingController _copyrightController;
  late TextEditingController _commentController;
  late TextEditingController _yearController;
  late TextEditingController _volumeIndexController;
  late TextEditingController _trackIndexController;
  late String _genreValue;

  Tags get tags {
    _tags.title = _titleController.text;
    _tags.album = _albumController.text;
    _tags.artist = _artistController.text;
    _tags.performer = _performerController.text;
    _tags.composer = _composerController.text;
    _tags.genre = _genreValue;
    _tags.copyright = _copyrightController.text;
    _tags.comment = _commentController.text;
    _tags.year = _yearController.intValue;
    _tags.volumeIndex = _volumeIndexController.intValue;
    _tags.trackIndex = _trackIndexController.intValue;
    return _tags;
  }

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
    _tags = Tags.copy(widget.tags);
    _titleController = TextEditingController(text: _tags.title);
    _albumController = TextEditingController(text: _tags.album);
    _artistController = TextEditingController(text: _tags.artist);
    _performerController = TextEditingController(text: _tags.performer);
    _composerController = TextEditingController(text: _tags.composer);
    _genreValue = _tags.genre;
    _copyrightController = TextEditingController(text: _tags.copyright);
    _commentController = TextEditingController(text: _tags.comment);
    _yearController = TextEditingController(
        text: _tags.year == TagEditorWidget.kMixedValueInt
            ? TagEditorWidget.kMixedValueStr
            : TrackUtils.getDisplayInteger(_tags.year));
    _volumeIndexController = TextEditingController(
        text: _tags.volumeIndex == TagEditorWidget.kMixedValueInt
            ? TagEditorWidget.kMixedValueStr
            : TrackUtils.getDisplayInteger(_tags.volumeIndex));
    _trackIndexController = TextEditingController(
        text: _tags.trackIndex == TagEditorWidget.kMixedValueInt
            ? TagEditorWidget.kMixedValueStr
            : TrackUtils.getDisplayInteger(_tags.trackIndex));
  }

  @override
  Widget build(BuildContext context) {
    // needed
    AppLocalizations t = AppLocalizations.of(context)!;
    String mixedTextPlaceholder = widget.singleTrackMode ? '' : t.tagsMixed;
    String mixedNumPlaceholder = widget.singleTrackMode ? '' : '-';
    String indexSeparator = t.indexOfCount;

    // genre
    List<String> genres = List.from(Consts.genres);
    if (genres.contains(_genreValue) == false) {
      genres.add(_genreValue);
    }

    // return
    return Column(
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
          value: _genreValue,
          values: genres,
          onChanged: (value) => setState(() => _genreValue = value),
        ),
        _textFieldRow(
          t.tagYear,
          _yearController,
          placeholder: mixedNumPlaceholder,
          keyboardType: TextInputType.number,
          maxLength: 4,
          width: 60,
        ),
        _textFieldsRow(
          t.tagVolumeIndex,
          indexSeparator,
          40,
          _volumeIndexController,
          _volumeIndexController,
          placeholder: mixedNumPlaceholder,
          keyboardType: TextInputType.number,
        ),
        _textFieldsRow(
          t.tagTrackIndex,
          indexSeparator,
          40,
          _trackIndexController,
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
    );
  }

  Widget _textFieldRow(
    String label,
    TextEditingController controller, {
    String? placeholder,
    TextInputType? keyboardType,
    int? maxLength,
    int? minLines,
    double? width,
  }) {
    Widget textField = _textField(
      keyboardType,
      maxLength,
      controller,
      placeholder,
      minLines,
    );
    return _row(label, 6, [
      width == null
          ? Expanded(child: textField)
          : SizedBox(width: width, child: textField)
    ]);
  }

  Widget _textFieldsRow(
    String label,
    String separator,
    double width,
    TextEditingController controller1,
    TextEditingController controller2, {
    String? placeholder,
    TextInputType? keyboardType,
    int? maxLength,
    int? minLines,
  }) {
    return _row(
      label,
      6,
      [
        SizedBox(
          width: width,
          child: _textField(
            keyboardType,
            maxLength,
            controller1,
            placeholder,
            minLines,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 6, left: 4, right: 4),
          child: Text(
            separator,
            style: const TextStyle(fontSize: 13),
          ),
        ),
        SizedBox(
          width: width,
          child: _textField(
            keyboardType,
            maxLength,
            controller2,
            placeholder,
            minLines,
          ),
        ),
      ],
    );
  }

  Widget _dropDowndRow(
    String label, {
    required String value,
    required List<String> values,
    required ValueChanged? onChanged,
    bool expanded = false,
  }) {
    Widget dropdown = _dropdown(value, values, onChanged);
    return _row(label, 3, [expanded ? Expanded(child: dropdown) : dropdown]);
  }

  Widget _row(String label, double paddingTop, List<Widget> widgets) {
    return Flex(
      direction: Axis.horizontal,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label, 6),
        ...widgets,
      ],
    );
  }

  Widget _label(String label, double paddingTop) {
    return SizedBox(
      width: 100,
      child: Padding(
        padding: EdgeInsets.only(top: paddingTop, right: 4),
        child: Text(
          label.toLowerCase(),
          textAlign: TextAlign.right,
          style: const TextStyle(
            fontSize: 13,
            color: Color.fromRGBO(125, 125, 125, 1.0),
          ),
        ),
      ),
    );
  }

  MacosTextField _textField(
    TextInputType? keyboardType,
    int? maxLength,
    TextEditingController controller,
    String? placeholder,
    int? minLines,
  ) {
    // check controller value
    bool isMixed = false;
    if (controller.text == TagEditorWidget.kMixedValueStr) {
      isMixed = true;
      controller.text = '';
    }
    return MacosTextField(
      padding: const EdgeInsets.symmetric(
        vertical: 2.0,
        horizontal: 4.0,
      ),
      textAlignVertical: TextAlignVertical.center,
      keyboardType: keyboardType,
      maxLength: maxLength,
      controller: controller,
      placeholder: isMixed ? placeholder : null,
      minLines: minLines ?? 1,
      maxLines: minLines ?? 1,
      onEditingComplete: () {
        widget.onComplete();
      },
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
    );
  }

  Widget _dropdown(
      String value, List<String> values, ValueChanged<dynamic>? onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: MacosPopupButton(
        value: value,
        items: values
            .map((i) => MacosPopupMenuItem(value: i, child: Text(i)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
