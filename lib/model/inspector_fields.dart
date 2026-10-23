import 'track.dart';

/// A tag value shared by every selected track, or "mixed" when they disagree.
class InspectorField {
  /// null when mixed, empty when every track agrees on "nothing".
  final String? value;
  const InspectorField(this.value);

  bool get isMixed => value == null;
  bool get isEmpty => value != null && value!.isEmpty;

  static InspectorField of(List<Track> tracks, String Function(Track) get) {
    if (tracks.isEmpty) return const InspectorField('');
    final String first = get(tracks.first);
    for (final Track track in tracks) {
      if (get(track) != first) return const InspectorField(null);
    }
    return InspectorField(first);
  }
}

/// What the inspector shows for the current selection.
class InspectorFields {
  final int count;
  final InspectorField title;
  final InspectorField album;
  final InspectorField albumArtist;
  final InspectorField genre;
  final InspectorField year;
  final InspectorField trackNumber;

  /// Every selected track belongs to the same album (so one cover fits all).
  final bool sameAlbum;

  const InspectorFields._({
    required this.count,
    required this.title,
    required this.album,
    required this.albumArtist,
    required this.genre,
    required this.year,
    required this.trackNumber,
    required this.sameAlbum,
  });

  factory InspectorFields.from(List<Track> tracks) {
    String number(int n) => n == 0 ? '' : '$n';
    final InspectorField album =
        InspectorField.of(tracks, (t) => t.safeTags.album);
    final InspectorField artist =
        InspectorField.of(tracks, (t) => t.safeTags.artist);
    return InspectorFields._(
      count: tracks.length,
      title: InspectorField.of(tracks, (t) => t.safeTags.title),
      album: album,
      albumArtist: artist,
      genre: InspectorField.of(tracks, (t) => t.safeTags.genre),
      year: InspectorField.of(tracks, (t) => number(t.safeTags.year)),
      trackNumber:
          InspectorField.of(tracks, (t) => number(t.safeTags.trackIndex)),
      sameAlbum: !album.isMixed && !artist.isMixed,
    );
  }

  bool get isEmpty => count == 0;

  /// Cleaning up titles only makes sense across several tracks.
  bool get canCleanupTitles => count > 1;

  /// Revealing in Finder is a single-file action.
  bool get canReveal => count == 1;
}
