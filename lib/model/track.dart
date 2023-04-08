import 'dart:io';
import 'dart:math';
import 'package:path/path.dart' as p;
import 'package:taglib_ffi/taglib_ffi.dart';

class Track {
  final String filename;
  int lastModified = 0;
  int size = 0;
  Tags? _tags;

  static bool isTrack(String filename) {
    String extension = p.extension(filename).toLowerCase();
    return ['.flac', '.m4a', '.mp3', '.ogg', '.wav'].contains(extension);
  }

  Tags get tags {
    return _tags ?? Tags();
  }

  Track(this.filename) {
    File f = File(filename);
    FileStat fs = f.statSync();
    lastModified = max(
        fs.changed.millisecondsSinceEpoch, fs.modified.millisecondsSinceEpoch);
    size = fs.size;
  }

  bool parse(TagLib tagLib) {
    _tags = tagLib.getAudioTags(filename);
    return _tags?.valid ?? false;
  }
}
