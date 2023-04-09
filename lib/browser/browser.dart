import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';

import 'content.dart';
import 'sidebar.dart';

class BrowserWidget extends StatefulWidget {
  const BrowserWidget({super.key});

  @override
  State<BrowserWidget> createState() => BrowserWidgetState();
}

class BrowserWidgetState extends State<BrowserWidget> {
  String? _artist;
  @override
  Widget build(BuildContext context) {
    Widget window = MacosWindow(
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
      child: BrowserContent(
        artist: _artist,
      ),
    );

    return window;
  }

  void onSelectArtist(String artist) {
    setState(() {
      _artist = artist;
    });
  }
}
