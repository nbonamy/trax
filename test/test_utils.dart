import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart' hide Tags;
import 'package:taglib_ffi/taglib_ffi.dart';
import 'package:trax/model/preferences.dart';
import 'package:trax/model/track.dart';

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
