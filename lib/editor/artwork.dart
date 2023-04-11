import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../components/artwork.dart';
import '../components/button.dart';
import '../processors/saver.dart';

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
  static const kArtworkSize = 300.0;
  ArtworkAction _action = ArtworkAction.untouched;
  Uint8List? _bytes;

  ArtworkAction get action => _action;
  Uint8List? get bytes => _bytes;

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

  void loadData() {
    _action = ArtworkAction.untouched;
    _bytes = widget.bytes == null ? null : Uint8List.fromList(widget.bytes!);
  }

  set bytes(Uint8List? imageBytes) {
    setState(() {
      _bytes = imageBytes;
      _action = ArtworkAction.updated;
    });
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations t = AppLocalizations.of(context)!;
    return Center(
      child: Flex(
        direction: Axis.vertical,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ArtworkWidget(
            bytes: bytes,
            size: kArtworkSize,
            radius: 0.0,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (bytes != null) ...[
                Button(t.artworkDelete, _delete),
                const SizedBox(width: 16),
              ],
              Button(
                bytes == null ? t.artworkAdd : t.artworkReplace,
                _add,
              ),
            ],
          )
        ],
      ),
    );
  }

  _delete() {
    setState(() {
      _bytes = null;
      _action = ArtworkAction.deleted;
    });
  }

  _add() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
    );
    if (result != null && result.isSinglePick) {
      File f = File(result.paths.first!);
      Uint8List fileBytes = await f.readAsBytes();
      setState(() {
        _bytes = fileBytes;
        _action = ArtworkAction.updated;
      });
    }
  }
}
