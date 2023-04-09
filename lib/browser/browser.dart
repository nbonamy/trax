import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';

import '../model/menu_actions.dart';
import '../model/selection.dart';
import 'content.dart';
import 'sidebar.dart';

class BrowserWidget extends StatefulWidget {
  final Stream<MenuAction> menuActionStream;
  const BrowserWidget({super.key, required this.menuActionStream});

  @override
  State<BrowserWidget> createState() => BrowserWidgetState();
}

class BrowserWidgetState extends State<BrowserWidget> {
  String? _artist;
  @override
  Widget build(BuildContext context) {
    Widget window = MacosWindow(
      backgroundColor: Colors.white,
      sidebar: Sidebar(
        minWidth: 250,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Color.fromRGBO(237, 231, 230, 1.0),
        ),
        builder: (context, controller) {
          return BrowserSidebar(
            scrollController: controller,
            onSelectArtist: onSelectArtist,
            artist: _artist,
          );
        },
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => SelectionModel.of(context).clear(),
        child: BrowserContent(
          artist: _artist,
          menuActionStream: widget.menuActionStream,
        ),
      ),
    );

    return window;
  }

  void onSelectArtist(String artist) {
    setState(() {
      SelectionModel.of(context).clear(notify: false);
      _artist = artist;
    });
  }
}
