import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as p;
import 'package:taglib_ffi/taglib_ffi.dart';

import '../data/database.dart';
import '../model/track.dart';
import '../utils/track_utils.dart';

enum ArtworkAction {
  untouched,
  updated,
  deleted,
}

class TagSaver {
  static const String kMixedValueStr = '__mixed__';
  static const String kClearedValueStr = '__cleared__';
  static const int kMixedValueInt = -999;
  static const int kClearedValueInt = -888;

  final TagLib tagLib;
  final TraxDatabase database;
  final String rootFolder;

  TagSaver(this.tagLib, this.database, this.rootFolder);

  Future<bool> update(
    Track track,
    Tags updatedTags,
    ArtworkAction artworkAction,
    Uint8List? artworkBytes,
  ) async {
    // track
    bool updated = false;

    // tag update?
    if (updatedTags.equals(track.tags) == false) {
      // now update
      tagLib.setAudioTags(track.filename, updatedTags);
      track.tags = updatedTags;
      database.insert(track, notify: false);

      // move?
      String fullpath = _filename(track);
      await _moveTrack(track, fullpath);

      // track
      updated = true;
    }

    // update artwork
    if (artworkAction == ArtworkAction.deleted) {
      tagLib.setArtwork(track.filename, Uint8List(0));
      updated = true;
    } else if (artworkAction == ArtworkAction.updated) {
      tagLib.setArtwork(track.filename, artworkBytes!);
      updated = true;
    }

    // done
    if (updated) {
      database.notify();
    }
    return true;
  }

  void mergeTags(Tags initialTags, Tags updatedTags) {
    initialTags.title = _mergeTagStr(initialTags.title, updatedTags.title);
    initialTags.album = _mergeTagStr(initialTags.album, updatedTags.album);
    initialTags.artist = _mergeTagStr(initialTags.artist, updatedTags.artist);
    initialTags.performer =
        _mergeTagStr(initialTags.performer, updatedTags.performer);
    initialTags.composer =
        _mergeTagStr(initialTags.composer, updatedTags.composer);
    initialTags.genre = _mergeTagStr(initialTags.genre, updatedTags.genre);
    initialTags.copyright =
        _mergeTagStr(initialTags.copyright, updatedTags.copyright);
    initialTags.comment =
        _mergeTagStr(initialTags.comment, updatedTags.comment);
    initialTags.year = _mergeTagInt(initialTags.year, updatedTags.year);
    initialTags.volumeIndex =
        _mergeTagInt(initialTags.volumeIndex, updatedTags.volumeIndex);
    initialTags.volumeCount =
        _mergeTagInt(initialTags.volumeCount, updatedTags.volumeCount);
    initialTags.trackIndex =
        _mergeTagInt(initialTags.trackIndex, updatedTags.trackIndex);
    initialTags.trackCount =
        _mergeTagInt(initialTags.trackCount, updatedTags.trackCount);
  }

  String _mergeTagStr(String initialValue, String updatedValue) {
    if (updatedValue == TagSaver.kClearedValueStr) return '';
    if (updatedValue == TagSaver.kMixedValueStr) return initialValue;
    return updatedValue;
  }

  int _mergeTagInt(int initialValue, int updatedValue) {
    if (updatedValue == TagSaver.kClearedValueInt) return 0;
    if (updatedValue == TagSaver.kMixedValueInt) return initialValue;
    return updatedValue;
  }

  Future<void> _moveTrack(Track track, String fullpath,
      {notify = false}) async {
    if (fullpath != track.filename) {
      String currpath = track.filename;
      database.delete(currpath, notify: false);
      await Directory(p.dirname(fullpath)).create(recursive: true);
      await File(currpath).rename(fullpath);
      track.filename = fullpath;
      database.insert(track, notify: notify);
    }
  }

  String _filename(Track track) {
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
