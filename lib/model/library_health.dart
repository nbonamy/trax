import 'track.dart';

/// The few tag facts needed to judge how tidy a library is.
class HealthRow {
  final String artist;
  final String album;
  final String genre;
  final int year;
  final bool lossy;
  final int bitrate;
  final bool compilation;

  const HealthRow({
    required this.artist,
    required this.album,
    required this.genre,
    required this.year,
    required this.lossy,
    required this.bitrate,
    this.compilation = false,
  });
}

/// Where to send the user to look at a problem.
class HealthTarget {
  final String artist;
  final String album;
  const HealthTarget(this.artist, this.album);
}

class LibraryHealth {
  static const int kMinBitrate = 192;

  final int totalTracks;
  final int lowBitrateTracks;
  final int mixedGenreAlbums;
  final int noYearTracks;
  final int affectedTracks;
  final HealthTarget? firstLowBitrate;
  final HealthTarget? firstMixedGenre;
  final HealthTarget? firstNoYear;

  const LibraryHealth({
    this.totalTracks = 0,
    this.lowBitrateTracks = 0,
    this.mixedGenreAlbums = 0,
    this.noYearTracks = 0,
    this.affectedTracks = 0,
    this.firstLowBitrate,
    this.firstMixedGenre,
    this.firstNoYear,
  });

  int get issueCount =>
      (lowBitrateTracks > 0 ? 1 : 0) +
      (mixedGenreAlbums > 0 ? 1 : 0) +
      (noYearTracks > 0 ? 1 : 0);

  bool get isTidy => issueCount == 0;

  /// Share of tracks that have none of the problems, as a 0..100 percentage.
  /// An empty library has nothing to tidy.
  int get score {
    if (totalTracks == 0) return 100;
    final double clean = 1 - affectedTracks / totalTracks;
    return (clean * 100).floor().clamp(0, 100);
  }

  factory LibraryHealth.compute(List<HealthRow> rows) {
    int total = 0;
    int lowBitrate = 0;
    int noYear = 0;
    HealthTarget? firstLow;
    HealthTarget? firstNoYear;

    // album key -> genres seen and tracks in it
    final Map<String, Set<String>> genres = {};
    final Map<String, int> albumTracks = {};
    final Map<String, HealthTarget> albumTarget = {};

    for (final HealthRow row in rows) {
      total++;
      final String key =
          '${row.artist.toLowerCase()}\u0000${row.album.toLowerCase()}';
      albumTracks[key] = (albumTracks[key] ?? 0) + 1;
      albumTarget.putIfAbsent(
        key,
        () => HealthTarget(
          row.compilation ? Track.kArtistCompilations : row.artist,
          row.album,
        ),
      );

      final String genre = row.genre.trim().toLowerCase();
      // compilations are expected to mix genres
      if (genre.isNotEmpty && !row.compilation) {
        (genres[key] ??= {}).add(genre);
      }

      if (row.lossy && row.bitrate > 0 && row.bitrate < kMinBitrate) {
        lowBitrate++;
        firstLow ??= albumTarget[key];
      }
      if (row.year == 0) {
        noYear++;
        firstNoYear ??= albumTarget[key];
      }
    }

    final List<String> mixed = genres.entries
        .where((e) => e.value.length > 1)
        .map((e) => e.key)
        .toList();

    // tracks touched by at least one issue
    int affected = 0;
    final Set<String> affectedAlbums = {...mixed};
    for (final HealthRow row in rows) {
      final String key =
          '${row.artist.toLowerCase()}\u0000${row.album.toLowerCase()}';
      final bool low =
          row.lossy && row.bitrate > 0 && row.bitrate < kMinBitrate;
      if (low || row.year == 0 || affectedAlbums.contains(key)) affected++;
    }

    return LibraryHealth(
      totalTracks: total,
      lowBitrateTracks: lowBitrate,
      mixedGenreAlbums: mixed.length,
      noYearTracks: noYear,
      affectedTracks: affected,
      firstLowBitrate: firstLow,
      firstMixedGenre: mixed.isEmpty ? null : albumTarget[mixed.first],
      firstNoYear: firstNoYear,
    );
  }
}
