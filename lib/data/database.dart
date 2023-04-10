import 'dart:collection';

import 'package:flutter/widgets.dart' hide Row;
import 'package:provider/provider.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:taglib_ffi/taglib_ffi.dart';

import '../model/track.dart';
import '../utils/path_utils.dart';
import '../utils/track_utils.dart';

class TraxDatabase extends ChangeNotifier {
  static const int _latestSchemaVersion = 1;
  String? databaseFile;
  Database? _database;

  static TraxDatabase of(BuildContext context) {
    return Provider.of<TraxDatabase>(context, listen: false);
  }

  TraxDatabase({
    this.databaseFile,
  });

  Future<void> init() async {
    String dbFile = databaseFile ?? await SystemPath.dbFile();
    print('Database file: $dbFile');
    _database = sqlite3.open(dbFile);
    _checkSchemaVersion();
    //clear();
  }

  bool artistExists(String artist) {
    final ResultSet resultSet = _database!.select(
        'SELECT COUNT(*) FROM tracks WHERE artist=(?) AND compilation=0',
        [artist]);
    return resultSet.first[0] != 0;
  }

  List<String> files() {
    final ResultSet resultSet =
        _database!.select('SELECT DISTINCT filename FROM tracks');
    return resultSet.rows.map((r) => r[0].toString()).toList();
  }

  List<String> artists() {
    final ResultSet resultSet = _database!.select(
        'SELECT DISTINCT artist, compilation FROM tracks ORDER BY artist');
    List<String> artists = [];
    for (Row row in resultSet) {
      if (row[1] == 1) {
        if (artists.contains(Track.kArtistCompilations) == false) {
          artists.add(Track.kArtistCompilations);
        }
      } else {
        artists.add(row[0]);
      }
    }
    artists.sort((a, b) {
      if (a == Track.kArtistCompilations) return -1;
      if (b == Track.kArtistCompilations) return 1;
      if (a.isEmpty) return -1;
      if (b.isEmpty) return 1;
      return TrackUtils.getSortableArtist(a)
          .compareTo(TrackUtils.getSortableArtist(b));
    });
    return artists;
  }

  LinkedHashMap<String, List<Track>> albums(String artist) {
    if (artist == Track.kArtistCompilations) return compilations();
    final ResultSet resultSet = _database!.select(
        'SELECT * FROM tracks WHERE artist=(?) ORDER BY album, volume_index, track_index, title',
        [artist]);
    return _dehydrateAlbums(resultSet);
  }

  LinkedHashMap<String, List<Track>> compilations() {
    final ResultSet resultSet = _database!.select(
        'SELECT * FROM tracks WHERE compilation=1 ORDER BY album, volume_index, track_index, title');
    return _dehydrateAlbums(resultSet);
  }

  Track? getTrack(String filename) {
    final ResultSet resultSet = _database!
        .select('SELECT * FROM tracks WHERE filename=(?)', [filename]);
    if (resultSet.length != 1) return null;
    return _dehydrateTrack(resultSet.first);
  }

  void insert(Track track, {bool notify = true}) {
    // now insert
    _database!.execute('''
    INSERT OR REPLACE INTO tracks(filename, filesize, last_modification, format,
      title, album, artist, performer, composer,
      genre, copyright, comment, year, compilation,
      volume_index, track_index, duration,
      num_channels, sample_rate, bits_per_sample, bitrate)
    VALUES((?), (?), (?), (?), (?), (?), (?), (?), (?), (?), (?), (?), (?),
      (?), (?), (?), (?), (?), (?), (?), (?))''', [
      track.filename,
      track.filesize,
      track.lastModified,
      track.format.toString(),
      track.safeTags.title,
      track.safeTags.album,
      track.safeTags.artist,
      track.safeTags.performer,
      track.safeTags.composer,
      track.safeTags.genre,
      track.safeTags.copyright,
      track.safeTags.comment,
      track.safeTags.year,
      track.safeTags.compilation,
      track.safeTags.volumeIndex,
      track.safeTags.trackIndex,
      track.safeTags.duration,
      track.safeTags.numChannels,
      track.safeTags.sampleRate,
      track.safeTags.bitsPerSample,
      track.safeTags.bitrate,
    ]);

    // update
    if (notify) {
      notifyListeners();
    }
  }

  void delete(String filename, {bool notify = true}) {
    _database!.execute('DELETE FROM tracks WHERE filename=(?)', [filename]);
    if (notify) notifyListeners();
  }

  void clear() {
    _database!.execute('DELETE FROM tracks');
  }

  void notify() {
    notifyListeners();
  }

  void _checkSchemaVersion() {
    try {
      final ResultSet resultSet = _database!.select('SELECT * FROM info');
      final Row row = resultSet.first;
      final int version = int.parse(row['version'].toString());
      if (version != _latestSchemaVersion) {
        _updateSchema(version);
      }
    } on SqliteException catch (e) {
      if (e.extendedResultCode == 1 && e.message.contains('no such table')) {
        _createSchema();
      } else {
        rethrow;
      }
    } catch (e) {
      _database = null;
    }
  }

  void _createSchema() {
    // tracks table
    _database!.execute('''
    CREATE TABLE tracks (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      filename TEXT, filesize INTEGER, last_modification INTEGER, format TEXT,
      title TEXT, album TEXT, artist TEXT, performer TEXT, composer TEXT,
      genre TEXT, copyright TEXT, comment TEXT, year TEXT, compilation INTEGER,
      volume_index INTEGER, track_index INTEGER, duration INTEGER,
      num_channels INTEGER, sample_rate INTEGER, bits_per_sample INTEGER, bitrate INTEGER
    );
    ''');

    // indexes
    _database!.execute('''
      CREATE UNIQUE INDEX tracks_idx1 ON tracks(filename);
    ''');
    _database!.execute('''
      CREATE INDEX tracks_idx2 ON tracks(artist, compilation);
    ''');

    // tracks table
    _database!.execute('''
    CREATE TABLE info (
      version INTEGER
    );
    ''');

    // insert
    _database!.execute(
        'INSERT INTO info(version) VALUES((?))', [_latestSchemaVersion]);
  }

  void _updateSchema(int currentVersion) {
    if (currentVersion == _latestSchemaVersion) return;
    // no update yet
    _updateVersion(currentVersion + 1);
    _updateSchema(currentVersion + 1);
  }

  void _updateVersion(int version) {
    _database!.execute('UPDATE info SET version=(?)', [version]);
  }

  LinkedHashMap<String, List<Track>> _dehydrateAlbums(ResultSet resultSet) {
    LinkedHashMap<String, List<Track>> albums = LinkedHashMap();
    for (final Row row in resultSet) {
      String album = row['album'].toString();
      if (albums.containsKey(album) == false) {
        albums[album] = [];
      }
      albums[album]!.add(_dehydrateTrack(row));
    }

    // now sort by year of 1st track
    List<String> titles = albums.keys.toList();
    titles.sort((a, b) {
      int y1 = albums[a]!.first.tags?.year ?? 0;
      int y2 = albums[b]!.first.tags?.year ?? 0;
      return (y1 != y2) ? y1.compareTo(y2) : a.compareTo(b);
    });

    // now rebuild the list
    return LinkedHashMap.fromIterable(
      titles,
      key: (t) => t,
      value: (t) => albums[t]!,
    );
  }

  Track _dehydrateTrack(Row row) {
    return Track(
      filename: row['filename'],
      filesize: row['filesize'],
      lastModified: row['last_modification'],
      format: row['format'].toString().toFormat(),
      tags: Tags(
        title: row['title'],
        album: row['album'],
        artist: row['artist'],
        performer: row['performer'],
        composer: row['composer'],
        genre: row['genre'],
        copyright: row['copyright'],
        comment: row['comment'],
        year: int.parse(row['year']),
        compilation: row['compilation'] == 1,
        volumeIndex: row['volume_index'],
        trackIndex: row['track_index'],
        duration: row['duration'],
        numChannels: row['num_channels'],
        sampleRate: row['sample_rate'],
        bitsPerSample: row['bits_per_sample'],
        bitrate: row['bitrate'],
      ),
    );
  }
}
