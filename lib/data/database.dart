import 'dart:collection';

import 'package:flutter/widgets.dart' hide Row;
import 'package:provider/provider.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:taglib_ffi/taglib_ffi.dart';

import '../model/track.dart';
import '../utils/path_utils.dart';

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
    _database = sqlite3.open(dbFile);
    _checkSchemaVersion();
  }

  List<String> files() {
    final ResultSet resultSet =
        _database!.select('SELECT DISTINCT filename FROM tracks');
    return resultSet.rows.map((r) => r[0].toString()).toList();
  }

  List<String> artists() {
    final ResultSet resultSet =
        _database!.select('SELECT DISTINCT artist FROM tracks ORDER BY artist');
    return resultSet.rows.map((r) => r[0].toString()).toList();
  }

  LinkedHashMap<String, List<Track>> albums(String artist) {
    LinkedHashMap<String, List<Track>> albums = LinkedHashMap();
    final ResultSet resultSet = _database!.select(
        'SELECT * FROM tracks WHERE artist=(?) ORDER BY year, volume_index, track_index',
        [artist]);
    for (final Row row in resultSet) {
      String album = row['album'].toString();
      if (albums.containsKey(album) == false) {
        albums[album] = [];
      }
      albums[album]!.add(
        Track(
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
        ),
      );
    }
    return albums;
  }

  void insert(Track track) {
    // first delete
    delete(track.filename, notify: false);

    // now insert
    _database!.execute('''
    INSERT INTO tracks(filename, filesize, last_modification, format,
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
    notifyListeners();
  }

  void delete(String filename, {bool notify = true}) {
    _database!.execute('DELETE FROM tracks WHERE filename=(?)', [filename]);
    if (notify) notifyListeners();
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
    // TODO: update schema
    _updateVersion(currentVersion + 1);
    _updateSchema(currentVersion + 1);
  }

  void _updateVersion(int version) {
    _database!.execute('UPDATE info SET version=(?)', [version]);
  }
}
