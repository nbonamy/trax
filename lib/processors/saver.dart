import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sanitize_filename/sanitize_filename.dart';
import 'package:taglib_ffi/taglib_ffi.dart';

import '../data/database.dart';
import '../model/editable_tags.dart';
import '../model/preferences.dart';
import '../model/track.dart';
import '../utils/artwork_provider.dart';
import '../utils/consts.dart';
import '../utils/path_utils.dart';
import '../utils/track_utils.dart';

enum EditorMode { edit, import, editOnly }

enum MetadataAction { loading, untouched, updated, deleted }

class TagSaver {
  static const String kMixedValueStr = '__mixed__';
  static const String kClearedValueStr = '__cleared__';
  static const int kMixedValueInt = -999;
  static const int kClearedValueInt = -888;

  final TagLib tagLib;
  final TraxDatabase database;
  final PreferencesBase preferences;

  TagSaver(this.tagLib, this.database, this.preferences);

  Future<bool> update(
    Preferences preferences,
    ArtworkProvider artworkProvider,
    EditorMode editorMode,
    Track track,
    Tags updatedTags,
    Uint8List? updatedArtwork,
    String? updatedLyrics, {
    bool notify = true,
  }) async {
    try {
      // track
      bool updated = false;

      // copy before?
      if (editorMode == EditorMode.import &&
          preferences.importFileOp == ImportFileOp.copy) {
        String tempFilePath =
            SystemPath.temporaryFile(extension: p.extension(track.filename));
        await File(track.filename).copy(tempFilePath);
        track.filename = tempFilePath;
      }

      // tag update?
      bool tagsUpdated = updatedTags.equals(track.tags) == false;
      if (editorMode == EditorMode.import || tagsUpdated) {
        // now update
        if (tagsUpdated) {
          if (tagLib.setAudioTags(track.filename, updatedTags) == false) {
            return false;
          }
          track.tags = EditableTags.safeFromTags(updatedTags);
        }

        // move?
        if (editorMode != EditorMode.editOnly) {
          String fullpath = targetFilename(
            track,
            preferences.keepMediaOrganized,
          );
          bool moved = await _moveTrack(track, fullpath);
          if (moved == false) {
            // save because move has not
            database.insert(track, notify: false);
          }
        }

        // track
        updated = true;
      }

      // update artwork
      if (updatedArtwork != null) {
        tagLib.setArtwork(track.filename, updatedArtwork);
        artworkProvider.evict(track);
        updated = true;
      }

      // update lyrics
      if (updatedLyrics != null) {
        switch (preferences.lyricsSaveMode) {
          case LyricsSaveMode.tag:
            tagLib.setLyrics(track.filename, updatedLyrics);
            break;
          case LyricsSaveMode.lrc:
            File f = File(track.companionLrcFilepath);
            if (updatedLyrics.isEmpty) {
              if (await f.exists()) {
                await f.delete();
              }
            } else {
              await f.writeAsString(updatedLyrics);
            }
            break;
        }
        updated = true;
      }

      // done
      if (notify && updated && editorMode != EditorMode.editOnly) {
        database.notify();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  void mergeTags(Tags initialTags, EditableTags updatedTags) {
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
    initialTags.compilation =
        _mergeTagBool(initialTags.compilation, updatedTags.editedCompilation);
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

  bool _mergeTagBool(bool initialValue, bool? updatedValue) {
    if (updatedValue == null) return initialValue;
    return updatedValue;
  }

  Future<bool> _moveTrack(
    Track track,
    String fullpath, {
    notify = false,
  }) async {
    if (fullpath == track.filename) return false;
    String currpath = track.filename;
    database.delete(currpath, notify: false);
    await Directory(p.dirname(fullpath)).create(recursive: true);
    await File(currpath).rename(fullpath);
    track.filename = fullpath;
    database.insert(track, notify: notify);
    return true;
  }

  @visibleForTesting
  String targetFilename(Track track, bool keepMediaOrganized) {
    // start with path
    String filepath = preferences.musicFolder;
    if (keepMediaOrganized) {
      if (track.safeTags.compilation) {
        filepath =
            p.join(filepath, sanitizePathComponent(Consts.compilationsFolder));
        filepath = p.join(filepath, sanitizePathComponent(track.displayAlbum));
      } else {
        filepath = p.join(filepath, sanitizePathComponent(track.displayArtist));
        filepath = p.join(filepath, sanitizePathComponent(track.displayAlbum));
      }
    }

    // filename: try to mimick what Apple Music does
    // start with volumeIndex if relevant followed by -
    // then trackIndex if relevant followed by space
    // then track title
    // then extension
    String filename = '';
    if (track.safeTags.volumeIndex != 0) {
      filename = '$filename${track.safeTags.volumeIndex}-';
    }
    if (track.safeTags.trackIndex != 0) {
      filename =
          '$filename${track.safeTags.trackIndex.toString().padLeft(2, '0')} ';
    }
    {
      filename = '$filename${sanitizePathComponent(track.displayTitle)}';
    }
    {
      filename = '$filename${p.extension(track.filename)}';
    }

    // now concat
    String fullpath = p.join(filepath, filename);
    return fullpath;
  }

  @visibleForTesting
  String sanitizePathComponent(String pathComponent) {
    return sanitizeFilename(pathComponent, replacement: '_');
  }
}
