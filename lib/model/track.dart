import 'dart:collection';
import 'dart:io';
import 'dart:math';

import 'package:path/path.dart' as p;
import 'package:taglib_ffi/taglib_ffi.dart';

import 'editable_tags.dart';

enum Format { notAudio, mp3, flac, alac, vorbis, aac }

extension FormatEx on String {
  Format toFormat() => Format.values.firstWhere((d) => d.toString() == this);
}

typedef TrackList = List<Track>;
typedef AlbumList = LinkedHashMap<String, TrackList>;

extension TrackListExt on TrackList {
  int get duration =>
      fold(0, (duration, track) => duration + track.safeTags.duration);
}

extension AlumbListExt on AlbumList {
  TrackList get allTracks =>
      values.fold([], (all, tracks) => [...all, ...tracks]);
}

class Track {
  static const String kArtistsHome = '_home_';
  static const String kArtistCompilations = '_compilations_';

  int id;
  String filename;
  Format format = Format.notAudio;
  int importedAt = 0;
  int lastModified = 0;
  int filesize = 0;

  Tags? tags;
  String? lyrics;

  factory Track.parse(String filename, TagLib? tagLib) {
    File f = File(filename);
    FileStat fs = f.statSync();
    return Track(
      filename: filename,
      filesize: fs.size,
      lastModified: max(0 /*fs.changed.millisecondsSinceEpoch*/,
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
    this.id = 0,
    this.importedAt = 0,
    this.tags,
  });

  Future<void> loadLyrics(TagLib tagLib) async {
    lyrics = await tagLib.getLyrics(filename);
  }

  String get formatString {
    return getFormatString(format);
  }

  String get channelsString {
    if (safeTags.numChannels == 0) return 'Unknown';
    if (safeTags.numChannels == 1) return 'Mono';
    if (safeTags.numChannels == 2) return 'Stereo';
    if (safeTags.numChannels == 3) return 'Multichannel 2.1';
    if (safeTags.numChannels == 5) return 'Multichannel 5.0';
    if (safeTags.numChannels == 6) return 'Multichannel 5.1';
    if (safeTags.numChannels == 8) return 'Multichannel 7.1';
    return '${safeTags.numChannels} channels';
  }

  Tags get safeTags {
    return tags ?? Tags();
  }

  EditableTags get editableTags {
    return tags == null ? EditableTags() : EditableTags.fromTags(tags!);
  }

  String get companionLrcFilepath {
    return p.setExtension(filename, '.lrc');
  }

  static bool isTrack(String filename) {
    // skip ._ files
    if (p.basename(filename).startsWith('._')) return false;
    return getFormat(filename) != Format.notAudio;
  }

  static Format getFormat(String filename) {
    String extension = p.extension(filename).toLowerCase();
    switch (extension) {
      case '.mp3':
        return Format.mp3;
      case '.m4a':
        return Format.alac;
      case '.flac':
        return Format.flac;
      case '.ogg':
        return Format.vorbis;
      default:
        return Format.notAudio;
    }
  }

  static String getFormatString(
    Format format, {
    bool shortDescription = false,
  }) {
    switch (format) {
      case Format.notAudio:
        return 'Unknown';
      case Format.mp3:
        return shortDescription ? 'MP3' : 'MPEG-1, Layer 3';
      case Format.aac:
        return shortDescription ? 'AAC' : 'Advanced Audio Codec';
      case Format.vorbis:
        return shortDescription ? 'Vorbis' : 'Ogg Vorbis';
      case Format.flac:
        return shortDescription ? 'FLAC' : 'Free Lossless Audio Codec';
      case Format.alac:
        return shortDescription ? 'ALAC' : 'Apple Lossless Audio Codec';
    }
  }
}
