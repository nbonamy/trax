import 'package:flutter_test/flutter_test.dart';
import 'package:taglib_ffi/taglib_ffi.dart';
import 'package:trax/data/database.dart';
import 'package:trax/model/preferences.dart';
import 'package:trax/processors/saver.dart';
import 'package:trax/utils/track_utils.dart';
import 'package:trax/utils/logger.dart';

import 'test_utils.dart';

void main() {
  Logger logger = Logger();
  TagLib tagLib = TagLib();
  TraxDatabase database = TraxDatabase(logger: logger);
  PreferencesBase preferences = PreferencesMock();
  TagSaver saver = TagSaver(tagLib, database, preferences);

  test('filename', () {
    // basic
    expect(
      saver.targetFilename(subject('test'), true),
      '$kMusicFolder/test.mp3',
    );
    expect(
      saver.targetFilename(subject('test', trackIndex: 1), true),
      '$kMusicFolder/01 test.mp3',
    );
    expect(
      saver.targetFilename(
          subject('test', volumeIndex: 1, trackIndex: 2), true),
      '$kMusicFolder/1-02 test.mp3',
    );

    // make sure filename is sanitized
    expect(
      saver.targetFilename(subject('/test/'), true),
      '$kMusicFolder/_test_.mp3',
    );
  });

  test('filepath', () {
    // basic
    expect(
      saver.targetFilename(
          subject('test', album: 'album', artist: 'artist'), true),
      '$kMusicFolder/artist/album/test.mp3',
    );

    // compilations
    expect(
      saver.targetFilename(
          subject('test', album: 'album', artist: 'artist', compilation: true),
          true),
      '$kMusicFolder/Compilations/album/test.mp3',
    );

    // sanitization
    expect(
      saver.targetFilename(
          subject('/test/', album: '<album>', artist: '"artist"'), true),
      '$kMusicFolder/_artist_/_album_/_test_.mp3',
    );
  });

  test('fullpath', () {
    expect(
      saver.targetFilename(
          subject('test',
              album: 'album', artist: 'artist', volumeIndex: 1, trackIndex: 2),
          true),
      '$kMusicFolder/artist/album/1-02 test.mp3',
    );
  });

  test('not_organized', () {
    expect(
      saver.targetFilename(
          subject('test',
              album: 'album', artist: 'artist', volumeIndex: 1, trackIndex: 2),
          false),
      '$kMusicFolder/1-02 test.mp3',
    );
  });

  testWidgets('localizations', (WidgetTester t) async {
    TrackUtils.initLocalization(await getLocalizations(t));
    expect(
      saver.targetFilename(subject(''), false),
      '$kMusicFolder/Unknown title.mp3',
    );
    expect(
      saver.targetFilename(subject(''), true),
      '$kMusicFolder/Unknown artist/Unknown album/Unknown title.mp3',
    );
  });
}
