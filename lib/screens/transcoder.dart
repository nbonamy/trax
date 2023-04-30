import 'dart:typed_data';

import 'package:audiotranscode_ffi/audiotranscode_ffi.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:path/path.dart' as p;
import 'package:macos_ui/macos_ui.dart';
import 'package:taglib_ffi/taglib_ffi.dart';

import '../components/app_icon.dart';
import '../components/button.dart';
import '../components/draggable_dialog.dart';
import '../model/preferences.dart';
import '../model/track.dart';
import '../processors/transcoder.dart';

class TranscoderWidget extends StatefulWidget {
  final List<String?>? files;
  final TrackList? trackList;
  const TranscoderWidget({
    super.key,
    this.trackList,
    this.files,
  });

  @override
  State<TranscoderWidget> createState() => _TranscoderWidgetState();

  static void show(
    BuildContext context, {
    TrackList? selection,
    List<String?>? files,
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          child: TranscoderWidget(trackList: selection, files: files),
        );
      },
    );
  }
}

class _TranscoderWidgetState extends State<TranscoderWidget> {
  final AudioTranscoder _audioTranscoder = AudioTranscoder();
  final TagLib tagLib = TagLib();
  String? _destinationFolder;
  late Preferences _preferences;
  late TranscodeFormat _transcodeFormat;
  late int _bitsPerSample;
  late int _sampleRate;
  late int _bitrate;

  @override
  void initState() {
    super.initState();
    _preferences = Preferences.of(context);
    _transcodeFormat = _preferences.convertFormat;
    _bitsPerSample = _preferences.convertBitsPerSample;
    _sampleRate = _preferences.convertSamplerate;
    _bitrate = _preferences.convertBitrate;
  }

  @override
  Widget build(BuildContext context) {
    // needed
    AppLocalizations t = AppLocalizations.of(context)!;

    return DraggableDialog(
      width: 550,
      height: 370,
      headerBgColor: const Color.fromRGBO(240, 234, 230, 1.0),
      //: const Color.fromRGBO(240, 234, 230, 1.0),
      // contentsBgColor: const Color.fromRGBO(246, 240, 236, 1.0),
      header: Row(
        children: [
          const AppIcon(size: 80),
          const SizedBox(width: 16),
          Text(
            t.convertTitle,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ],
      ),
      body: Flex(
        direction: Axis.vertical,
        children: [
          _row(t.convertDestination, 1, [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_destinationFolder ?? t.convertDestinationSame),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (_destinationFolder != null) ...[
                      Button(
                        'Clear',
                        () => setState(() => _destinationFolder = null),
                        horizontalPadding: 8,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Button(
                      'Browse...',
                      () async {
                        String? folder =
                            await FilePicker.platform.getDirectoryPath();
                        setState(() => _destinationFolder = folder);
                      },
                      horizontalPadding: 8,
                    ),
                  ],
                ),
              ],
            ),
          ]),
          _row(t.convertFormat, 1, [
            MacosPopupButton(
                value: _transcodeFormat,
                items: const [
                  MacosPopupMenuItem(
                    value: TranscodeFormat.mp3,
                    child: Text('MP3'),
                  ),
                  MacosPopupMenuItem(
                    value: TranscodeFormat.flac,
                    child: Text('FLAC'),
                  ),
                ],
                onChanged: (f) => setState(() => _transcodeFormat = f!)),
          ]),
          if (_transcodeFormat == TranscodeFormat.mp3) ...[
            _row(t.convertBitrate, 1, [
              MacosPopupButton(
                  value: _bitrate,
                  items: const [
                    MacosPopupMenuItem(
                      value: 128000,
                      child: Text('128 kbps'),
                    ),
                    MacosPopupMenuItem(
                      value: 160000,
                      child: Text('160 kbps'),
                    ),
                    MacosPopupMenuItem(
                      value: 192000,
                      child: Text('192 kbps'),
                    ),
                    MacosPopupMenuItem(
                      value: 320000,
                      child: Text('320 kbps'),
                    ),
                  ],
                  onChanged: (b) => setState(() => _bitrate = b!)),
            ]),
          ],
          if (_transcodeFormat == TranscodeFormat.flac) ...[
            _row(t.convertBitsPerSample, 1, [
              MacosPopupButton(
                  value: _bitsPerSample,
                  items: const [
                    MacosPopupMenuItem(
                      value: 16,
                      child: Text('16 bits'),
                    ),
                    MacosPopupMenuItem(
                      value: 24,
                      child: Text('24 bits'),
                    ),
                    MacosPopupMenuItem(
                      value: 32,
                      child: Text('32 bits'),
                    ),
                  ],
                  onChanged: (b) => setState(() => _bitsPerSample = b!)),
            ]),
            _row(t.convertSampleRate, 1, [
              MacosPopupButton(
                  value: _sampleRate,
                  items: const [
                    MacosPopupMenuItem(
                      value: 44100,
                      child: Text('44.1 kHz'),
                    ),
                    MacosPopupMenuItem(
                      value: 48000,
                      child: Text('48 kHz'),
                    ),
                    MacosPopupMenuItem(
                      value: 88200,
                      child: Text('88.2 kHz'),
                    ),
                    MacosPopupMenuItem(
                      value: 96000,
                      child: Text('96 kHz'),
                    ),
                  ],
                  onChanged: (s) => setState(() => _sampleRate = s!)),
            ]),
          ],
        ],
      ),
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Button(t.cancel, _onClose),
          const SizedBox(width: 8),
          Button(t.save, _onConvert, defaultButton: true),
        ],
      ),
    );
  }

  void _onClose() {
    Navigator.of(context).pop();
  }

  void _onConvert() async {
    _save();
    _transcode();
    _onClose();
  }

  void _save() {
    _preferences.convertFormat = _transcodeFormat;
    _preferences.convertBitsPerSample = _bitsPerSample;
    _preferences.convertSamplerate = _sampleRate;
    _preferences.convertBitrate = _bitrate;
  }

  void _transcode() {
    if (widget.trackList != null) {
      _transcodeSelection(widget.trackList!);
    } else if (widget.files != null) {
      _transcodeFiles(widget.files!);
    }
  }

  void _transcodeSelection(TrackList trackList) async {
    _transcodeFiles(trackList.map((t) => t.filename).toList());
  }

  void _transcodeFiles(List<String?> files) async {
    for (String? file in files) {
      if (file == null) continue;
      String src = file;
      await _runTranscode(src);
    }
  }

  Future<bool> _runTranscode(String src) async {
    // init
    bool rc = false;
    String dst = p.join(_destinationFolder ?? p.dirname(src), p.basename(src));

    // now transcode
    if (_transcodeFormat == TranscodeFormat.mp3) {
      dst = _replaceExtension(dst, '.mp3');
      rc = await _audioTranscoder.transcodeMp3(src, dst, _bitrate);
    } else if (_transcodeFormat == TranscodeFormat.flac) {
      dst = _replaceExtension(dst, '.flac');
      rc = await _audioTranscoder.transcodeFlac(
          src, dst, _sampleRate, _bitsPerSample);
    }

    // if successful copy metadata
    if (rc) {
      // get it from src
      Tags tags = tagLib.getAudioTags(src);
      Uint8List? artwork = await tagLib.getArtworkBytes(src);
      String? lyrics = await tagLib.getLyrics(src);

      // save it to dst
      tagLib.setAudioTags(dst, tags);
      tagLib.setArtwork(dst, artwork ?? Uint8List(0));
      tagLib.setLyrics(dst, lyrics);
    }

    // done
    return rc;
  }

  String _replaceExtension(String filepath, String ext) {
    return p.setExtension(filepath, ext);
  }

  Widget _row(String label, double paddingTop, List<Widget> widgets) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Flex(
        direction: Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(label, paddingTop),
          ...widgets,
        ],
      ),
    );
  }

  Widget _label(String label, double paddingTop) {
    return SizedBox(
      width: 120,
      child: Padding(
        padding: EdgeInsets.only(top: paddingTop, right: 12),
        child: Text(
          label,
          textAlign: TextAlign.right,
          style: const TextStyle(
            fontSize: 13,
            color: Color.fromRGBO(125, 125, 125, 1.0),
          ),
        ),
      ),
    );
  }
}
