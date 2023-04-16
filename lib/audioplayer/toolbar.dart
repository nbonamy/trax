import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';

import 'widget.dart';

class AudioPlayerToolBar extends ToolBar {
  const AudioPlayerToolBar({Key? key})
      : super(
          key: key,
          height: 52,
          padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 16),
          decoration: const BoxDecoration(color: CupertinoColors.white),
          titleWidth: double.infinity,
          title: const AudioPlayerWidget(),
          centerTitle: true,
        );
}
