import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../model/track.dart';

extension TrackUtils on Track {
  static final List<String> _prefixes = ['The', 'Le', 'La', 'Les'];

  static AppLocalizations? _t;
  static initLocalization(AppLocalizations? t) {
    _t = t;
  }

  String get displayTitle {
    return getDisplayTitle(safeTags.title);
  }

  String get displayAlbum {
    return getDisplayAlbum(safeTags.album);
  }

  String get displayArtist {
    return getDisplayArtist(safeTags.artist);
  }

  String get displayAlbumArtist {
    return safeTags.compilation ? 'Compilation' : displayArtist;
  }

  String get displayGenre {
    return getDisplayGenre(safeTags.genre);
  }

  String get displayYear {
    return getDisplayInteger(safeTags.year);
  }

  String get displayVolumeIndex {
    return getDisplayInteger(safeTags.volumeIndex);
  }

  String get displayTrackIndex {
    return getDisplayInteger(safeTags.trackIndex);
  }

  int get volumeIndex {
    return safeTags.volumeIndex;
  }

  static String getDisplayTitle(String title) {
    return _defaultValue(title, _t?.unknownTitle);
  }

  static String getDisplayAlbum(String album) {
    return _defaultValue(album, _t?.unknownAlbum);
  }

  static String getDisplayArtist(String artist) {
    if (artist == Track.kArtistsHome) {
      return _t?.home ?? artist;
    } else if (artist == Track.kArtistCompilations) {
      return _t?.compilations ?? artist;
    } else {
      return _defaultValue(artist, _t?.unknownArtist);
    }
  }

  static String getDisplayGenre(String genre) {
    return _defaultValue(genre, _t?.unknownGenre);
  }

  static String getDisplayInteger(int value) {
    return value == 0 ? '' : value.toString();
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

  static String _defaultValue(dynamic value, String? defaultValue) {
    if (defaultValue == null) return value;
    if (value == null) return defaultValue;
    if (value is String && value.isEmpty) return defaultValue;
    return value;
  }
}
