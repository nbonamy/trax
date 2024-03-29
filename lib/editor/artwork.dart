import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:taglib_ffi/taglib_ffi.dart';

import '../components/context_menu.dart' as ctxm;
import '../components/artwork.dart';
import '../components/button.dart';
import '../model/menu_actions.dart';
import '../model/track.dart';
import '../processors/saver.dart';
import 'loading.dart';

typedef ArtworkCalculatedCallback = void Function(Uint8List bytes);

class EditorArtworkWidget extends StatefulWidget {
  final Track? track;
  final TrackList selection;
  final ArtworkCalculatedCallback artworkCallback;
  const EditorArtworkWidget({
    super.key,
    required this.track,
    required this.selection,
    required this.artworkCallback,
  });

  @override
  State<EditorArtworkWidget> createState() => EditorArtworkWidgetState();
}

class EditorArtworkWidgetState extends State<EditorArtworkWidget>
    with MenuHandler {
  static const kArtworkSize = 300.0;

  late TagLib _tagLib;
  MetadataAction _action = MetadataAction.loading;
  bool? _checkingMultiple;
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
    if (oldWidget.track != widget.track ||
        oldWidget.selection != widget.selection) {
      _action = MetadataAction.loading;
      _checkingMultiple = null;
      _bytes = null;
    }
  }

  @override
  void dispose() {
    cancelMenuSubscription();
    super.dispose();
  }

  Future<bool> loadArtwork() async {
    if (_action == MetadataAction.loading) {
      if (widget.track == null) {
        // check in background
        if (_checkingMultiple == null) {
          _checkingMultiple = true;
          _checkIfSameArtwork();
        }
        return Future.value(true);
      }
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
            return const LoadingWidget();
          } else {
            return Flex(
              direction: Axis.vertical,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DropTarget(
                  onDragDone: (detail) async {
                    Uint8List fileBytes =
                        await detail.files.first.readAsBytes();
                    setState(() {
                      _bytes = fileBytes;
                      _action = MetadataAction.updated;
                    });
                  },
                  child: (widget.track == null && _bytes == null)
                      ? _multiplePlaceholder()
                      : ctxm.ContextMenu(
                          menu: ctxm.Menu(
                            items: [
                              if (_bytes != null)
                                ctxm.MenuItem(
                                  label: t.menuEditCopy,
                                  onClick: (_) => _copy(bytes!),
                                ),
                              ctxm.MenuItem(
                                label: t.menuEditPaste,
                                onClick: (_) => _paste(),
                              ),
                              ctxm.MenuItem.separator(),
                              ctxm.MenuItem(
                                label: t.menuEditDelete,
                                onClick: (_) => _delete(),
                              ),
                            ],
                          ),
                          child: ArtworkWidget(
                            bytes: _bytes,
                            size: kArtworkSize,
                            radius: 0.0,
                          ),
                        ),
                ),
                const SizedBox(height: 8),
                _actionButtons()
              ],
            );
          }
        },
      ),
    );
  }

  Widget _multiplePlaceholder() {
    return Container(
      width: kArtworkSize,
      height: kArtworkSize,
      decoration: BoxDecoration(
        border: Border.all(
          color: CupertinoColors.lightBackgroundGray,
        ),
      ),
      child: _action == MetadataAction.deleted
          ? Container()
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  CupertinoIcons.music_albums,
                  size: kArtworkSize * 0.5,
                  color: CupertinoColors.lightBackgroundGray,
                ),
                if (_checkingMultiple != null && _checkingMultiple!) ...[
                  const SizedBox(height: 8),
                  LoadingAnimationWidget.prograssiveDots(
                    size: 32,
                    color: CupertinoColors.lightBackgroundGray,
                  ),
                ]
              ],
            ),
    );
  }

  Widget _actionButtons() {
    AppLocalizations t = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.track == null || _bytes != null) ...[
          Button(t.artworkDelete, onPressed: _delete),
          const SizedBox(width: 16),
        ],
        Button(t.artworkUpdate, onPressed: _add),
      ],
    );
  }

  void _delete() {
    setState(() {
      _bytes = null;
      _action = MetadataAction.deleted;
    });
  }

  void _add() async {
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

  Future<void> _paste() async {
    final imageBytes = await Pasteboard.image;
    if (imageBytes != null) {
      setState(() {
        _bytes = imageBytes;
        _action = MetadataAction.updated;
      });
    }
  }

  void _copy(Uint8List bytes) {
    Pasteboard.writeImage(bytes);
  }

  void _checkIfSameArtwork() async {
    Uint8List? refBytes =
        await _tagLib.getArtworkBytes(widget.selection.first.filename);
    for (int i = 1; i < widget.selection.length; i++) {
      Uint8List? bytes =
          await _tagLib.getArtworkBytes(widget.selection[i].filename);
      if (_action != MetadataAction.loading ||
          listEquals(bytes?.toList(), refBytes?.toList()) == false) {
        setState(() => _checkingMultiple = false);
        return;
      }
    }

    // we are here so all same: but do a last check
    if (_action == MetadataAction.loading) {
      setState(() {
        _bytes = refBytes;
        _action = MetadataAction.untouched;
        _checkingMultiple = false;
      });
      if (_bytes != null) {
        widget.artworkCallback(_bytes!);
      }
    }
  }

  @override
  void onMenuAction(MenuAction action) async {
    if (action == MenuAction.editPaste) {
      await _paste();
    }
  }
}
