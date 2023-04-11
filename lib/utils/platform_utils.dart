import 'dart:async';

import 'package:flutter/services.dart';

class PlatformUtils {
  static const MethodChannel _mChannel =
      MethodChannel('platform_utils/messages');

  static Future<void> moveToTrash(String filepath) async {
    _mChannel.invokeMethod('moveToTrash', filepath);
  }
}
