import 'package:flutter_test/flutter_test.dart';
import 'package:trax/model/track.dart';
import 'package:trax/utils/track_utils.dart';

import 'test_utils.dart';

void main() {
  test('isTrack', () {
    expect(Track.getFormat('test.mp3'), Format.mp3);
    expect(Track.getFormat('test.ogg'), Format.vorbis);
    expect(Track.getFormat('test.m4a'), Format.alac);
    expect(Track.getFormat('test.flac'), Format.flac);
    expect(Track.getFormat('test'), Format.notAudio);
    expect(Track.getFormat('test.docx'), Format.notAudio);
    expect(Track.getFormat('test.mp3.tmp'), Format.notAudio);
    expect(Track.getFormat('._test.mp3'), Format.mp3);
  });

  test('isTrack', () {
    expect(Track.isTrack('test.mp3'), true);
    expect(Track.isTrack('test.ogg'), true);
    expect(Track.isTrack('test.m4a'), true);
    expect(Track.isTrack('test.flac'), true);
    expect(Track.isTrack('test'), false);
    expect(Track.isTrack('test.docx'), false);
    expect(Track.isTrack('test.mp3.tmp'), false);
    expect(Track.isTrack('._test.mp3'), false);
  });

  // test('parse', () {
  //   TagLib tagLib = TagLib();
  //   Track track = Track.parse('../data/sample.mp3', tagLib);
  //   expect(track.filesize, 22640);
  //   expect(track.safeTags.title, 'Title');
  //   expect(track.safeTags.album, 'Album');
  //   expect(track.safeTags.artist, 'Artist');
  //   expect(track.safeTags.performer, 'Performer');
  //   expect(track.safeTags.composer, 'Composer');
  // });

  testWidgets('localizations', (WidgetTester t) async {
    TrackUtils.initLocalization(await getLocalizations(t));
  });
}
