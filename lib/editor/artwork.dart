import 'dart:typed_data';

import 'package:flutter/material.dart';

class EditorArtworkWidget extends StatefulWidget {
  final Uint8List? bytes;
  final bool singleTrackMode;
  const EditorArtworkWidget({
    super.key,
    required this.bytes,
    required this.singleTrackMode,
  });

  @override
  State<EditorArtworkWidget> createState() => EditorArtworkWidgetState();
}

class EditorArtworkWidgetState extends State<EditorArtworkWidget> {
  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void didUpdateWidget(EditorArtworkWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    loadData();
  }

  void loadData() {}

  @override
  Widget build(BuildContext context) {
    return Container(height: 322, color: Colors.blue);
  }
}
