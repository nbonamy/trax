import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../browser/browser.dart';
import '../data/database.dart';
import '../model/menu_actions.dart';
import '../model/preferences.dart';
import '../processors/scanner.dart';
import '../utils/events.dart';

class TraxHomePage extends StatefulWidget {
  const TraxHomePage({super.key});

  @override
  State<TraxHomePage> createState() => _TraxHomePageState();
}

class _TraxHomePageState extends State<TraxHomePage> with WindowListener {
  final GlobalKey<BrowserWidgetState> _keyBrowser = GlobalKey();
  final MenuActionController _menuActionStream =
      MenuActionController.broadcast();
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
        menuActionStream: _menuActionStream.stream,
      ),
    );
  }

  List<PlatformMenuItem> _getMainMenu(BuildContext context) {
    AppLocalizations t = AppLocalizations.of(context)!;
    return [
      PlatformMenu(
        label: t.appName,
        menus: [
          const PlatformProvidedMenuItem(
            type: PlatformProvidedMenuItemType.about,
          ),
          const PlatformProvidedMenuItem(
            type: PlatformProvidedMenuItemType.quit,
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
                label: t.menuEditSelectAll,
                shortcut: MenuUtils.cmdShortcut(LogicalKeyboardKey.keyA),
                onSelected: () => _onMenu(MenuAction.editSelectAll),
              ),
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
        label: t.menuTrack,
        menus: [
          PlatformMenuItemGroup(
            members: [
              PlatformMenuItem(
                label: t.menuTrackInfo,
                shortcut: MenuUtils.cmdShortcut(LogicalKeyboardKey.keyI),
                onSelected: () => _onMenu(MenuAction.trackInfo),
              ),
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
      // PlatformMenu(
      //   label: t.menuView,
      //   menus: [
      //     // PlatformMenuItem(
      //     //   label: t.menuViewInspector,
      //     //   shortcut: MenuUtils.cmdShortcut(LogicalKeyboardKey.keyI),
      //     //   onSelected: () => _onMenu(MenuAction.viewInspector),
      //     // ),
      //   ],
      // ),
    ];
  }

  void _onMenu(MenuAction action) async {
    switch (action) {
      case MenuAction.fileImport:
        _runImport();
        break;

      case MenuAction.fileRefresh:
        _runScan();
        break;

      case MenuAction.fileRebuild:
        TraxDatabase.of(context).clear();
        TraxDatabase.of(context).notify();
        _runScan();
        break;

      default:
        _menuActionStream.sink.add(action);
        break;
    }
  }

  void _runImport() {}

  void _runScan() {
    eventBus.fire(BackgroundActionStartEvent(BackgroundAction.scan));
    runScan(
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
