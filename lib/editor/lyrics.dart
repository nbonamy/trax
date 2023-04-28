import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:taglib_ffi/taglib_ffi.dart';

import '../model/preferences.dart';
import '../model/track.dart';
import '../processors/saver.dart';
import 'loading.dart';

class EditorLyricsWidget extends StatefulWidget {
  final Track? track;
  const EditorLyricsWidget({
    super.key,
    this.track,
  });

  @override
  State<EditorLyricsWidget> createState() => EditorLyricsWidgetState();
}

class EditorLyricsWidgetState extends State<EditorLyricsWidget> {
  late TagLib _tagLib;
  MetadataAction _action = MetadataAction.loading;
  final TextEditingController _controller = TextEditingController();

  MetadataAction get action => _action;

  String? get lyrics {
    switch (_action) {
      case MetadataAction.loading:
      case MetadataAction.untouched:
        return null;
      case MetadataAction.deleted:
        return '';
      default:
        return _controller.text;
    }
  }

  @override
  void initState() {
    super.initState();
    _tagLib = TagLib();
    _controller.addListener(() {
      if (_controller.text == widget.track!.lyrics) {
        _action = MetadataAction.untouched;
      } else {
        _action = MetadataAction.updated;
      }
    });
  }

  @override
  void didUpdateWidget(covariant EditorLyricsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _action = MetadataAction.loading;
  }

  Future<bool> loadLyrics() async {
    if (widget.track == null) return Future.value(false);
    if (_action == MetadataAction.loading) {
      // get dependent of prefs
      String lyrics = '';
      Preferences prefs = Preferences.of(context);
      switch (prefs.lyricsSaveMode) {
        case LyricsSaveMode.tag:
          lyrics = await _tagLib.getLyrics(widget.track!.filename);
          break;
        case LyricsSaveMode.lrc:
          File f = File(widget.track!.companionLrcFilepath);
          if (f.existsSync()) {
            lyrics = await f.readAsString();
          }
          break;
      }

      // if still loading
      if (_action == MetadataAction.loading) {
        _controller.text = lyrics;
        widget.track!.lyrics = lyrics;
        _action = MetadataAction.untouched;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations t = AppLocalizations.of(context)!;
    return Center(
      child: Builder(
        builder: (context) {
          if (widget.track == null) {
            // on multiple tracks we can only delete
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MacosCheckbox(
                  value: _action == MetadataAction.deleted,
                  onChanged: (v) => setState(() => _action =
                      v ? MetadataAction.deleted : MetadataAction.untouched),
                ),
                const SizedBox(width: 8),
                Text(t.lyricsDelete),
              ],
            );
          } else {
            return FutureBuilder<bool>(
              future: loadLyrics(),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done ||
                    snapshot.hasData == false ||
                    snapshot.data == false) {
                  return const LoadingWidget();
                } else {
                  return MacosTextField(
                    controller: _controller,
                    minLines: 24,
                    maxLines: 24,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color.fromRGBO(192, 192, 192, 1.0),
                        width: 0.8,
                      ),
                    ),
                    style: const TextStyle(
                      fontFeatures: [
                        FontFeature.tabularFigures(),
                      ],
                    ),
                  );
                }
              },
            );
          }
        },
      ),
    );
  }
}
