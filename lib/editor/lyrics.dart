import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:taglib_ffi/taglib_ffi.dart';

import '../model/track.dart';

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
  bool _deleteLyrics = false;
  final TextEditingController _controller = TextEditingController();

  String? get lyrics {
    if (widget.track == null) {
      return _deleteLyrics ? '' : null;
    } else {
      return _controller.text;
    }
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void didUpdateWidget(EditorLyricsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    loadData();
  }

  void loadData() {
    if (widget.track != null) {
      widget.track!.loadLyrics(TagLib());
      _controller.text = widget.track!.lyrics ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations t = AppLocalizations.of(context)!;
    return Center(
      child: (widget.track == null)
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MacosCheckbox(
                  value: _deleteLyrics,
                  onChanged: (v) => setState(() => _deleteLyrics = v),
                ),
                const SizedBox(width: 8),
                Text(t.lyricsDelete),
              ],
            )
          : MacosTextField(
              controller: _controller,
              minLines: 24,
              maxLines: 24,
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color.fromRGBO(192, 192, 192, 1.0),
                  width: 0.8,
                ),
              ),
            ),
    );
  }
}
