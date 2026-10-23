import '../utils/track_utils.dart';
import 'library_health.dart';
import 'track.dart';

/// An album as listed in a results or review screen.
class AlbumGroup {
  /// Album artist, or [Track.kArtistCompilations].
  final String artist;
  final String album;
  final TrackList tracks;
  const AlbumGroup(this.artist, this.album, this.tracks);
}

class LibraryQuery {
  /// Tracks of an album in disc / track / title order.
  static int compareTracks(Track a, Track b) {
    if (a.safeTags.volumeIndex != b.safeTags.volumeIndex) {
      return a.safeTags.volumeIndex.compareTo(b.safeTags.volumeIndex);
    }
    if (a.safeTags.trackIndex != b.safeTags.trackIndex) {
      return a.safeTags.trackIndex.compareTo(b.safeTags.trackIndex);
    }
    return a.displayTitle.compareTo(b.displayTitle);
  }

  /// Groups tracks by album (compilations together), artists A to Z, then each
  /// artist's albums by year.
  static List<AlbumGroup> groupAlbums(TrackList tracks) {
    final Map<String, TrackList> byAlbum = {};
    final Map<String, String> artistOf = {};
    final Map<String, String> albumOf = {};
    for (final Track track in tracks) {
      final bool compilation = track.safeTags.compilation;
      final String key = LibraryHealth.albumKey(
        track.safeTags.artist,
        track.safeTags.album,
        compilation,
      );
      (byAlbum[key] ??= []).add(track);
      artistOf.putIfAbsent(
        key,
        () => compilation ? Track.kArtistCompilations : track.safeTags.artist,
      );
      albumOf.putIfAbsent(key, () => track.safeTags.album);
    }

    final List<AlbumGroup> groups = byAlbum.entries.map((e) {
      final TrackList sorted = [...e.value]..sort(compareTracks);
      return AlbumGroup(artistOf[e.key]!, albumOf[e.key]!, sorted);
    }).toList();

    groups.sort((a, b) {
      final int byArtist = _sortable(a.artist).compareTo(_sortable(b.artist));
      if (byArtist != 0) return byArtist;
      final int byYear =
          a.tracks.first.safeTags.year.compareTo(b.tracks.first.safeTags.year);
      return byYear != 0 ? byYear : a.album.compareTo(b.album);
    });
    return groups;
  }

  /// Exactly the tracks that need review for [kind].
  static TrackList reviewTracks(ReviewKind kind, TrackList all) {
    switch (kind) {
      case ReviewKind.noYear:
        return all.where((t) => t.safeTags.year == 0).toList();
      case ReviewKind.mixedGenres:
        final Set<String> mixed = LibraryHealth.mixedGenreAlbumKeys(
          all.map(HealthRow.fromTrack).toList(),
        );
        return all
            .where((t) => mixed.contains(HealthRow.fromTrack(t).albumKey))
            .toList();
    }
  }

  /// Words typed in the search box, lower-cased and without the empties.
  static List<String> tokens(String query) {
    return query
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
  }

  /// Every word must appear in the title, album, artist or performer.
  static bool matches(Track track, List<String> tokens) {
    if (tokens.isEmpty) return false;
    final String haystack = [
      track.safeTags.title,
      track.safeTags.album,
      track.safeTags.artist,
      track.safeTags.performer,
    ].join('\u0000').toLowerCase();
    return tokens.every(haystack.contains);
  }

  static String _sortable(String artist) {
    if (artist == Track.kArtistCompilations) return '';
    return TrackUtils.getSortableArtist(artist).toLowerCase();
  }
}
