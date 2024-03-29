import 'dart:io';
import 'dart:typed_data';

import 'package:audiotranscode_ffi/audiotranscode_ffi.dart';
import 'package:path/path.dart' as p;
import 'package:taglib_ffi/taglib_ffi.dart';

import '../data/database.dart';
import '../model/track.dart';

class AudioSettingBitrate {
  final String name;
  final int bitrate;
  AudioSettingBitrate(this.name, this.bitrate);
}

class AudioSettingBitsPerSample {
  final String name;
  final int bitsPerSample;
  AudioSettingBitsPerSample(this.name, this.bitsPerSample);
}

class AudioSettingSampleRate {
  final String name;
  final int sampleRate;
  AudioSettingSampleRate(this.name, this.sampleRate);
}

class TranscodingSettings {
  int bitrate;
  int bitsPerSample;
  int sampleRate;
  TranscodingSettings(this.bitrate, this.bitsPerSample, this.sampleRate);
}

class AudioTranscoder {
  static final List<AudioSettingBitrate> kSettingsMp3Bitrate = [
    AudioSettingBitrate('128 kbps', 128000),
    AudioSettingBitrate('160 kbps', 160000),
    AudioSettingBitrate('192 kbps', 192000),
    AudioSettingBitrate('320 kbps', 320000),
  ];

  static final List<AudioSettingBitrate> kSettingsAacBitrate = [
    AudioSettingBitrate('128 kbps (VBR)', 128000),
    AudioSettingBitrate('192 kbps (VBR)', 192000),
    AudioSettingBitrate('256 kbps (VBR)', 256000),
  ];

  static final List<AudioSettingBitsPerSample> kSettingsFlacBitsPerSample = [
    AudioSettingBitsPerSample('16 bits', 16),
    AudioSettingBitsPerSample('24 bits', 24),
  ];

  static final List<AudioSettingBitsPerSample> kSettingsAlacBitsPerSample = [
    AudioSettingBitsPerSample('16 bits', 16),
    AudioSettingBitsPerSample('24 bits', 24),
  ];

  static final List<AudioSettingSampleRate> kSettingsSampleRate = [
    AudioSettingSampleRate('44.1 kHz', 44100),
    AudioSettingSampleRate('48 kHz', 48000),
    AudioSettingSampleRate('88.2 kHz', 88200),
    AudioSettingSampleRate('96 kHz', 96000),
    AudioSettingSampleRate('176.4 kHz', 176400),
    AudioSettingSampleRate('192 kHz', 192000),
  ];

  final TagLib tagLib = TagLib();
  final TraxDatabase database;

  AudioTranscoder({
    required this.database,
  });

  Future<bool> transcode(
    String src,
    String? destinationFolder,
    TranscodeFormat transcodeFormat,
    int bitrate,
    int bitsPerSample,
    int sampleRate,
    bool deleteSourceFile,
    bool addToLibrary,
  ) async {
    // init
    bool rc = false;

    // save metadata
    Tags tags = tagLib.getAudioTags(src);
    Uint8List? artwork = await tagLib.getArtworkBytes(src);
    String? lyrics = await tagLib.getLyrics(src);
    int importedAt = (await database.getTrackByFilename(src))?.importedAt ?? 0;

    // manage potential conflict
    bool filenameConflict = false;
    String dst = p.join(destinationFolder ?? p.dirname(src), p.basename(src));
    dst = p.setExtension(dst, _targetExtension(transcodeFormat));
    if (src == dst) {
      filenameConflict = true;
      dst = p.setExtension(dst, '.tmp${_targetExtension(transcodeFormat)}');
    }

    // now transcode
    if (transcodeFormat == TranscodeFormat.mp3) {
      rc = await transcodeMp3(
        src,
        dst,
        bitrate,
      );
    } else if (transcodeFormat == TranscodeFormat.flac) {
      rc = await transcodeFlac(
        src,
        dst,
        bitsPerSample,
        sampleRate,
      );
    } else if (transcodeFormat == TranscodeFormat.aac) {
      rc = await transcodeAac(
        src,
        dst,
        bitrate,
      );
    } else if (transcodeFormat == TranscodeFormat.alac) {
      rc = await transcodeAlac(
        src,
        dst,
        bitsPerSample,
        sampleRate,
      );
    }

    // if error cleanup and done
    if (!rc) {
      try {
        await File(dst).delete();
      } catch (_) {}
      return false;
    }

    // restore
    if (filenameConflict) {
      // try to delete 1st
      try {
        await File(src).delete();
      } catch (e) {
        try {
          await File(dst).delete();
        } catch (_) {}
        return false;
      }

      // rename
      await File(dst).rename(src);
      dst = src;
    }

    // save metadata to dst
    tagLib.setAudioTags(dst, tags);
    tagLib.setArtwork(dst, artwork ?? Uint8List(0));
    tagLib.setLyrics(dst, lyrics);

    // delete source
    if (deleteSourceFile && !filenameConflict) {
      try {
        await File(src).delete();
      } catch (e) {
        return false;
      }
      database.delete(src);
    }

    // do we need to add to the library
    if (addToLibrary) {
      Track track = Track.parse(dst, tagLib);
      track.importedAt = importedAt;
      database.insert(track);
    }

    // done
    return true;
  }

  String _targetExtension(TranscodeFormat transcodeFormat) {
    switch (transcodeFormat) {
      case TranscodeFormat.mp3:
        return '.mp3';
      case TranscodeFormat.flac:
        return '.flac';
      case TranscodeFormat.aac:
        return '.aac';
      case TranscodeFormat.alac:
        return '.m4a';
    }
  }

  static bool isBitrateTranscode(TranscodeFormat format) {
    return [TranscodeFormat.mp3, TranscodeFormat.aac].contains(format);
  }

  static bool isSampleTranscode(TranscodeFormat format) {
    return [TranscodeFormat.flac, TranscodeFormat.alac].contains(format);
  }
}
