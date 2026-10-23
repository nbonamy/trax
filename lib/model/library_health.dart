import 'track.dart';

/// What a review screen shows: only the data that has the problem.
enum ReviewKind { mixedGenres, noYear }

/// The few tag facts needed to judge how tidy a library is.
class HealthRow {
  final String artist;
  final String album;
  final String genre;
  final int year;
  final bool compilation;

  const HealthRow({
    required this.artist,
    required this.album,
    required this.genre,
    required this.year,
    this.compilation = false,
  });

  factory HealthRow.fromTrack(Track track) {
    return HealthRow(
      artist: track.safeTags.artist,
      album: track.safeTags.album,
      genre: track.safeTags.genre,
      year: track.safeTags.year,
      compilation: track.safeTags.compilation,
    );
  }

  String get albumKey => LibraryHealth.albumKey(artist, album, compilation);
}

class LibraryHealth {
  final int totalTracks;
  final int mixedGenreAlbums;
  final int noYearTracks;
  final int affectedTracks;

  const LibraryHealth({
    this.totalTracks = 0,
    this.mixedGenreAlbums = 0,
    this.noYearTracks = 0,
    this.affectedTracks = 0,
  });

  int get issueCount =>
      (mixedGenreAlbums > 0 ? 1 : 0) + (noYearTracks > 0 ? 1 : 0);

  bool get isTidy => issueCount == 0;

  /// Share of tracks that have none of the problems, as a 0..100 percentage.
  /// An empty library has nothing to tidy.
  int get score {
    if (totalTracks == 0) return 100;
    final double clean = 1 - affectedTracks / totalTracks;
    return (clean * 100).floor().clamp(0, 100);
  }

  /// Same album, same key: case does not matter, compilations are one bucket
  /// per album title whoever the track artist is.
  static String albumKey(String artist, String album, bool compilation) {
    final String who = compilation ? '\u0001' : artist.toLowerCase();
    return '$who\u0000${album.toLowerCase()}';
  }

  /// Albums whose tracks disagree on genre. Empty genres are not a genre, and
  /// compilations are expected to mix them.
  static Set<String> mixedGenreAlbumKeys(List<HealthRow> rows) {
    final Map<String, Set<String>> genres = {};
    for (final HealthRow row in rows) {
      final String genre = row.genre.trim().toLowerCase();
      if (genre.isEmpty || row.compilation) continue;
      (genres[row.albumKey] ??= {}).add(genre);
    }
    return genres.entries
        .where((e) => e.value.length > 1)
        .map((e) => e.key)
        .toSet();
  }

  factory LibraryHealth.compute(List<HealthRow> rows) {
    final Set<String> mixed = mixedGenreAlbumKeys(rows);
    int noYear = 0;
    int affected = 0;
    for (final HealthRow row in rows) {
      final bool missingYear = row.year == 0;
      if (missingYear) noYear++;
      if (missingYear || mixed.contains(row.albumKey)) affected++;
    }
    return LibraryHealth(
      totalTracks: rows.length,
      mixedGenreAlbums: mixed.length,
      noYearTracks: noYear,
      affectedTracks: affected,
    );
  }
}
