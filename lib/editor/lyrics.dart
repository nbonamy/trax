import 'package:flutter/material.dart';

class EditorLyricsWidget extends StatefulWidget {
  final bool singleTrackMode;
  const EditorLyricsWidget({
    super.key,
    required this.singleTrackMode,
  });

  @override
  State<EditorLyricsWidget> createState() => EditorLyricsWidgetState();
}

class EditorLyricsWidgetState extends State<EditorLyricsWidget> {
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

  void loadData() {}

  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.red);
  }
}
