import 'package:flutter/material.dart';

class EditorFileWidget extends StatefulWidget {
  final bool singleTrackMode;
  const EditorFileWidget({
    super.key,
    required this.singleTrackMode,
  });

  @override
  State<EditorFileWidget> createState() => EditorFileWidgetState();
}

class EditorFileWidgetState extends State<EditorFileWidget> {
  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void didUpdateWidget(EditorFileWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    loadData();
  }

  void loadData() {}

  @override
  Widget build(BuildContext context) {
    return Container(height: 322, color: Colors.green);
  }
}
