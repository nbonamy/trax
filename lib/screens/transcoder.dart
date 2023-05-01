import 'package:audiotranscode_ffi/audiotranscode_ffi.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:taglib_ffi/taglib_ffi.dart';

import '../components/app_icon.dart';
import '../components/button.dart';
import '../components/draggable_dialog.dart';
import '../data/database.dart';
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
  late AudioTranscoder _audioTranscoder;
  final TagLib tagLib = TagLib();
  late TraxDatabase _database;
  String? _destinationFolder;
  late Preferences _preferences;
  bool _deleteSourceFiles = false;
  late TranscodeFormat _format;
  final Map<TranscodeFormat, TranscodingSettings> _settings = {};
  bool _stopTranscode = false;

  // info
  bool get isTranscodingLibraryTracks => widget.trackList != null;
  bool get isTranscodingFiles =>
      !isTranscodingLibraryTracks && widget.files != null;

  // bitrate adapters
  List<AudioSettingBitrate> get bitrateValues => _format == TranscodeFormat.aac
      ? AudioTranscoder.kSettingsAacBitrate
      : AudioTranscoder.kSettingsMp3Bitrate;
  int get bitrate => _settings[_format]!.bitrate;
  set bitrate(int bitrate) => _settings[_format]!.bitrate = bitrate;

  // bits per sample adapters
  List<AudioSettingBitsPerSample> get bitsPerSampleValues =>
      _format == TranscodeFormat.alac
          ? AudioTranscoder.kSettingsAlacBitsPerSample
          : AudioTranscoder.kSettingsFlacBitsPerSample;
  int get bitsPerSample => _settings[_format]!.bitsPerSample;
  set bitsPerSample(int bitsPerSample) =>
      _settings[_format]!.bitsPerSample = bitsPerSample;

  // sample rate adapter
  List<AudioSettingSampleRate> get sampleRateValues =>
      AudioTranscoder.kSettingsSampleRate;
  int get sampleRate => _settings[_format]!.sampleRate;
  set sampleRate(int sampleRate) => _settings[_format]!.sampleRate = sampleRate;

  @override
  void initState() {
    super.initState();
    _database = TraxDatabase.of(context);
    _preferences = Preferences.of(context);
    _audioTranscoder = AudioTranscoder(database: _database);
    _format = _preferences.transcodeFormat;
    _settings[TranscodeFormat.mp3] = _preferences.transcodingSettingsMp3;
    _settings[TranscodeFormat.aac] = _preferences.transcodingSettingsAac;
    _settings[TranscodeFormat.flac] = _preferences.transcodingSettingsFlac;
    _settings[TranscodeFormat.alac] = _preferences.transcodingSettingsAlac;
    eventBus.on<StopTranscodeEvent>().listen((event) => _stopTranscode = true);
  }

  Future<String> _getSourceFileDescription() async {
    Format? format;
    int? bitrate;
    int? sampleRate;
    int? bitsPerSample;
    // needed
    AppLocalizations t = AppLocalizations.of(context)!;

    // tracks
    if (isTranscodingLibraryTracks) {
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
    } else if (isTranscodingFiles) {
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
      if (AudioTranscoder.isBitrateFormat(format)) {
        String desc = Track.getFormatString(format, shortDescription: true);
        desc += bitrate == null
            ? ', ${t.transcodeInfoVariousBitrates}'
            : ', $bitrate bps';
        return desc;
      } else if (AudioTranscoder.isSampleFormat(format)) {
        String desc = Track.getFormatString(format, shortDescription: true);
        desc += bitsPerSample == null
            ? ', ${t.transcodeInfoVariousBitsPerSample}'
            : ', $bitsPerSample bits';
        desc += sampleRate == null
            ? ', ${t.transcodeInfoVariousSampleRates}'
            : ', $sampleRate Hz';
        return desc;
      } else {
        return 'Unknown format';
      }
    }

    // too bad
    return t.transcodeInfoVariousFormats;
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
            t.transcodeTitle,
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
                return _row(t.transcodeInfoTitle, 1, [Text(text)]);
              }),
          _row(t.transcodeFormat, 1, [
            MacosPopupButton(
                value: _format,
                items: const [
                  MacosPopupMenuItem(
                    value: TranscodeFormat.flac,
                    child: Text('FLAC'),
                  ),
                  MacosPopupMenuItem(
                    value: TranscodeFormat.mp3,
                    child: Text('MP3'),
                  ),
                  MacosPopupMenuItem(
                    value: TranscodeFormat.alac,
                    child: Text('ALAC'),
                  ),
                  MacosPopupMenuItem(
                    value: TranscodeFormat.aac,
                    child: Text('AAC'),
                  ),
                ],
                onChanged: (f) => setState(() => _format = f!)),
          ]),
          if (AudioTranscoder.isBitrateTranscode(_format)) ...[
            _row(t.transcodeBitrate, 1, [
              MacosPopupButton(
                value: bitrate,
                items: bitrateValues
                    .map(
                      (s) => MacosPopupMenuItem(
                        value: s.bitrate,
                        child: Text(s.name),
                      ),
                    )
                    .toList(),
                onChanged: (b) => setState(() => bitrate = b!),
              ),
            ]),
          ],
          if (AudioTranscoder.isSampleTranscode(_format)) ...[
            _row(t.transcodeBitsPerSample, 1, [
              MacosPopupButton(
                value: bitsPerSample,
                items: bitsPerSampleValues
                    .map(
                      (s) => MacosPopupMenuItem(
                        value: s.bitsPerSample,
                        child: Text(s.name),
                      ),
                    )
                    .toList(),
                onChanged: (b) => setState(() => bitsPerSample = b!),
              ),
            ]),
            _row(t.transcodeSampleRate, 1, [
              MacosPopupButton(
                value: sampleRate,
                items: sampleRateValues
                    .map(
                      (s) => MacosPopupMenuItem(
                        value: s.sampleRate,
                        child: Text(s.name),
                      ),
                    )
                    .toList(),
                onChanged: (s) => setState(() => sampleRate = s!),
              ),
            ]),
          ],
          _row(t.transcodeDestination, 1, [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_destinationFolder ?? t.transcodeDestinationSame),
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
            Text(t.transcodeDeleteSrc),
          ]),
        ],
      ),
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Button(t.cancel, _onClose),
          const SizedBox(width: 8),
          Button(t.save, _onTranscode, defaultButton: true),
        ],
      ),
    );
  }

  void _onClose() {
    Navigator.of(context).pop();
  }

  void _onTranscode() async {
    _save();
    _transcode();
    _onClose();
  }

  void _save() {
    _preferences.transcodeFormat = _format;
    _preferences.transcodingSettingsMp3 = _settings[TranscodeFormat.mp3]!;
    _preferences.transcodingSettingsAac = _settings[TranscodeFormat.aac]!;
    _preferences.transcodingSettingsFlac = _settings[TranscodeFormat.flac]!;
    _preferences.transcodingSettingsAlac = _settings[TranscodeFormat.alac]!;
  }

  void _transcode() {
    if (isTranscodingLibraryTracks) {
      _transcodeFiles(widget.trackList!.map((t) => t.filename).toList());
    } else if (isTranscodingFiles) {
      _transcodeFiles(widget.files!);
    }
  }

  void _transcodeFiles(List<String> files) async {
    _stopTranscode = false;
    for (int i = 0; i < files.length; i++) {
      eventBus
          .fire(BackgroundActionStartEvent(BackgroundAction.transcode, data: {
        'index': i + 1,
        'count': files.length,
      }));
      String src = files[i];
      await _runTranscode(src);
      if (_stopTranscode) {
        break;
      }
    }
    eventBus.fire(BackgroundActionEndEvent(BackgroundAction.transcode));
  }

  Future<bool> _runTranscode(String src) {
    return _audioTranscoder.transcode(
      src,
      _destinationFolder,
      _format,
      bitrate,
      bitsPerSample,
      sampleRate,
      _deleteSourceFiles,
      isTranscodingLibraryTracks && _destinationFolder == null,
    );
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
