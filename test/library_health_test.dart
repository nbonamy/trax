import 'dart:ui' show Brightness;

import 'package:flutter_test/flutter_test.dart' hide Tags;
import 'package:taglib_ffi/taglib_ffi.dart';
import 'package:trax/model/library_health.dart';
import 'package:trax/model/library_query.dart';
import 'package:trax/model/track.dart';
import 'package:trax/utils/monogram.dart';

HealthRow row({
  String artist = 'Olivia Rodrigo',
  String album = 'GUTS',
  String genre = 'Pop',
  int year = 2023,
  bool compilation = false,
}) =>
    HealthRow(
      artist: artist,
      album: album,
      genre: genre,
      year: year,
      compilation: compilation,
    );

Track track(
  String title, {
  String artist = 'Olivia Rodrigo',
  String album = 'GUTS',
  String genre = 'Pop',
  int year = 2023,
  int index = 1,
  int volume = 1,
  bool compilation = false,
}) =>
    Track(
      filename: '/m/$artist/$album/$title.flac',
      filesize: 1,
      lastModified: 0,
      format: Format.flac,
      tags: Tags(
        title: title,
        album: album,
        artist: artist,
        genre: genre,
        year: year,
        trackIndex: index,
        volumeIndex: volume,
        compilation: compilation,
      ),
    );

void main() {
  group('library health', () {
    test('an empty library is tidy', () {
      final h = LibraryHealth.compute([]);
      expect(h.isTidy, isTrue);
      expect(h.score, 100);
    });

    test('a clean library scores 100', () {
      final h = LibraryHealth.compute([row(), row(), row(album: 'SOUR')]);
      expect(h.isTidy, isTrue);
      expect(h.issueCount, 0);
      expect(h.score, 100);
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
    });

    test('compilations may mix genres', () {
      final h = LibraryHealth.compute([
        row(album: 'Hits', genre: 'Pop', compilation: true),
        row(album: 'Hits', genre: 'Rock', compilation: true),
      ]);
      expect(h.mixedGenreAlbums, 0);
    });

    test('flags tracks without a year', () {
      final h = LibraryHealth.compute([row(year: 0), row(), row(year: 0)]);
      expect(h.noYearTracks, 2);
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
        row(year: 0, genre: 'Pop'),
        row(year: 0, genre: 'Rock'),
        row(album: 'Other'),
      ]);
      expect(h.affectedTracks, 2);
      expect(h.score, 33);
    });
  });

  group('review: exactly what the panel counted', () {
    final all = [
      track('a', album: 'GUTS', genre: 'Pop', index: 1),
      track('b', album: 'GUTS', genre: 'Rock', index: 2),
      track('c', album: 'SOUR', genre: 'Pop', year: 0),
      track('d', album: 'SOUR', genre: 'Pop'),
      track('e', album: 'Clean'),
    ];

    test('mixed genres lists every track of every such album', () {
      final tracks = LibraryQuery.reviewTracks(ReviewKind.mixedGenres, all);
      expect(tracks.map((t) => t.safeTags.title), ['a', 'b']);
      final h = LibraryHealth.compute(all.map(HealthRow.fromTrack).toList());
      expect(
        LibraryQuery.groupAlbums(tracks).length,
        h.mixedGenreAlbums,
      );
    });

    test('no year lists only the tracks without one', () {
      final tracks = LibraryQuery.reviewTracks(ReviewKind.noYear, all);
      expect(tracks.map((t) => t.safeTags.title), ['c']);
      final h = LibraryHealth.compute(all.map(HealthRow.fromTrack).toList());
      expect(tracks.length, h.noYearTracks);
    });

    test('nothing to review, nothing listed', () {
      expect(
        LibraryQuery.reviewTracks(ReviewKind.noYear, [track('a')]),
        isEmpty,
      );
    });
  });

  group('grouping', () {
    test('albums by artist then year, tracks in disc and track order', () {
      final groups = LibraryQuery.groupAlbums([
        track('late', artist: 'The Zebras', album: 'Z2', year: 2010),
        track('t2', album: 'GUTS', year: 2023, index: 2),
        track('t1', album: 'GUTS', year: 2023, index: 1),
        track('old', album: 'SOUR', year: 2021),
        track('d2', artist: 'Aaron', album: 'Two Discs', volume: 2, index: 1),
        track('d1', artist: 'Aaron', album: 'Two Discs', volume: 1, index: 9),
      ]);
      expect(groups.map((g) => g.album), ['Two Discs', 'SOUR', 'GUTS', 'Z2']);
      expect(groups[2].tracks.map((t) => t.safeTags.title), ['t1', 't2']);
      expect(groups[0].tracks.map((t) => t.safeTags.title), ['d1', 'd2']);
    });

    test('compilations are grouped together whoever the artist is', () {
      final groups = LibraryQuery.groupAlbums([
        track('a', artist: 'X', album: 'Hits', compilation: true),
        track('b', artist: 'Y', album: 'Hits', compilation: true),
        track('c', artist: 'X', album: 'Hits'), // not a compilation
      ]);
      expect(groups.length, 2);
      expect(
        groups
            .where((g) => g.artist == Track.kArtistCompilations)
            .single
            .tracks
            .length,
        2,
      );
    });
  });

  group('search matching', () {
    final t = track('vampire', album: 'GUTS');

    test('tokens', () {
      expect(LibraryQuery.tokens('  Olivia   GUTS '), ['olivia', 'guts']);
      expect(LibraryQuery.tokens('   '), isEmpty);
    });

    test('every word must match somewhere, in any order', () {
      expect(LibraryQuery.matches(t, LibraryQuery.tokens('vamp')), isTrue);
      expect(
          LibraryQuery.matches(t, LibraryQuery.tokens('rodrigo guts')), isTrue);
      expect(
          LibraryQuery.matches(t, LibraryQuery.tokens('guts olivia')), isTrue);
      expect(LibraryQuery.matches(t, LibraryQuery.tokens('vampire sour')),
          isFalse);
    });

    test('an empty search matches nothing', () {
      expect(LibraryQuery.matches(t, const []), isFalse);
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
