import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart' hide Tags;
import 'package:macos_ui/macos_ui.dart';
import 'package:provider/provider.dart';
import 'package:taglib_ffi/taglib_ffi.dart';
import 'package:trax/audioplayer/audio_player.dart';
import 'package:trax/components/theme.dart';
import 'package:trax/data/database.dart';
import 'package:trax/model/editable_tags.dart';
import 'package:trax/model/preferences.dart';
import 'package:trax/model/selection.dart';
import 'package:trax/model/track.dart';
import 'package:trax/utils/artwork_provider.dart';
import 'package:trax/utils/logger.dart';

const kMusicFolder = '/Users/trax/Music';

class PreferencesMock implements PreferencesBase {
  @override
  String get musicFolder => kMusicFolder;
}

Track subject(
  String title, {
  String artist = '',
  String album = '',
  bool compilation = false,
  int volumeIndex = 0,
  int trackIndex = 0,
}) {
  return Track(
    id: 0,
    filename: '/Users/trax/Downloads/test.mp3',
    filesize: 0,
    lastModified: 0,
    format: Format.mp3,
    tags: Tags(
      title: title,
      album: album,
      artist: artist,
      compilation: compilation,
      volumeIndex: volumeIndex,
      trackIndex: trackIndex,
    ),
  );
}

Future<AppLocalizations> getLocalizations(WidgetTester t) async {
  late AppLocalizations result;
  await t.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Material(
        child: Builder(
          builder: (BuildContext context) {
            result = AppLocalizations.of(context)!;
            return Container();
          },
        ),
      ),
    ),
  );
  return result;
}

Future<Widget> bootstrapWidget(Widget widget) async {
  // logger
  Logger logger = Logger();

  // load some stuff
  TraxDatabase traxDatabase = TraxDatabase(logger: logger);
  Preferences preferences = Preferences();
  // await preferences.init();
  // await traxDatabase.init();

  return MacosApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AppTheme(),
        ),
        ChangeNotifierProvider(
          create: (_) => logger,
        ),
        ChangeNotifierProvider(
          create: (_) => preferences,
        ),
        ChangeNotifierProvider(
          create: (_) => traxDatabase,
        ),
        ChangeNotifierProvider(
          create: (_) => SelectionModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => ArtworkProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => AudioPlayer(),
        ),
      ],
      builder: (context, _) => widget,
    ),
  );
}

T findByKey<T extends Widget>(
  WidgetTester tester,
  CommonFinders find,
  String key,
) {
  return tester.widget(find.byKey(Key(key)));
}

void expectTextFieldValue(
  WidgetTester tester,
  CommonFinders find,
  String key,
  String value,
) {
  expect(
    findByKey<MacosAutoCompleteField>(
      tester,
      find,
      key,
    ).controller!.text,
    value,
  );
}

void expectTextFieldPlaceholder(
  WidgetTester tester,
  CommonFinders find,
  String key,
  String placeholder,
) {
  expect(
    findByKey<MacosAutoCompleteField>(
      tester,
      find,
      key,
    ).placeholder,
    placeholder == '' ? null : placeholder,
  );
}

void expectCheckboxField(
  WidgetTester tester,
  CommonFinders find,
  String key,
  bool? value,
) {
  MacosCheckbox widget = findByKey<MacosCheckbox>(
    tester,
    find,
    key,
  );
  expect(widget.value, value);
}

EditableTags testTags() {
  return EditableTags.fromTags(
    Tags(
      title: 'Title',
      album: 'Album',
      artist: 'Artist',
      performer: 'Performer',
      composer: 'Composer',
      genre: 'Genre',
      year: 2000,
      volumeIndex: 1,
      volumeCount: 2,
      trackIndex: 3,
      trackCount: 4,
      compilation: false,
      copyright: 'Copyright',
      comment: 'Comment',
    ),
  );
}
