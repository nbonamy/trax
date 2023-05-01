import 'package:audiotranscode_ffi/audiotranscode_ffi.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../processors/transcoder.dart';
import '../utils/path_utils.dart';

enum ImportFileOp { copy, move }

enum LyricsSaveMode { tag, lrc }

abstract class PreferencesBase {
  String get musicFolder;
}

class Preferences extends ChangeNotifier implements PreferencesBase {
  static Preferences of(BuildContext context) {
    return Provider.of<Preferences>(context, listen: false);
  }

  late SharedPreferences _prefs;

  init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  // ignore: unnecessary_overrides
  void notifyListeners() {
    super.notifyListeners();
  }

  @override
  String get musicFolder {
    return _prefs.getString('musicfolder') ?? SystemPath.music() ?? '/Music';
  }

  set musicFolder(String folder) {
    _prefs.setString('musicfolder', folder);
  }

  ImportFileOp get importFileOp {
    return ImportFileOp.values.elementAt(_prefs.getInt('import.fileop') ?? 0);
  }

  set importFileOp(ImportFileOp importFileOp) {
    _prefs.setInt('import.fileop', importFileOp.index);
  }

  bool get keepMediaOrganized {
    return _prefs.getBool('import.keeporganized') ?? true;
  }

  set keepMediaOrganized(bool keepOrganized) {
    _prefs.setBool('import.keeporganized', keepOrganized);
  }

  LyricsSaveMode get lyricsSaveMode {
    return LyricsSaveMode.values
        .elementAt(_prefs.getInt('lyrics.savemode') ?? 0);
  }

  set lyricsSaveMode(LyricsSaveMode lyricsSaveMode) {
    _prefs.setInt('lyrics.savemode', lyricsSaveMode.index);
  }

  TranscodeFormat get transcodeFormat {
    return TranscodeFormat.values.elementAt(
        _prefs.getInt('transcode.format') ?? TranscodeFormat.flac.index);
  }

  set transcodeFormat(TranscodeFormat transcodeFormat) {
    _prefs.setInt('transcode.format', transcodeFormat.index);
  }

  TranscodingSettings get transcodingSettingsMp3 {
    return TranscodingSettings(
      _prefs.getInt('transcode.bitrate.mp3') ??
          AudioTranscoder.kSettingsMp3Bitrate.last.bitrate,
      0,
      0,
    );
  }

  set transcodingSettingsMp3(TranscodingSettings settings) {
    _prefs.setInt('transcode.bitrate.mp3', settings.bitrate);
  }

  TranscodingSettings get transcodingSettingsAac {
    return TranscodingSettings(
      _prefs.getInt('transcode.bitrate.aac') ??
          AudioTranscoder.kSettingsAacBitrate.last.bitrate,
      0,
      0,
    );
  }

  set transcodingSettingsAac(TranscodingSettings settings) {
    _prefs.setInt('transcode.bitrate.aac', settings.bitrate);
  }

  TranscodingSettings get transcodingSettingsFlac {
    return TranscodingSettings(
      0,
      _prefs.getInt('transcode.bitspersample.flac') ??
          AudioTranscoder.kSettingsFlacBitsPerSample.first.bitsPerSample,
      _prefs.getInt('transcode.samplerate.flac') ??
          AudioTranscoder.kSettingsSampleRate.first.sampleRate,
    );
  }

  set transcodingSettingsFlac(TranscodingSettings settings) {
    _prefs.setInt('transcode.bitspersample.flac', settings.bitsPerSample);
    _prefs.setInt('transcode.samplerate.flac', settings.sampleRate);
  }

  TranscodingSettings get transcodingSettingsAlac {
    return TranscodingSettings(
      0,
      _prefs.getInt('transcode.bitspersample.alac') ??
          AudioTranscoder.kSettingsAlacBitsPerSample.first.bitsPerSample,
      _prefs.getInt('transcode.samplerate.alac') ??
          AudioTranscoder.kSettingsSampleRate.first.sampleRate,
    );
  }

  set transcodingSettingsAlac(TranscodingSettings settings) {
    _prefs.setInt('transcode.bitspersample.alac', settings.bitsPerSample);
    _prefs.setInt('transcode.samplerate.alac', settings.sampleRate);
  }

  Rect get windowBounds {
    try {
      var bounds = _prefs.getString('window.bounds');
      var parts = bounds?.split(',');
      var left = double.parse(parts![0]);
      var top = double.parse(parts[1]);
      var right = double.parse(parts[2]);
      var bottom = double.parse(parts[3]);
      return Rect.fromLTRB(left, top, right, bottom);
    } catch (_) {
      return const Rect.fromLTWH(0, 0, 800, 600);
    }
  }

  set windowBounds(Rect rc) {
    _prefs.setString('window.bounds',
        '${rc.left.toStringAsFixed(1)},${rc.top.toStringAsFixed(1)},${rc.right.toStringAsFixed(1)},${rc.bottom.toStringAsFixed(1)}');
  }

  Alignment getDialogAlignment(String preferenceKey) {
    try {
      var alignment = _prefs.getString(preferenceKey);
      var parts = alignment?.split(',');
      var x = double.parse(parts![0]);
      var y = double.parse(parts[1]);
      return Alignment(x, y);
    } catch (_) {
      return Alignment.center;
    }
  }

  void saveEditorAlignment(String preferenceKey, Alignment alignment) {
    _prefs.setString(preferenceKey,
        '${alignment.x.toStringAsFixed(1)},${alignment.y.toStringAsFixed(1)}');
  }
}
