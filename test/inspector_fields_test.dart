import 'package:flutter_test/flutter_test.dart' hide Tags;
import 'package:taglib_ffi/taglib_ffi.dart';
import 'package:trax/model/inspector_fields.dart';
import 'package:trax/model/track.dart';
import 'package:trax/utils/track_utils.dart';

Track _t(
  String title, {
  String album = 'GUTS',
  String artist = 'Olivia Rodrigo',
  String genre = 'Pop',
  int year = 2023,
  int index = 1,
  Format format = Format.flac,
  int bitrate = 0,
  int bits = 16,
  int rate = 44100,
}) =>
    Track(
      filename: '/m/$title.flac',
      filesize: 1,
      lastModified: 0,
      format: format,
      tags: Tags(
        title: title,
        album: album,
        artist: artist,
        genre: genre,
        year: year,
        trackIndex: index,
        bitrate: bitrate,
        bitsPerSample: bits,
        sampleRate: rate,
      ),
    );

void main() {
  group('inspector fields', () {
    test('nothing selected', () {
      final f = InspectorFields.from([]);
      expect(f.isEmpty, isTrue);
      expect(f.canCleanupTitles, isFalse);
      expect(f.canReveal, isFalse);
    });

    test('one track shows its own values', () {
      final f = InspectorFields.from([_t('vampire', index: 3)]);
      expect(f.title.value, 'vampire');
      expect(f.trackNumber.value, '3');
      expect(f.year.value, '2023');
      expect(f.sameAlbum, isTrue);
      expect(f.canReveal, isTrue);
      expect(f.canCleanupTitles, isFalse);
    });

    test('several tracks: shared values stay, the rest is mixed', () {
      final f = InspectorFields.from([
        _t('bad idea right?', index: 2),
        _t('vampire', index: 3),
        _t('lacy', index: 4),
      ]);
      expect(f.title.isMixed, isTrue);
      expect(f.trackNumber.isMixed, isTrue);
      expect(f.album.value, 'GUTS');
      expect(f.genre.value, 'Pop');
      expect(f.year.value, '2023');
      expect(f.sameAlbum, isTrue);
      expect(f.canCleanupTitles, isTrue);
      expect(f.canReveal, isFalse);
    });

    test('tracks from two albums do not share a cover', () {
      final f = InspectorFields.from([_t('a'), _t('b', album: 'SOUR')]);
      expect(f.album.isMixed, isTrue);
      expect(f.sameAlbum, isFalse);
    });

    test('a missing year is empty, not mixed', () {
      final f = InspectorFields.from([_t('a', year: 0), _t('b', year: 0)]);
      expect(f.year.isMixed, isFalse);
      expect(f.year.isEmpty, isTrue);
    });
  });

  group('format summary', () {
    test('lossy shows the bitrate', () {
      expect(_t('a', format: Format.mp3, bitrate: 181).formatSummary,
          'MP3 181 kbps');
    });

    test('lossless shows bit depth and sample rate', () {
      expect(_t('a').formatSummary, 'FLAC 16/44.1');
      expect(_t('a', rate: 96000, bits: 24).formatSummary, 'FLAC 24/96');
    });

    test('degrades gracefully when details are unknown', () {
      expect(_t('a', format: Format.mp3, bitrate: 0).formatSummary, 'MP3');
      expect(_t('a', bits: 0).formatSummary, 'FLAC');
    });
  });
}
