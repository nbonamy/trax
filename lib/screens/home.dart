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
import 'settings.dart';

class TraxHomePage extends StatefulWidget {
  const TraxHomePage({super.key});

  @override
  State<TraxHomePage> createState() => _TraxHomePageState();
}

class _TraxHomePageState extends State<TraxHomePage> with WindowListener {
  final GlobalKey<BrowserWidgetState> _keyBrowser = GlobalKey();
  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
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
                onSelected: () => _onMenu(MenuAction.appSettings),
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
                onSelected: () => _onMenu(MenuAction.fileImport),
              ),
            ],
          ),
          PlatformMenuItemGroup(
            members: [
              PlatformMenuItem(
                label: t.menuFileRefresh,
                shortcut: MenuUtils.cmdShortcut(LogicalKeyboardKey.keyR),
                onSelected: () => _onMenu(MenuAction.fileRefresh),
              ),
              PlatformMenuItem(
                label: t.menuFileRebuild,
                shortcut: MenuUtils.cmdShortcut(
                  LogicalKeyboardKey.keyR,
                  shift: true,
                ),
                onSelected: () => _onMenu(
                  MenuAction.fileRebuild,
                ),
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
                onSelected: () => _onMenu(MenuAction.editPaste),
              ),
            ],
          ),
          PlatformMenuItemGroup(
            members: [
              PlatformMenuItem(
                label: t.menuEditSelectAll,
                shortcut: MenuUtils.cmdShortcut(LogicalKeyboardKey.keyA),
                onSelected: () => _onMenu(MenuAction.editSelectAll),
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
                onSelected: () => _onMenu(MenuAction.trackInfo),
              ),
            ],
          ),
          PlatformMenuItemGroup(
            members: [
              PlatformMenuItem(
                label: t.menuEditDelete,
                shortcut: MenuUtils.cmdShortcut(LogicalKeyboardKey.backspace),
                onSelected: () => _onMenu(MenuAction.editDelete),
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
                onSelected: () => _onMenu(MenuAction.trackPrevious),
              ),
              PlatformMenuItem(
                label: t.menuTrackNext,
                shortcut: MenuUtils.cmdShortcut(LogicalKeyboardKey.keyN),
                onSelected: () => _onMenu(MenuAction.trackNext),
              ),
            ],
          ),
        ],
      ),
    ];
  }

  void _onMenu(MenuAction action) async {
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
        TraxDatabase.of(context).clear();
        TraxDatabase.of(context).notify();
        eventBus.fire(SelectArtistAlbumEvent(null, null));
        _runScan();
        break;

      default:
        eventBus.fire(MenuActionEvent(action));
        break;
    }
  }

  void _import() async {
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
      EditorMode.import,
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
