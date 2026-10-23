import 'dart:ui' show Brightness;

import 'package:flutter_test/flutter_test.dart';
import 'package:trax/model/library_health.dart';
import 'package:trax/model/track.dart';
import 'package:trax/utils/monogram.dart';

HealthRow row({
  String artist = 'Olivia Rodrigo',
  String album = 'GUTS',
  String genre = 'Pop',
  int year = 2023,
  bool lossy = false,
  int bitrate = 0,
  bool compilation = false,
}) =>
    HealthRow(
      artist: artist,
      album: album,
      genre: genre,
      year: year,
      lossy: lossy,
      bitrate: bitrate,
      compilation: compilation,
    );

void main() {
  group('library health', () {
    test('an empty library is tidy', () {
      final h = LibraryHealth.compute([]);
      expect(h.isTidy, isTrue);
      expect(h.score, 100);
    });

    test('a clean library scores 100', () {
      final h =
          LibraryHealth.compute([row(), row(), row(lossy: true, bitrate: 320)]);
      expect(h.isTidy, isTrue);
      expect(h.issueCount, 0);
      expect(h.score, 100);
    });

    test('flags lossy tracks below 192 kbps, never lossless ones', () {
      final h = LibraryHealth.compute([
        row(lossy: true, bitrate: 181),
        row(lossy: true, bitrate: 192),
        row(lossy: false, bitrate: 0),
        row(lossy: true, bitrate: 0), // unknown bitrate is not a verdict
      ]);
      expect(h.lowBitrateTracks, 1);
      expect(h.firstLowBitrate?.album, 'GUTS');
    });

    test('flags albums whose tracks disagree on genre', () {
      final h = LibraryHealth.compute([
        row(genre: 'Pop'),
        row(genre: 'pop'), // same genre, different case
        row(album: 'SOUR', genre: 'Pop'),
        row(album: 'SOUR', genre: 'Rock'),
        row(album: 'SOUR', genre: ''), // empty is not a genre
      ]);
      expect(h.mixedGenreAlbums, 1);
      expect(h.firstMixedGenre?.album, 'SOUR');
    });

    test('compilations may mix genres and are reviewed under Compilations', () {
      final h = LibraryHealth.compute([
        row(album: 'Hits', genre: 'Pop', compilation: true),
        row(album: 'Hits', genre: 'Rock', compilation: true, year: 0),
      ]);
      expect(h.mixedGenreAlbums, 0);
      expect(h.firstNoYear?.artist, Track.kArtistCompilations);
    });

    test('flags tracks without a year', () {
      final h = LibraryHealth.compute([row(year: 0), row(), row(year: 0)]);
      expect(h.noYearTracks, 2);
      expect(h.firstNoYear?.artist, 'Olivia Rodrigo');
    });

    test('score is the share of tracks without any issue', () {
      final h = LibraryHealth.compute([
        row(year: 0), // affected
        row(album: 'SOUR', genre: 'Pop'),
        row(album: 'SOUR', genre: 'Rock'), // both SOUR tracks affected
        row(album: 'Clean'),
      ]);
      expect(h.affectedTracks, 3);
      expect(h.score, 25);
      expect(h.issueCount, 2);
    });

    test('a track with several issues is only counted once', () {
      final h = LibraryHealth.compute([
        row(year: 0, lossy: true, bitrate: 128),
        row(),
      ]);
      expect(h.affectedTracks, 1);
      expect(h.score, 50);
    });
  });

  group('monogram', () {
    test('initials', () {
      expect(artistInitials('AC/DC'), 'AC');
      expect(artistInitials('AaRON'), 'Aa');
      expect(artistInitials('Abd Al Malik'), 'AM');
      expect(artistInitials('Adam and the Ants'), 'AA');
      expect(artistInitials('The Alan Parsons Project'), 'AP');
      expect(artistInitials('Angus & Julia Stone'), 'AJ');
      expect(artistInitials('Al Green'), 'Gr');
      expect(artistInitials('  '), '?');
      expect(artistInitials('Björk'), 'Bj');
    });

    test('colors are stable per name and respect brightness', () {
      final a = monogramColors('Arctic Monkeys', Brightness.light);
      final b = monogramColors('arctic monkeys ', Brightness.light);
      expect(a.background, b.background);
      final d = monogramColors('Arctic Monkeys', Brightness.dark);
      expect(d.background, isNot(a.background));
    });

    test('names spread over several colors', () {
      final names = [
        'AC/DC',
        'AaRON',
        'Abd Al Malik',
        'Adam and the Ants',
        'Alain Souchon',
        'Arctic Monkeys',
        'Axel Bauer',
        'Bauhaus'
      ];
      expect(names.map(monogramIndex).toSet().length, greaterThan(2));
    });
  });
}
