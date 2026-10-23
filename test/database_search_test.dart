import 'package:flutter_test/flutter_test.dart' hide Tags;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:taglib_ffi/taglib_ffi.dart';
import 'package:trax/data/database.dart';
import 'package:trax/model/library_health.dart';
import 'package:trax/model/track.dart';
import 'package:trax/utils/logger.dart';

Track t(String title, String album, String artist,
        {String genre = 'Pop', int year = 2023, int i = 1}) =>
    Track(
        filename: '/m/$artist/$album/$title.flac',
        filesize: 1,
        lastModified: 0,
        format: Format.flac,
        tags: Tags(
            title: title,
            album: album,
            artist: artist,
            performer: artist,
            genre: genre,
            year: year,
            trackIndex: i));

void main() {
  test('search and review against a real sqlite', () async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    final db =
        TraxDatabase(logger: Logger(), databaseFile: inMemoryDatabasePath);
    await db.init();
    db.insert(t('vampire', 'GUTS', 'Olivia Rodrigo'), notify: false);
    db.insert(t('lacy', 'GUTS', 'Olivia Rodrigo', genre: 'Rock', i: 2),
        notify: false);
    db.insert(t('100% pure_love', 'Hits', 'Crystal Waters', year: 0),
        notify: false);
    db.insert(t('Brutal', 'SOUR', 'Olivia Rodrigo', year: 0), notify: false);
    await Future.delayed(const Duration(milliseconds: 200));

    expect((await db.searchTracks('olivia')).length, 3);
    expect((await db.searchTracks('OLIVIA guts')).length, 2);
    expect((await db.searchTracks('vamp')).single.safeTags.title, 'vampire');
    expect((await db.searchTracks('100%')).single.safeTags.title,
        '100% pure_love');
    expect((await db.searchTracks('%')).length,
        1); // a literal percent, not a wildcard
    expect((await db.searchTracks('_')).length, 1);
    expect((await db.searchTracks('  ')).length, 0);

    final h = await db.health();
    expect(h.mixedGenreAlbums, 1);
    expect(h.noYearTracks, 2);
    expect((await db.reviewTracks(ReviewKind.mixedGenres)).length, 2);
    expect((await db.reviewTracks(ReviewKind.noYear)).length, 2);
  });
}
