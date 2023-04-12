import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:taglib_ffi/taglib_ffi.dart';

import '../processors/saver.dart';
import '../utils/consts.dart';
import '../utils/track_utils.dart';

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
  late TextEditingController _volumeCountController;
  late TextEditingController _trackIndexController;
  late TextEditingController _trackCountController;

  bool _genreInitialized = false;
  late List<String> _genres;
  late String _genreValue;

  final List<TextEditingController> _userCleared = [];
  final List<TextEditingController> _mixedValue = [];

  String get genreStr {
    if (_genreValue == TagSaver.kMixedValueStr) {
      return AppLocalizations.of(context)!.tagsMixed;
    } else if (_genreValue == TagSaver.kClearedValueStr) {
      return '';
    } else {
      return _genreValue;
    }
  }

  Tags get tags {
    String getText(TextEditingController controller) {
      if (!widget.singleTrackMode) {
        if (_userCleared.contains(controller)) {
          return TagSaver.kClearedValueStr;
        }
        if (_mixedValue.contains(controller)) {
          return TagSaver.kMixedValueStr;
        }
      }
      // default
      return controller.text;
    }

    int getInt(TextEditingController controller) {
      if (!widget.singleTrackMode) {
        if (_userCleared.contains(controller)) {
          return TagSaver.kClearedValueInt;
        }
        if (_mixedValue.contains(controller)) {
          return TagSaver.kMixedValueInt;
        }
      }
      // default
      return controller.intValue;
    }

    _tags.title = getText(_titleController);
    _tags.album = getText(_albumController);
    _tags.artist = getText(_artistController);
    _tags.performer = getText(_performerController);
    _tags.composer = getText(_composerController);
    _tags.genre = _genreValue;
    _tags.copyright = getText(_copyrightController);
    _tags.comment = getText(_commentController);
    _tags.year = getInt(_yearController);
    _tags.volumeIndex = getInt(_volumeIndexController);
    _tags.volumeCount = getInt(_volumeCountController);
    _tags.trackIndex = getInt(_trackIndexController);
    _tags.trackCount = getInt(_trackCountController);
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
    _userCleared.clear();
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
        text: _tags.year == TagSaver.kMixedValueInt
            ? TagSaver.kMixedValueStr
            : TrackUtils.getDisplayInteger(_tags.year));
    _volumeIndexController = TextEditingController(
        text: _tags.volumeIndex == TagSaver.kMixedValueInt
            ? TagSaver.kMixedValueStr
            : TrackUtils.getDisplayInteger(_tags.volumeIndex));
    _volumeCountController = TextEditingController(
        text: _tags.volumeCount == TagSaver.kMixedValueInt
            ? TagSaver.kMixedValueStr
            : TrackUtils.getDisplayInteger(_tags.volumeCount));
    _trackIndexController = TextEditingController(
        text: _tags.trackIndex == TagSaver.kMixedValueInt
            ? TagSaver.kMixedValueStr
            : TrackUtils.getDisplayInteger(_tags.trackIndex));
    _trackCountController = TextEditingController(
        text: _tags.trackCount == TagSaver.kMixedValueInt
            ? TagSaver.kMixedValueStr
            : TrackUtils.getDisplayInteger(_tags.trackCount));

    // update genres
    _genreInitialized = false;
  }

  @override
  Widget build(BuildContext context) {
    // needed
    AppLocalizations t = AppLocalizations.of(context)!;
    String mixedTextPlaceholder = widget.singleTrackMode ? '' : t.tagsMixed;
    String mixedNumPlaceholder = widget.singleTrackMode ? '' : '-';
    String indexSeparator = t.indexOfCount;

    // update genres
    if (!_genreInitialized) {
      _genres = List.from(Consts.genres);
      if (_genres.contains(genreStr) == false) {
        _genres.add(genreStr);
      }
      _genreInitialized = true;
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
          t.tagPerformer,
          _performerController,
          placeholder: mixedTextPlaceholder,
        ),
        _textFieldRow(
          t.tagComposer,
          _composerController,
          placeholder: mixedTextPlaceholder,
        ),
        _dropDowndRow(
          t.tagGenre,
          value: genreStr,
          values: _genres,
          onChanged: (value) {
            if (!widget.singleTrackMode) {
              if (value.isEmpty) {
                value = TagSaver.kClearedValueStr;
              } else if (value == t.tagsMixed) {
                value = TagSaver.kMixedValueStr;
              }
            }
            setState(() => _genreValue = value);
          },
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
          _volumeCountController,
          placeholder: mixedNumPlaceholder,
          keyboardType: TextInputType.number,
        ),
        _textFieldsRow(
          t.tagTrackIndex,
          indexSeparator,
          40,
          _trackIndexController,
          _trackCountController,
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
    return _row(label, 6, [
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
    ]);
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

  Widget _textField(
    TextInputType? keyboardType,
    int? maxLength,
    TextEditingController controller,
    String? placeholder,
    int? minLines,
  ) {
    // check controller value
    bool isMixed = _mixedValue.contains(controller);
    if (!isMixed && controller.text == TagSaver.kMixedValueStr) {
      _mixedValue.add(controller);
      controller.text = '';
      isMixed = true;
    }
    FocusNode focusNode = FocusNode();
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        controller.selection =
            TextSelection(baseOffset: 0, extentOffset: controller.text.length);
      } else {
        controller.selection =
            const TextSelection(baseOffset: 0, extentOffset: 0);
      }
    });
    focusNode.onKeyEvent = (node, event) {
      if (event.logicalKey == LogicalKeyboardKey.backspace &&
          controller.text.isEmpty &&
          _mixedValue.contains(controller)) {
        _userCleared.add(controller);
        _mixedValue.remove(controller);
      }
      return KeyEventResult.ignored;
    };
    return MacosTextField(
      focusNode: focusNode,
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
      inputFormatters: [
        if (keyboardType == TextInputType.number)
          FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
      ],
      onChanged: (_) {
        _mixedValue.remove(controller);
      },
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
