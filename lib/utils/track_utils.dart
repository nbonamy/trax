import '../model/track.dart';

extension TrackUtils on Track {
  static final List<String> _prefixes = ['The', 'Le', 'La', 'Les'];

  String get displayTitle {
    return getDisplayTitle(safeTags.title);
  }

  String get displayAlbum {
    return getDisplayAlbum(safeTags.title);
  }

  String get displayArtist {
    return getDisplayArtist(safeTags.title);
  }

  String get displayGenre {
    return getDisplayTitle(safeTags.title);
  }

  String get displayTrackIndex {
    return getDisplayTrackIndex(safeTags.trackIndex);
  }

  int get volumeIndex {
    return safeTags.volumeIndex;
  }

  static String getDisplayTitle(String title) {
    return _defaultValue(title, 'Unknown title');
  }

  static String getDisplayAlbum(String album) {
    return _defaultValue(album, 'Unknown album');
  }

  static String getDisplayArtist(String artist) {
    if (artist == Track.kArtistCompilations) {
      return 'Compilations';
    } else {
      return _defaultValue(artist, 'Unknown artist');
    }
  }

  static String getDisplayTrackIndex(int index) {
    return index == 0 ? '' : index.toString();
  }

  static String getSortableArtist(String artist) {
    artist = getDisplayArtist(artist);
    for (String prefix in _prefixes) {
      if (artist.startsWith('$prefix ')) {
        return artist.substring(prefix.length + 1);
      }
    }
    return artist;
  }

  static String getDisplayGenre(String genre) {
    return _defaultValue(genre, 'Unknown genre');
  }

  static String _defaultValue(dynamic value, String defaultValue) {
    if (value == null) return defaultValue;
    if (value is String && value.isEmpty) return defaultValue;
    return value;
  }
}
