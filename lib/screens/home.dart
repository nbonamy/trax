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
                onSelected: () => onMenuAction(MenuAction.appSettings),
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
                onSelected: () => onMenuAction(MenuAction.fileImport),
              ),
            ],
          ),
          PlatformMenuItemGroup(
            members: [
              PlatformMenuItem(
                label: t.menuFileRefresh,
                shortcut: MenuUtils.cmdShortcut(LogicalKeyboardKey.keyR),
                onSelected: () => onMenuAction(MenuAction.fileRefresh),
              ),
              PlatformMenuItem(
                label: t.menuFileRebuild,
                onSelected: () => onMenuAction(
                  MenuAction.fileRebuild,
                ),
              ),
            ],
          ),
          PlatformMenuItemGroup(
            members: [
              PlatformMenuItem(
                label: t.menuFileReveal,
                shortcut:
                    MenuUtils.cmdShortcut(LogicalKeyboardKey.keyR, shift: true),
                onSelected: () => onMenuAction(MenuAction.fileReveal),
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
                onSelected: () => onMenuAction(MenuAction.editPaste),
              ),
            ],
          ),
          PlatformMenuItemGroup(
            members: [
              PlatformMenuItem(
                label: t.menuEditSelectAllAlbum,
                shortcut: MenuUtils.cmdShortcut(LogicalKeyboardKey.keyA),
                onSelected: () => onMenuAction(MenuAction.editSelectAllAlbum),
              ),
              PlatformMenuItem(
                label: t.menuEditSelectAllArtist,
                shortcut:
                    MenuUtils.cmdShortcut(LogicalKeyboardKey.keyA, shift: true),
                onSelected: () => onMenuAction(MenuAction.editSelectAllArtist),
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
                onSelected: () => onMenuAction(MenuAction.trackInfo),
              ),
            ],
          ),
          // PlatformMenuItemGroup(
          //   members: [
          //     PlatformMenuItem(
          //       label: t.menuTrackPlay,
          //       onSelected: () => _onMenu(MenuAction.trackPlay),
          //     ),
          //   ],
          // ),
          PlatformMenuItemGroup(
            members: [
              PlatformMenuItem(
                label: t.menuEditDelete,
                shortcut: MenuUtils.cmdShortcut(LogicalKeyboardKey.backspace),
                onSelected: () => onMenuAction(MenuAction.editDelete),
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
                onSelected: () => onMenuAction(MenuAction.trackPrevious),
              ),
              PlatformMenuItem(
                label: t.menuTrackNext,
                shortcut: MenuUtils.cmdShortcut(LogicalKeyboardKey.keyN),
                onSelected: () => onMenuAction(MenuAction.trackNext),
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
                onSelected: () => onMenuAction(MenuAction.toolsEdit),
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

  @override
  void onMenuAction(MenuAction action) async {
    switch (action) {
      case MenuAction.appSettings:
        SettingsWidget.show(context);
        break;

      case MenuAction.toolsEdit:
        _edit();
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

      default:
        eventBus.fire(MenuActionEvent(action));
        break;
    }
  }

  void _edit() async {
    _pickAndEdit(EditorMode.editOnly);
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
      () {
        TraxDatabase.of(context).notify();
      },
      () {
        TraxDatabase.of(context).notify();
        eventBus.fire(BackgroundActionEndEvent(BackgroundAction.scan));
      },
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
