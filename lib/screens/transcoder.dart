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
import '../utils/events.dart';

class TranscoderWidget extends StatefulWidget {
  final List<String>? files;
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
    List<String>? files,
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          child: TranscoderWidget(
            trackList: selection,
            files: files,
          ),
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
  bool _deleteSourceFiles = false;
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

  Future<String> _getSourceFileDescription() async {
    Format? format;
    int? bitrate;
    int? sampleRate;
    int? bitsPerSample;
    // needed
    AppLocalizations t = AppLocalizations.of(context)!;

    // tracks
    if (widget.trackList != null) {
      // init
      format = widget.trackList!.first.format;
      bitrate = widget.trackList!.first.safeTags.bitrate;
      sampleRate = widget.trackList!.first.safeTags.sampleRate;
      bitsPerSample = widget.trackList!.first.safeTags.bitsPerSample;

      // parse all
      for (Track track in widget.trackList!.skip(1)) {
        if (track.format != format) format = null;
        if (track.safeTags.bitrate != bitrate) bitrate = null;
        if (track.safeTags.sampleRate != sampleRate) sampleRate = null;
        if (track.safeTags.bitsPerSample != bitsPerSample) bitsPerSample = null;
      }
    } else if (widget.files != null) {
      // init
      Tags tags = tagLib.getAudioTags(widget.files!.first);
      format = Track.getFormat(widget.files!.first);
      bitrate = tags.bitrate;
      sampleRate = tags.sampleRate;
      bitsPerSample = tags.bitsPerSample;

      // parse all
      for (String file in widget.files!.skip(1)) {
        Tags tags = tagLib.getAudioTags(file);
        if (Track.getFormat(file) != format) format = null;
        if (tags.bitrate != bitrate) bitrate = null;
        if (tags.sampleRate != sampleRate) sampleRate = null;
        if (tags.bitsPerSample != bitsPerSample) bitsPerSample = null;
      }
    }

    // decide
    if (format != null) {
      if (format == Format.mp3 || format == Format.vorbis) {
        String desc = Track.getFormatString(format, shortDescription: true);
        desc += bitrate == null
            ? ', ${t.convertInfoVariousBitrates}'
            : ', $bitrate bps';
        return desc;
      } else if (format == Format.flac || format == Format.mp4) {
        String desc = Track.getFormatString(format, shortDescription: true);
        desc += bitsPerSample == null
            ? ', ${t.convertInfoVariousBitsPerSample}'
            : ', $bitsPerSample bits';
        desc += sampleRate == null
            ? ', ${t.convertInfoVariousSampleRates}'
            : ', $sampleRate Hz';
        return desc;
      }
    }

    // too bad
    return t.convertInfoVariousFormats;
  }

  @override
  Widget build(BuildContext context) {
    // needed
    AppLocalizations t = AppLocalizations.of(context)!;

    return DraggableDialog(
      width: 550,
      height: 435,
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
          FutureBuilder(
              future: _getSourceFileDescription(),
              builder: (context, snapshot) {
                String text =
                    snapshot.hasData ? snapshot.data! : 'calculating...';
                return _row(t.convertInfoTitle, 1, [Text(text)]);
              }),
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
                items: AudioTranscoder.kSettingsBitrate
                    .map(
                      (s) => MacosPopupMenuItem(
                        value: s.bitrate,
                        child: Text(s.name),
                      ),
                    )
                    .toList(),
                onChanged: (b) => setState(() => _bitrate = b!),
              ),
            ]),
          ],
          if (_transcodeFormat == TranscodeFormat.flac) ...[
            _row(t.convertBitsPerSample, 1, [
              MacosPopupButton(
                value: _bitsPerSample,
                items: AudioTranscoder.kSettingsBitsPerSample
                    .map(
                      (s) => MacosPopupMenuItem(
                        value: s.bitsPerSample,
                        child: Text(s.name),
                      ),
                    )
                    .toList(),
                onChanged: (b) => setState(() => _bitsPerSample = b!),
              ),
            ]),
            _row(t.convertSampleRate, 1, [
              MacosPopupButton(
                value: _sampleRate,
                items: AudioTranscoder.kSettingsSampleRate
                    .map(
                      (s) => MacosPopupMenuItem(
                        value: s.sampleRate,
                        child: Text(s.name),
                      ),
                    )
                    .toList(),
                onChanged: (s) => setState(() => _sampleRate = s!),
              ),
            ]),
          ],
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
                        t.clear,
                        () => setState(() => _destinationFolder = null),
                        horizontalPadding: 8,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Button(
                      t.browse,
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
          _row('', 1, [
            MacosCheckbox(
              value: _deleteSourceFiles,
              onChanged: (b) => setState(() => _deleteSourceFiles = b),
            ),
            const SizedBox(width: 8),
            Text(t.convertDeleteSrc),
          ]),
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

  void _transcodeFiles(List<String> files) async {
    for (int i = 0; i < files.length; i++) {
      eventBus
          .fire(BackgroundActionStartEvent(BackgroundAction.transcode, data: {
        'index': i + 1,
        'count': files.length,
      }));
      String src = files[i];
      await _runTranscode(src);
    }
    eventBus.fire(BackgroundActionEndEvent(BackgroundAction.transcode));
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
