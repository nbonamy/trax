import 'dart:io';
import 'dart:math';
import 'package:path/path.dart' as p;
import 'package:taglib_ffi/taglib_ffi.dart';

enum Format { notAudio, mp3, flac, mp4, vorbis }

extension FormatEx on String {
  Format toFormat() => Format.values.firstWhere((d) => d.toString() == this);
}

class Track {
  final String filename;
  Format format = Format.notAudio;
  int lastModified = 0;
  int filesize = 0;
  Tags? tags;

  Tags get safeTags {
    return tags ?? Tags();
  }

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

  int get volumeIndex {
    return safeTags.volumeIndex;
  }

  int get trackIndex {
    return safeTags.trackIndex;
  }

  factory Track.parse(String filename, TagLib? tagLib) {
    File f = File(filename);
    FileStat fs = f.statSync();
    return Track(
      filename: filename,
      filesize: fs.size,
      lastModified: max(fs.changed.millisecondsSinceEpoch,
          fs.modified.millisecondsSinceEpoch),
      format: getFormat(filename),
      tags: tagLib?.getAudioTags(filename),
    );
  }

  Track({
    required this.filename,
    required this.filesize,
    required this.lastModified,
    required this.format,
    this.tags,
  });

  static bool isTrack(String filename) {
    return getFormat(filename) != Format.notAudio;
  }

  static Format getFormat(String filename) {
    String extension = p.extension(filename).toLowerCase();
    switch (extension) {
      case '.mp3':
        return Format.mp3;
      case '.m4a':
        return Format.mp4;
      case '.flac':
        return Format.flac;
      case '.ogg':
        return Format.vorbis;
      default:
        return Format.notAudio;
    }
  }

  static String getDisplayTitle(String title) {
    return _defaultValue(title, 'Unknown title');
  }

  static String getDisplayAlbum(String album) {
    return _defaultValue(album, 'Unknown album');
  }

  static String getDisplayArtist(String artist) {
    return _defaultValue(artist, 'Unknown artist');
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
