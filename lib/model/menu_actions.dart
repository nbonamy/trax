import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/events.dart';
import '../utils/platform_keyboard.dart';

enum MenuAction {
  appSettings,
  fileImport,
  fileRefresh,
  fileRebuild,
  fileReveal,
  editSelectAllAlbum,
  editSelectAllArtist,
  editPaste,
  editDelete,
  trackInfo,
  // trackPlay,
  trackPrevious,
  trackNext,
  toolsEdit,
}

class MenuUtils {
  static SingleActivator cmdShortcut(
    LogicalKeyboardKey key, {
    bool shift = false,
  }) {
    return SingleActivator(
      key,
      control: PlatformKeyboard.ctrlIsCommandModifier(),
      meta: PlatformKeyboard.metaIsCommandModifier(),
      shift: shift,
    );
  }
}

mixin MenuHandler {
  StreamSubscription? _menuSubscription;

  void initMenuSubscription() {
    _menuSubscription = eventBus.listenForMenuAction(onMenuAction);
  }

  void cancelMenuSubscription() {
    _menuSubscription?.cancel();
  }

  void onMenuAction(MenuAction action) {
    throw Exception(['Not implemented. You need to override.']);
  }
}
