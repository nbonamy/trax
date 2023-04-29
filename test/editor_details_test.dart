import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart' hide Tags;
import 'package:macos_ui/macos_ui.dart';
import 'package:trax/editor/details.dart';
import 'package:trax/model/editable_tags.dart';
import 'package:trax/processors/saver.dart';

import 'test_utils.dart';

String textFieldExpectedValue(String value) {
  if (value == TagSaver.kMixedValueStr) return '';
  if (value == TagSaver.kClearedValueStr) return '';
  return value;
}

String textFieldExpectedPlaceholder(bool singleTrackMode, String value) {
  if (!singleTrackMode && value == TagSaver.kMixedValueStr) return 'Mixed';
  return '';
}

String numFieldExpectedValue(int value) {
  if (value == TagSaver.kMixedValueInt) return '';
  return value == 0 ? '' : value.toString();
}

String numFieldExpectedPlaceholder(bool singleTrackMode, int value) {
  if (!singleTrackMode && value == TagSaver.kMixedValueInt) return '-';
  return '';
}

void checkAllFieldValues(
  WidgetTester tester,
  CommonFinders find,
  EditableTags tags,
  bool singleTrackMode,
) {
  // check each control values
  expectTextFieldValue(
    tester,
    find,
    'title',
    textFieldExpectedValue(tags.title),
  );
  expectTextFieldValue(
    tester,
    find,
    'album',
    textFieldExpectedValue(tags.album),
  );
  expectTextFieldValue(
    tester,
    find,
    'artist',
    textFieldExpectedValue(tags.artist),
  );
  expectTextFieldValue(
    tester,
    find,
    'performer',
    textFieldExpectedValue(tags.performer),
  );
  expectTextFieldValue(
    tester,
    find,
    'composer',
    textFieldExpectedValue(tags.composer),
  );
  expectTextFieldValue(
    tester,
    find,
    'genre',
    textFieldExpectedValue(tags.genre),
  );
  expectTextFieldValue(
    tester,
    find,
    'year',
    numFieldExpectedValue(tags.year),
  );
  expectTextFieldValue(
    tester,
    find,
    'volume_index',
    numFieldExpectedValue(tags.volumeIndex),
  );
  expectTextFieldValue(
    tester,
    find,
    'volume_count',
    numFieldExpectedValue(tags.volumeCount),
  );
  expectTextFieldValue(
    tester,
    find,
    'track_index',
    numFieldExpectedValue(tags.trackIndex),
  );
  expectTextFieldValue(
    tester,
    find,
    'track_count',
    numFieldExpectedValue(tags.trackCount),
  );
  expectCheckboxField(
    tester,
    find,
    'compilation',
    tags.editedCompilation,
  );
  expectTextFieldValue(
    tester,
    find,
    'copyright',
    textFieldExpectedValue(tags.copyright),
  );
  expectTextFieldValue(
    tester,
    find,
    'comment',
    textFieldExpectedValue(tags.comment),
  );
}

void checkAllFieldPlaceholders(
  WidgetTester tester,
  CommonFinders find,
  EditableTags tags,
  bool singleTrackMode,
) {
  // now check placeholders
  expectTextFieldPlaceholder(
    tester,
    find,
    'title',
    textFieldExpectedPlaceholder(singleTrackMode, tags.title),
  );
  expectTextFieldPlaceholder(
    tester,
    find,
    'album',
    textFieldExpectedPlaceholder(singleTrackMode, tags.album),
  );
  expectTextFieldPlaceholder(
    tester,
    find,
    'artist',
    textFieldExpectedPlaceholder(singleTrackMode, tags.artist),
  );
  expectTextFieldPlaceholder(
    tester,
    find,
    'performer',
    textFieldExpectedPlaceholder(singleTrackMode, tags.performer),
  );
  expectTextFieldPlaceholder(
    tester,
    find,
    'composer',
    textFieldExpectedPlaceholder(singleTrackMode, tags.composer),
  );
  expectTextFieldPlaceholder(
    tester,
    find,
    'genre',
    textFieldExpectedPlaceholder(singleTrackMode, tags.genre),
  );
  expectTextFieldPlaceholder(
    tester,
    find,
    'year',
    numFieldExpectedPlaceholder(singleTrackMode, tags.year),
  );
  expectTextFieldPlaceholder(
    tester,
    find,
    'volume_index',
    numFieldExpectedPlaceholder(singleTrackMode, tags.volumeIndex),
  );
  expectTextFieldPlaceholder(
    tester,
    find,
    'volume_count',
    numFieldExpectedPlaceholder(singleTrackMode, tags.volumeCount),
  );
  expectTextFieldPlaceholder(
    tester,
    find,
    'track_index',
    numFieldExpectedPlaceholder(singleTrackMode, tags.trackIndex),
  );
  expectTextFieldPlaceholder(
    tester,
    find,
    'track_count',
    numFieldExpectedPlaceholder(singleTrackMode, tags.trackCount),
  );
  expectTextFieldPlaceholder(
    tester,
    find,
    'copyright',
    textFieldExpectedPlaceholder(singleTrackMode, tags.copyright),
  );
  expectTextFieldPlaceholder(
    tester,
    find,
    'comment',
    textFieldExpectedPlaceholder(singleTrackMode, tags.comment),
  );
}

Future<GlobalKey<EditorDetailsWidgetState>> runTest(
  WidgetTester tester,
  EditableTags tags,
  bool singleTrackMode,
) async {
  // create widget
  GlobalKey<EditorDetailsWidgetState> key = GlobalKey();
  EditorDetailsWidget widget = EditorDetailsWidget(
    key: key,
    tags: tags,
    singleTrackMode: singleTrackMode,
    onComplete: () {},
  );
  await tester.pumpWidget(await bootstrapWidget(tester, widget));

  // check screen structure
  expect(tester.allWidgets.whereType<MacosTextField>().length, 13);
  expect(tester.allWidgets.whereType<MacosCheckbox>().length, 1);

  // now check if everything loaded correctly
  checkAllFieldValues(tester, find, tags, singleTrackMode);
  checkAllFieldPlaceholders(tester, find, tags, singleTrackMode);

  // check edited values when we do nothing
  EditableTags editedTags = key.currentState!.tags;
  expect(editedTags, tags);

  // done
  return key;
}

void main() async {
  testWidgets('Single Basic', (WidgetTester tester) async {
    await runTest(
      tester,
      testTags(),
      true,
    );
  });
  testWidgets('Single Compilation', (WidgetTester tester) async {
    await runTest(
      tester,
      testTags().copyWith(compilation: true),
      true,
    );
  });
  testWidgets('Single Empty Numeric Fields', (WidgetTester tester) async {
    await runTest(
      tester,
      testTags().copyWith(
        year: 0,
        volumeIndex: 0,
        volumeCount: 0,
        trackCount: 0,
      ),
      true,
    );
  });
  testWidgets('Multi Basic', (WidgetTester tester) async {
    await runTest(
      tester,
      testTags().copyWith(
        title: TagSaver.kMixedValueStr,
        album: TagSaver.kMixedValueStr,
        artist: TagSaver.kMixedValueStr,
        performer: TagSaver.kMixedValueStr,
        composer: TagSaver.kMixedValueStr,
        genre: TagSaver.kMixedValueStr,
        year: TagSaver.kMixedValueInt,
        volumeIndex: TagSaver.kMixedValueInt,
        volumeCount: TagSaver.kMixedValueInt,
        trackIndex: TagSaver.kMixedValueInt,
        trackCount: TagSaver.kMixedValueInt,
        compilation: null,
        copyright: TagSaver.kMixedValueStr,
        comment: TagSaver.kMixedValueStr,
      ),
      false,
    );
  });
  testWidgets('Multi Clear Text', (WidgetTester tester) async {
    // we need the tags to compare them later
    EditableTags tags = testTags().copyWith(
      title: TagSaver.kMixedValueStr,
    );
    GlobalKey<EditorDetailsWidgetState> key = await runTest(
      tester,
      tags,
      false,
    );

    // clear text
    MacosAutoCompleteField title = findByKey(tester, find, 'title');
    title.focusNode!.requestFocus();
    await tester.pump();
    await simulateKeyDownEvent(LogicalKeyboardKey.backspace);
    await tester.pump();
    expectTextFieldValue(tester, find, 'title', '');
    expectTextFieldPlaceholder(tester, find, 'title', '');

    // check value
    EditableTags editableTags = key.currentState!.tags;
    expect(editableTags, tags.copyWith(title: TagSaver.kClearedValueStr));
  });
  testWidgets('Multi Clear Int', (WidgetTester tester) async {
    // we need the tags to compare them later
    EditableTags tags = testTags().copyWith(
      trackCount: TagSaver.kMixedValueInt,
    );
    GlobalKey<EditorDetailsWidgetState> key = await runTest(
      tester,
      tags,
      false,
    );

    // clear text
    MacosAutoCompleteField trackIndex = findByKey(tester, find, 'track_count');
    trackIndex.focusNode!.requestFocus();
    await tester.pump();
    await simulateKeyDownEvent(LogicalKeyboardKey.backspace);
    await tester.pump();
    expectTextFieldValue(tester, find, 'track_count', '');
    expectTextFieldPlaceholder(tester, find, 'track_count', '');

    // check value
    EditableTags editedTags = key.currentState!.tags;
    expect(editedTags, tags.copyWith(trackCount: TagSaver.kClearedValueInt));
  });
}
