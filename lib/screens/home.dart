import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../browser/browser.dart';

class TraxHomePage extends StatefulWidget {
  const TraxHomePage({super.key});

  @override
  State<TraxHomePage> createState() => _TraxHomePageState();
}

class _TraxHomePageState extends State<TraxHomePage> {
  final GlobalKey<BrowserWidgetState> _keyBrowser = GlobalKey();
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
          const PlatformProvidedMenuItem(
            type: PlatformProvidedMenuItemType.about,
          ),
          const PlatformProvidedMenuItem(
            type: PlatformProvidedMenuItemType.quit,
          ),
        ],
      ),
      // PlatformMenu(
      //   label: t.menuFile,
      //   menus: [
      //     // PlatformMenuItem(
      //     //   label: t.menuFileRefresh,
      //     //   shortcut: MenuUtils.cmdShortcut(LogicalKeyboardKey.keyR),
      //     //   onSelected: () => _onMenu(MenuAction.fileRefresh),
      //     // ),
      //     // PlatformMenuItem(
      //     //   label: t.menuFileRename,
      //     //   //shortcut: const SingleActivator(LogicalKeyboardKey.enter),
      //     //   onSelected: () => _onMenu(MenuAction.fileRename),
      //     // ),
      //   ],
      // ),
      // PlatformMenu(
      //   label: t.menuEdit,
      //   menus: [
      //     const PlatformMenuItemGroup(
      //       members: [
      //         // PlatformMenuItem(
      //         //   label: t.menuEditSelectAll,
      //         //   shortcut: MenuUtils.cmdShortcut(LogicalKeyboardKey.keyA),
      //         //   onSelected: () => _onMenu(MenuAction.editSelectAll),
      //         // ),
      //       ],
      //     ),
      //     const PlatformMenuItemGroup(
      //       members: [
      //         // PlatformMenuItem(
      //         //   label: t.menuEditCopy,
      //         //   shortcut: MenuUtils.cmdShortcut(LogicalKeyboardKey.keyC),
      //         //   onSelected: () => _onMenu(MenuAction.editCopy),
      //         // ),
      //         // PlatformMenuItem(
      //         //   label: t.menuEditPaste,
      //         //   shortcut: MenuUtils.cmdShortcut(LogicalKeyboardKey.keyV),
      //         //   onSelected: () => _onMenu(MenuAction.editPaste),
      //         // ),
      //         // PlatformMenuItem(
      //         //   label: t.menuEditPasteMove,
      //         //   shortcut: SingleActivator(
      //         //     LogicalKeyboardKey.keyV,
      //         //     alt: true,
      //         //     control: PlatformKeyboard.ctrlIsCommandModifier(),
      //         //     meta: PlatformKeyboard.metaIsCommandModifier(),
      //         //   ),
      //         //   onSelected: () => _onMenu(MenuAction.editPasteMove),
      //         // ),
      //         // PlatformMenuItem(
      //         //   label: t.menuEditDelete,
      //         //   shortcut: MenuUtils.cmdShortcut(LogicalKeyboardKey.backspace),
      //         //   onSelected: () => _onMenu(MenuAction.editDelete),
      //         // ),
      //       ],
      //     ),
      //   ],
      // ),
      // PlatformMenu(
      //   label: t.menuImage,
      //   menus: [
      //     const PlatformMenuItemGroup(
      //       members: [
      //         // PlatformMenuItem(
      //         //   label: t.menuImageView,
      //         //   shortcut: const SingleActivator(LogicalKeyboardKey.enter),
      //         //   onSelected: () => _onMenu(MenuAction.imageView),
      //         // ),
      //       ],
      //     ),
      //     PlatformMenu(
      //       label: t.menuImageTransform,
      //       menus: [
      //         // PlatformMenuItem(
      //         //   label: t.menuImageRotate90CW,
      //         //   shortcut: MenuUtils.cmdShortcut(LogicalKeyboardKey.arrowRight),
      //         //   onSelected: () => _onMenu(MenuAction.imageRotate90cw),
      //         // ),
      //         // PlatformMenuItem(
      //         //   label: t.menuImageRotate90CCW,
      //         //   shortcut: MenuUtils.cmdShortcut(LogicalKeyboardKey.arrowLeft),
      //         //   onSelected: () => _onMenu(MenuAction.imageRotate90ccw),
      //         // ),
      //         // PlatformMenuItem(
      //         //   label: t.menuImageRotate180,
      //         //   shortcut: MenuUtils.cmdShortcut(LogicalKeyboardKey.arrowDown),
      //         //   onSelected: () => _onMenu(MenuAction.imageRotate180),
      //         // ),
      //       ],
      //     ),
      //   ],
      // ),
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
}
