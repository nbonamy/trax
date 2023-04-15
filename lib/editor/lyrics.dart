import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:taglib_ffi/taglib_ffi.dart';

import '../model/track.dart';

class EditorLyricsWidget extends StatefulWidget {
  final Track track;
  const EditorLyricsWidget({
    super.key,
    required this.track,
  });

  @override
  State<EditorLyricsWidget> createState() => EditorLyricsWidgetState();
}

class EditorLyricsWidgetState extends State<EditorLyricsWidget> {
  final TextEditingController _controller = TextEditingController();

  String get lyrics => _controller.text;

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
    widget.track.loadLyrics(TagLib());
    _controller.text = widget.track.lyrics ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: MacosTextField(
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
