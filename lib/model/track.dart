import 'dart:io';
import 'dart:math';
import 'package:path/path.dart' as p;
import 'package:taglib_ffi/taglib_ffi.dart';

enum Format { notAudio, mp3, flac, mp4, vorbis }

extension FormatEx on String {
  Format toFormat() => Format.values.firstWhere((d) => d.toString() == this);
}

class Track {
  static const String kArtistCompilations = '_compilations_';

  final String filename;
  Format format = Format.notAudio;
  int lastModified = 0;
  int filesize = 0;
  Tags? tags;

  Tags get safeTags {
    return tags ?? Tags();
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


}
