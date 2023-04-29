import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:mutex/mutex.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:taglib_ffi/taglib_ffi.dart';

import '../model/track.dart';
import '../utils/logger.dart';
import '../utils/path_utils.dart';
import '../utils/track_utils.dart';

enum AlbumOrdering {
  none,
  alpha,
  chrono,
}

class LibraryInfo {
  int tracks = 0;
  int duration = 0;
  int artists = 0;
  int albums = 0;
}

class TraxDatabase extends ChangeNotifier {
  static const int _latestSchemaVersion = 1;
  final Logger logger;
  String? databaseFile;
  Database? _database;
  LibraryInfo? _cachedInfo;
  final Mutex _cacheMutex = Mutex();

  static TraxDatabase of(BuildContext context) {
    return Provider.of<TraxDatabase>(context, listen: false);
  }

  bool get isOpen {
    return _database != null;
  }

  TraxDatabase({
    required this.logger,
    this.databaseFile,
  });

  Future<void> init() async {
    String dbFile = databaseFile ?? await SystemPath.dbFile();
    logger.i('[DB] File: $dbFile');
    _database = await openDatabase(
      dbFile,
      version: _latestSchemaVersion,
      onCreate: _createSchema,
      onUpgrade: _updateSchema,
    );
    //clear();
  }

  Future<LibraryInfo> info() async {
    // is cached?
    if (_cachedInfo != null) {
      return _cachedInfo!;
    }

    await _cacheMutex.protect(() async {
      _cachedInfo = LibraryInfo();
      List<Map> resultSet =
          await _database!.rawQuery('SELECT COUNT(*) AS count FROM tracks');
      _cachedInfo!.tracks = resultSet.first['count'];
      resultSet = await _database!
          .rawQuery('SELECT SUM(duration) AS total FROM tracks');
      _cachedInfo!.duration = resultSet.first['total'] ?? 0;
      resultSet = await _database!.rawQuery(
          'SELECT COUNT(DISTINCT artist) AS count FROM tracks WHERE compilation=0');
      _cachedInfo!.artists = resultSet.first['count'];
      resultSet = await _database!.rawQuery(
          'SELECT COUNT(*) AS count FROM (SELECT DISTINCT artist, album FROM TRACKS WHERE compilation=0)');
      _cachedInfo!.albums = resultSet.first['count'];
    });
    return _cachedInfo!;
  }

  Future<bool> get isEmpty async {
    final List<Map> resultSet =
        await _database!.rawQuery('SELECT COUNT(*) AS count FROM tracks');
    return resultSet.first['count'] == 0;
  }

  Future<bool> artistExists(String artist) async {
    final List<Map> resultSet = await _database!.rawQuery(
        'SELECT COUNT(*) AS count FROM tracks WHERE artist=(?) AND compilation=0',
        [artist]);
    return resultSet.first['count'] != 0;
  }

  Future<List<String>> files() async {
    final List<Map> resultSet =
        await _database!.rawQuery('SELECT DISTINCT filename FROM tracks');
    return resultSet.map((r) => r['filename'].toString()).toList();
  }

  Future<List<String>> artists() async {
    final List<Map> resultSet = await _database!.rawQuery(
        'SELECT DISTINCT artist, compilation FROM tracks ORDER BY artist');
    Set<String> artistLc = {};
    List<String> artists = [];
    for (Map row in resultSet) {
      if (row['compilation'] == 1) {
        if (artists.contains(Track.kArtistCompilations) == false) {
          artists.add(Track.kArtistCompilations);
        }
      } else {
        String artist = row['artist'].toString();
        if (artistLc.contains(artist.toLowerCase()) == false) {
          artists.add(artist);
          artistLc.add(artist.toLowerCase());
        }
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

  Future<List<String>> allArtists() {
    return _allColumnValues('artist');
  }

  Future<List<String>> allAlbums() {
    return _allColumnValues('album');
  }

  Future<List<String>> allPerformers() {
    return _allColumnValues('performer');
  }

  Future<List<String>> allComposers() {
    return _allColumnValues('composer');
  }

  Future<List<String>> allGenres() {
    return _allColumnValues('genre');
  }

  Future<AlbumList> albums(String artist) async {
    if (artist == Track.kArtistCompilations) return compilations();
    final List<Map> resultSet = await _database!.rawQuery(
        'SELECT * FROM tracks WHERE LOWER(artist)=LOWER((?))', [artist]);
    return _dehydrateAlbums(resultSet, AlbumOrdering.chrono);
  }

  Future<AlbumList> compilations() async {
    final List<Map> resultSet =
        await _database!.rawQuery('SELECT * FROM tracks WHERE compilation=1');
    return _dehydrateAlbums(resultSet, AlbumOrdering.alpha);
  }

  Future<AlbumList> recents() async {
    final List<Map> resultSet = await _database!.rawQuery(
        'SELECT * FROM tracks WHERE imported_at>(UNIXEPOCH()-30*24*60*60)*1000 ORDER BY imported_at DESC');
    return _dehydrateAlbums(resultSet, AlbumOrdering.none);
  }

  Future<Track?> getTrackById(String id) async {
    final List<Map> resultSet =
        await _database!.rawQuery('SELECT * FROM tracks WHERE id=(?)', [id]);
    if (resultSet.length != 1) return null;
    return _dehydrateTrack(resultSet.first);
  }

  Future<Track?> getTrackByFilename(String filename) async {
    final List<Map> resultSet = await _database!
        .rawQuery('SELECT * FROM tracks WHERE filename=(?)', [filename]);
    if (resultSet.length != 1) return null;
    return _dehydrateTrack(resultSet.first);
  }

  void insert(Track track, {bool notify = true}) async {
    // update importedAt if needed
    if (track.importedAt == 0) {
      track.importedAt = DateTime.now().millisecondsSinceEpoch;
    }

    // now insert
    int id = await _database!.rawInsert('''
    INSERT OR REPLACE INTO tracks(filename, filesize, last_modification, format,
      title, album, artist, performer, composer,
      genre, copyright, comment, year, compilation,
      volume_index, volume_count, track_index, track_count, duration,
      num_channels, sample_rate, bits_per_sample, bitrate, imported_at)
    VALUES((?), (?), (?), (?), (?), (?), (?), (?), (?), (?), (?), (?), (?),
      (?), (?), (?), (?), (?), (?), (?), (?), (?), (?), (?))''', [
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
      track.safeTags.compilation ? 1 : 0,
      track.safeTags.volumeIndex,
      track.safeTags.volumeCount,
      track.safeTags.trackIndex,
      track.safeTags.trackCount,
      track.safeTags.duration,
      track.safeTags.numChannels,
      track.safeTags.sampleRate,
      track.safeTags.bitsPerSample,
      track.safeTags.bitrate,
      track.importedAt,
    ]);

    // update track
    track.id = id;

    // done
    _invalidateCache();

    // update
    if (notify) {
      notifyListeners();
    }
  }

  Future<void> delete(String filename, {bool notify = true}) async {
    await _database!
        .execute('DELETE FROM tracks WHERE filename=(?)', [filename]);
    _invalidateCache();
    if (notify) notifyListeners();
  }

  void clear() async {
    _database!.execute('DELETE FROM tracks');
    _invalidateCache();
  }

  void notify() {
    notifyListeners();
  }

  Future<void> _createSchema(Database db, int version) async {
    // tracks table
    await _database!.execute('''
    CREATE TABLE tracks (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      filename TEXT UNIQUE, filesize INTEGER, last_modification INTEGER, format TEXT,
      title TEXT, album TEXT, artist TEXT, performer TEXT, composer TEXT,
      genre TEXT, copyright TEXT, comment TEXT, year TEXT, compilation INTEGER,
      volume_index INTEGER, volume_count INTEGER, track_index INTEGER, track_count INTEGER,
      duration INTEGER, num_channels INTEGER, sample_rate INTEGER,
      bits_per_sample INTEGER, bitrate INTEGER, imported_at INTEGER
    );
    ''');

    // indexes
    await _database!.execute('''
      CREATE INDEX tracks_idx1 ON tracks(artist, compilation);
    ''');
  }

  void _updateSchema(Database db, int oldVersion, int newVersion) {
    if (oldVersion == newVersion) return;
    // no update yet
    _updateSchema(db, oldVersion + 1, newVersion);
  }

  AlbumList _dehydrateAlbums(
    List<Map> resultSet,
    AlbumOrdering ordering,
  ) {
    AlbumList albums = LinkedHashMap();
    for (final Map row in resultSet) {
      String album = row['album'].toString();
      String key = albums.keys.toList().firstWhere(
        (k) => k.toLowerCase() == album.toLowerCase(),
        orElse: () {
          albums[album] = [];
          return album;
        },
      );
      albums[key]!.add(_dehydrateTrack(row));
    }

    // now sort albums
    List<String> titles = albums.keys.toList();
    if (ordering != AlbumOrdering.none) {
      titles.sort((a, b) {
        if (ordering == AlbumOrdering.chrono) {
          int y1 = albums[a]!.first.tags?.year ?? 0;
          int y2 = albums[b]!.first.tags?.year ?? 0;
          return (y1 != y2) ? y1.compareTo(y2) : a.compareTo(b);
        } else if (ordering == AlbumOrdering.alpha) {
          return a.compareTo(b);
        } else {
          return 0;
        }
      });
    }

    // and tracks
    for (TrackList tracks in albums.values) {
      tracks.sort((a, b) {
        if (a.safeTags.volumeIndex == b.safeTags.volumeIndex) {
          if (a.safeTags.trackIndex == b.safeTags.trackIndex) {
            return a.displayTitle.compareTo(b.displayTitle);
          } else {
            return a.safeTags.trackIndex.compareTo(b.safeTags.trackIndex);
          }
        } else {
          return a.safeTags.volumeIndex.compareTo(b.safeTags.volumeIndex);
        }
      });
    }

    // now rebuild the list
    return LinkedHashMap.fromIterable(
      titles,
      key: (t) => t,
      value: (t) => albums[t]!,
    );
  }

  Track _dehydrateTrack(Map row) {
    return Track(
      id: row['id'],
      filename: row['filename'],
      filesize: row['filesize'],
      importedAt: row['imported_at'],
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
        volumeCount: row['volume_count'],
        trackIndex: row['track_index'],
        trackCount: row['track_count'],
        duration: row['duration'],
        numChannels: row['num_channels'],
        sampleRate: row['sample_rate'],
        bitsPerSample: row['bits_per_sample'],
        bitrate: row['bitrate'],
      ),
    );
  }

  Future<List<String>> _allColumnValues(String column) async {
    final List<Map> resultSet = await _database!.rawQuery(
        'SELECT DISTINCT $column FROM tracks ORDER BY LOWER($column)');
    return resultSet.map((r) => r[column].toString()).toList();
  }

  void _invalidateCache() {
    _cacheMutex.protect(() async => _cachedInfo = null);
  }
}
