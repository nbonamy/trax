import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PlatformKeyboard {
  static LogicalKeyboardKey get selectionExtendModifier {
    return LogicalKeyboardKey.shiftLeft;
  }

  static LogicalKeyboardKey get selectionToggleModifier {
    return Platform.isMacOS
        ? LogicalKeyboardKey.metaLeft
        : LogicalKeyboardKey.controlLeft;
  }

  static bool get selectionExtendActive {
    return RawKeyboard.instance.keysPressed
        .contains(PlatformKeyboard.selectionExtendModifier);
  }

  static bool get selectionToggleActive {
    return RawKeyboard.instance.keysPressed
        .contains(PlatformKeyboard.selectionToggleModifier);
  }

  static bool commandModifierPressed(RawKeyEvent event) {
    if (metaIsCommandModifier()) {
      return event.isMetaPressed;
    } else {
      return event.isControlPressed;
    }
  }

  static bool metaIsCommandModifier() {
    return Platform.isMacOS;
  }

  static bool ctrlIsCommandModifier() {
    return !metaIsCommandModifier();
  }

  static SingleActivator commandActivator(LogicalKeyboardKey key) {
    return SingleActivator(
      key,
      meta: PlatformKeyboard.metaIsCommandModifier(),
      control: PlatformKeyboard.ctrlIsCommandModifier(),
    );
  }
}
