import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:taglib_ffi/taglib_ffi.dart';

import '../components/artwork.dart';
import '../components/button.dart';
import '../model/menu_actions.dart';
import '../model/track.dart';
import '../processors/saver.dart';

class EditorArtworkWidget extends StatefulWidget {
  final Track? track;
  const EditorArtworkWidget({
    super.key,
    this.track,
  });

  @override
  State<EditorArtworkWidget> createState() => EditorArtworkWidgetState();
}

class EditorArtworkWidgetState extends State<EditorArtworkWidget>
    with MenuHandler {
  static const kArtworkSize = 300.0;

  late TagLib _tagLib;
  MetadataAction _action = MetadataAction.loading;
  Uint8List? _bytes;

  Uint8List? get bytes {
    switch (_action) {
      case MetadataAction.loading:
      case MetadataAction.untouched:
        return null;
      case MetadataAction.deleted:
        return Uint8List(0);
      default:
        return _bytes;
    }
  }

  @override
  void initState() {
    super.initState();
    initMenuSubscription();
    _tagLib = TagLib();
  }

  @override
  void didUpdateWidget(EditorArtworkWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _action = MetadataAction.loading;
    _bytes = null;
  }

  @override
  void dispose() {
    cancelMenuSubscription();
    super.dispose();
  }

  Future<bool> loadArtwork() async {
    if (widget.track == null) return Future.value(true);
    if (_action == MetadataAction.loading) {
      Uint8List? bytes = await _tagLib.getArtworkBytes(widget.track!.filename);
      // if still loading
      if (_action == MetadataAction.loading) {
        _bytes = bytes;
        _action = MetadataAction.untouched;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations t = AppLocalizations.of(context)!;
    return Center(
      child: FutureBuilder<bool>(
        future: loadArtwork(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done ||
              snapshot.hasData == false ||
              snapshot.data == false) {
            return LoadingAnimationWidget.prograssiveDots(
              size: 64,
              color: CupertinoColors.systemGrey,
            );
          } else {
            return Flex(
              direction: Axis.vertical,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                (widget.track == null && _bytes == null)
                    ? Container(
                        width: kArtworkSize,
                        height: kArtworkSize,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: CupertinoColors.lightBackgroundGray,
                          ),
                        ),
                        child: _action == MetadataAction.deleted
                            ? Container()
                            : const Icon(
                                CupertinoIcons.music_albums,
                                size: kArtworkSize * 0.5,
                                color: CupertinoColors.lightBackgroundGray,
                              ),
                      )
                    : ArtworkWidget(
                        bytes: _bytes,
                        size: kArtworkSize,
                        radius: 0.0,
                      ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.track == null || _bytes != null) ...[
                      Button(t.artworkDelete, _delete),
                      const SizedBox(width: 16),
                    ],
                    Button(t.artworkUpdate, _add),
                  ],
                )
              ],
            );
          }
        },
      ),
    );
  }

  _delete() {
    setState(() {
      _bytes = null;
      _action = MetadataAction.deleted;
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
        _action = MetadataAction.updated;
      });
    }
  }

  @override
  void onMenuAction(MenuAction action) async {
    if (action == MenuAction.editPaste) {
      final imageBytes = await Pasteboard.image;
      if (imageBytes != null) {
        setState(() {
          _bytes = imageBytes;
          _action = MetadataAction.updated;
        });
      }
    }
  }
}
