import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:taglib_ffi/taglib_ffi.dart';
import 'package:window_manager/window_manager.dart';

import '../browser/browser.dart';
import '../components/dialog.dart';
import '../data/database.dart';
import '../editor/editor.dart';
import '../model/menu_actions.dart';
import '../model/preferences.dart';
import '../model/track.dart';
import '../processors/saver.dart';
import '../processors/scanner.dart';
import '../utils/events.dart';
import '../utils/logger.dart';
import 'settings.dart';
import 'transcoder.dart';

class TraxHomePage extends StatefulWidget {
  const TraxHomePage({super.key});

  @override
  State<TraxHomePage> createState() => _TraxHomePageState();
}

class _TraxHomePageState extends State<TraxHomePage>
    with WindowListener, MenuHandler {
  final GlobalKey<BrowserWidgetState> _keyBrowser = GlobalKey();
  @override
  void initState() {
    super.initState();
    initMenuSubscription();
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    cancelMenuSubscription();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PlatformMenuBar(
      menus: _getMainMenu(context),
      child: BrowserWidget(
        key: _keyBrowser,
      ),
    );
  }

  List<PlatformMenuItem> _getMainMenu(BuildContext context) {
    AppLocalizations t = AppLocalizations.of(context)!;
    return [
      PlatformMenu(
        label: t.appName,
        menus: [
          const PlatformMenuItemGroup(
            members: [
              PlatformProvidedMenuItem(
                type: PlatformProvidedMenuItemType.about,
              ),
            ],
          ),
          PlatformMenuItemGroup(
            members: [
              PlatformMenuItem(
                label: t.menuAppSettings,
                shortcut: MenuUtils.cmdShortcut(LogicalKeyboardKey.comma),
                onSelected: () => onMenuSelected(MenuAction.appSettings),
              ),
            ],
          ),
          const PlatformMenuItemGroup(
            members: [
              PlatformProvidedMenuItem(
                type: PlatformProvidedMenuItemType.quit,
              ),
            ],
          ),
        ],
      ),
      PlatformMenu(
        label: t.menuFile,
        menus: [
          PlatformMenuItemGroup(
            members: [
              PlatformMenuItem(
                label: t.menuFileImport,
                onSelected: () => onMenuSelected(MenuAction.fileImport),
              ),
            ],
          ),
          PlatformMenuItemGroup(
            members: [
              PlatformMenuItem(
                label: t.menuFileRefresh,
                shortcut: MenuUtils.cmdShortcut(LogicalKeyboardKey.keyR),
                onSelected: () => onMenuSelected(MenuAction.fileRefresh),
              ),
              PlatformMenuItem(
                label: t.menuFileRebuild,
                onSelected: () => onMenuSelected(MenuAction.fileRebuild),
              ),
            ],
          ),
          PlatformMenuItemGroup(
            members: [
              PlatformMenuItem(
                label: t.menuFileReveal,
                shortcut:
                    MenuUtils.cmdShortcut(LogicalKeyboardKey.keyR, shift: true),
                onSelected: () => onMenuSelected(MenuAction.fileReveal),
              ),
            ],
          ),
        ],
      ),
      PlatformMenu(
        label: t.menuEdit,
        menus: [
          PlatformMenuItemGroup(
            members: [
              PlatformMenuItem(
                label: t.menuEditPaste,
                shortcut: MenuUtils.cmdShortcut(LogicalKeyboardKey.keyV),
                onSelected: () => onMenuSelected(MenuAction.editPaste),
              ),
            ],
          ),
          PlatformMenuItemGroup(
            members: [
              PlatformMenuItem(
                label: t.menuEditSelectAllAlbum,
                shortcut: MenuUtils.cmdShortcut(LogicalKeyboardKey.keyA),
                onSelected: () => onMenuSelected(MenuAction.editSelectAllAlbum),
              ),
              PlatformMenuItem(
                label: t.menuEditSelectAllArtist,
                shortcut:
                    MenuUtils.cmdShortcut(LogicalKeyboardKey.keyA, shift: true),
                onSelected: () =>
                    onMenuSelected(MenuAction.editSelectAllArtist),
              ),
            ],
          ),
        ],
      ),
      PlatformMenu(
        label: t.menuTrack,
        menus: [
          PlatformMenuItemGroup(
            members: [
              PlatformMenuItem(
                label: t.menuTrackInfo,
                shortcut: MenuUtils.cmdShortcut(LogicalKeyboardKey.keyI),
                onSelected: () => onMenuSelected(MenuAction.trackInfo),
              ),
              PlatformMenuItem(
                label: t.menuTrackCleanupTitles,
                //shortcut: MenuUtils.cmdShortcut(LogicalKeyboardKey.keyI),
                onSelected: () => onMenuSelected(MenuAction.trackCleanupTitles),
              ),
            ],
          ),
          PlatformMenuItemGroup(
            members: [
              PlatformMenuItem(
                label: t.menuTrackTranscode,
                shortcut:
                    MenuUtils.cmdShortcut(LogicalKeyboardKey.keyC, shift: true),
                onSelected: () => onMenuSelected(MenuAction.trackTranscode),
              ),
            ],
          ),
          PlatformMenuItemGroup(
            members: [
              PlatformMenuItem(
                label: t.menuEditDeleteSoft,
                shortcut: MenuUtils.cmdShortcut(LogicalKeyboardKey.backspace),
                onSelected: () => onMenuSelected(MenuAction.editDelete),
              ),
            ],
          ),
        ],
      ),
      PlatformMenu(
        label: t.menuView,
        menus: [
          PlatformMenuItemGroup(
            members: [
              PlatformMenuItem(
                label: t.menuTrackPrev,
                shortcut: MenuUtils.cmdShortcut(LogicalKeyboardKey.keyP),
                onSelected: () => onMenuSelected(MenuAction.trackPrevious),
              ),
              PlatformMenuItem(
                label: t.menuTrackNext,
                shortcut: MenuUtils.cmdShortcut(LogicalKeyboardKey.keyN),
                onSelected: () => onMenuSelected(MenuAction.trackNext),
              ),
            ],
          ),
        ],
      ),
      PlatformMenu(
        label: t.menuTools,
        menus: [
          PlatformMenuItemGroup(
            members: [
              PlatformMenuItem(
                label: t.menuToolsEdit,
                onSelected: () => onMenuSelected(MenuAction.toolsEdit),
              ),
            ],
          ),
          PlatformMenuItemGroup(
            members: [
              PlatformMenuItem(
                label: t.menuToolsTranscode,
                onSelected: () => onMenuSelected(MenuAction.toolsTranscode),
              ),
            ],
          ),
        ],
      ),
      PlatformMenu(
        label: t.menuHelp,
        menus: [],
      ),
    ];
  }

  // just fire
  void onMenuSelected(MenuAction action) {
    eventBus.fire(MenuActionEvent(action));
  }

  @override
  void onMenuAction(MenuAction action) {
    switch (action) {
      case MenuAction.appSettings:
        SettingsWidget.show(context);
        break;

      case MenuAction.fileImport:
        _import();
        break;

      case MenuAction.fileRefresh:
        _runScan();
        break;

      case MenuAction.fileRebuild:
        TraxDialog.confirm(
            context: context,
            text: AppLocalizations.of(context)!.rebuildConfirm,
            onConfirmed: (context) {
              Navigator.of(context).pop();
              TraxDatabase.of(context).clear();
              TraxDatabase.of(context).notify();
              eventBus.fire(SelectArtistAlbumEvent(null, null));
              _runScan();
            });
        break;

      case MenuAction.toolsEdit:
        _edit();
        break;

      case MenuAction.toolsTranscode:
        _transcode();
        break;

      default:
        break;
    }
  }

  void _edit() async {
    _pickAndEdit(EditorMode.editOnly);
  }

  void _transcode() async {
    _pickAndTranscode();
  }

  void _import() {
    _pickAndEdit(EditorMode.import);
  }

  void _pickAndEdit(EditorMode editorMode) async {
    // get some files
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: true,
      allowedExtensions: ['mp3', 'm4a', 'flac'],
    );
    if (result == null) return;

    // we need to parse them
    TrackList tracks = [];
    TagLib tagLib = TagLib();
    eventBus.fire(BackgroundActionStartEvent(BackgroundAction.import));
    for (String? filepath in result.paths) {
      if (filepath == null) continue;
      Track track = Track.parse(filepath, tagLib);
      tracks.add(track);
      await Future.delayed(Duration.zero, () {});
    }
    eventBus.fire(BackgroundActionEndEvent(BackgroundAction.import));

    // now show import
    // ignore: use_build_context_synchronously
    TagEditorWidget.show(
      context,
      editorMode,
      tracks,
      notify: true,
      onComplete: () {
        eventBus.fire(SelectArtistAlbumEvent(
          tracks.first.safeTags.artist,
          tracks.first.safeTags.album,
        ));
      },
    );
  }

  void _pickAndTranscode() async {
    // get some files
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: true,
      allowedExtensions: ['mp3', 'm4a', 'flac'],
    );
    if (result?.paths == null) return;

    // we need to parse them
    List<String> files = [];
    for (String? path in result!.paths) {
      if (path != null) files.add(path);
    }
    // ignore: use_build_context_synchronously
    TranscoderWidget.show(context, files: files);
  }

  void _runScan() async {
    // only one at a time
    if (isScanRunning()) {
      AppLocalizations t = AppLocalizations.of(context)!;
      TraxDialog.inform(
        context: context,
        message: t.scanRunningError,
      );
      return;
    }

    eventBus.fire(BackgroundActionStartEvent(BackgroundAction.scan));
    bool started = await runScan(
      Logger.of(context),
      Preferences.of(context).musicFolder,
      TraxDatabase.of(context),
      onUpdate: () => TraxDatabase.of(context).notify(),
      onComplete: () => eventBus.fire(
        BackgroundActionEndEvent(BackgroundAction.scan),
      ),
    );
    if (!started) {
      eventBus.fire(BackgroundActionEndEvent(BackgroundAction.scan));
    }
  }

  @override
  void onWindowMoved() async {
    if (!await windowManager.isFullScreen()) {
      _saveWindowBounds();
    }
  }

  @override
  void onWindowResized() async {
    if (!await windowManager.isFullScreen()) {
      _saveWindowBounds();
    }
  }

  void _saveWindowBounds() async {
    Rect rc = await windowManager.getBounds();
    // ignore: use_build_context_synchronously
    Preferences.of(context).windowBounds = rc;
  }
}
