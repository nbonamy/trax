import 'package:contextual_menu/contextual_menu.dart' as ncm;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

typedef BoolCallback = bool Function();

class Menu extends ncm.Menu {
  Menu({
    super.items,
  });
}

class ShortcutModifier extends ncm.ShortcutModifiers {
  ShortcutModifier({
    super.shift,
    super.control,
    super.command,
    super.alt,
  });
}

class MenuItem extends ncm.MenuItem {
  MenuItem.separator() : super.separator();

  MenuItem.submenu({String? label, Menu? submenu})
      : super.submenu(
          label: label,
          submenu: submenu,
        );

  MenuItem({
    super.key,
    super.type = 'normal',
    super.label,
    super.sublabel,
    super.toolTip,
    super.icon,
    super.checked,
    super.disabled = false,
    super.shortcutKey,
    super.shortcutModifiers,
    super.submenu,
    super.onClick,
  });
}

class ContextMenu extends StatefulWidget {
  final Menu menu;
  final ncm.Placement placement;
  final BoolCallback? onBeforeShowMenu;
  final Widget child;

  const ContextMenu({
    Key? key,
    required this.menu,
    this.placement = ncm.Placement.bottomRight,
    this.onBeforeShowMenu,
    required this.child,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ContextMenuState();
}

class _ContextMenuState extends State<ContextMenu> {
  bool _shouldReact = false;
  bool _shouldWait = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) {
        _shouldReact = (event.kind == PointerDeviceKind.mouse &&
            event.buttons == kSecondaryMouseButton);
        if (_shouldReact && widget.onBeforeShowMenu != null) {
          _shouldWait = widget.onBeforeShowMenu!();
        }
      },
      onPointerUp: (event) async {
        if (!_shouldReact) return;
        if (_shouldWait) {
          Future.delayed(const Duration(milliseconds: 100), () {
            _handleClickPopUp(event.position);
          });
        } else {
          _handleClickPopUp(event.position);
        }
      },
      child: widget.child,
    );
  }

  void _handleClickPopUp(Offset position) {
    ncm.popUpContextualMenu(
      widget.menu,
      position: position,
      placement: widget.placement,
    );
  }
}
