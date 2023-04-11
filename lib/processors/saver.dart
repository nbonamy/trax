import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as p;
import 'package:taglib_ffi/taglib_ffi.dart';
import 'package:trax/utils/track_utils.dart';

import '../data/database.dart';
import '../model/track.dart';

class TagSaver {
  final TagLib tagLib;
  final TraxDatabase database;
  final String rootFolder;

  TagSaver(this.tagLib, this.database, this.rootFolder);

  Future<bool> update(
      Track track, Tags? updatedTags, Uint8List? artwork) async {
    // basic checks
    if (updatedTags == null) return false;
    if (updatedTags.equals(track.tags)) return true;

    // now update
    tagLib.setAudioTags(track.filename, updatedTags);
    track.tags = updatedTags;
    database.insert(track, notify: false);

    // move?
    String fullpath = filename(track);
    await moveTrack(track, fullpath);

    // done
    database.notify();
    return true;
  }

  Future<void> moveTrack(Track track, String fullpath, {notify = false}) async {
    if (fullpath != track.filename) {
      String currpath = track.filename;
      database.delete(currpath, notify: false);
      await Directory(p.dirname(fullpath)).create(recursive: true);
      await File(currpath).rename(fullpath);
      track.filename = fullpath;
      database.insert(track, notify: notify);
    }
  }

  String filename(Track track) {
    String filepath = rootFolder;
    filepath = p.join(filepath, track.displayArtist);
    filepath = p.join(filepath, track.displayAlbum);
    String filename = track.displayTrackIndex;
    if (filename.isNotEmpty) filename = '$filename. ';
    filename = '$filename${track.displayTitle}${p.extension(track.filename)}';
    String fullpath = p.join(filepath, filename);
    return fullpath;
  }
}
