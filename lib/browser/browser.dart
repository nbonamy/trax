import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';

import '../components/search_box.dart';
import '../components/status_bar.dart';
import '../model/menu_actions.dart';
import '../model/selection.dart';
import '../utils/consts.dart';
import '../utils/events.dart';
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
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    eventBus.on().listen(onEvent);
  }

  @override
  Widget build(BuildContext context) {
    Widget window = MacosWindow(
      backgroundColor: Colors.white,
      sidebar: Sidebar(
        minWidth: 250,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(color: Consts.sideBarBgColor),
        top: const SearchBoxWidget(),
        builder: (context, controller) {
          return Column(
            children: [
              Expanded(
                child: BrowserSidebar(
                  scrollController: controller,
                  onSelectArtist: onSelectArtist,
                  artist: _artist,
                ),
              ),
              if (_statusMessage != null)
                StatusBarWidget(message: _statusMessage!)
            ],
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

  void onEvent(event) {
    if (event is BackgroundActionStartEvent &&
        event.action == BackgroundAction.scan) {
      setState(() => _statusMessage = 'Scanning audio files');
    }
    if (event is BackgroundActionEndEvent &&
        event.action == BackgroundAction.scan) {
      setState(() => _statusMessage = null);
    }
  }
}
