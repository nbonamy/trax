import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:provider/provider.dart';

import '../components/search_box.dart';
import '../components/status_bar.dart';
import '../data/database.dart';
import '../model/menu_actions.dart';
import '../model/selection.dart';
import '../screens/start.dart';
import '../screens/welcome.dart';
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
  void dispose() {
    super.dispose();
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
          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => onSelectArtist(null),
            child: Column(
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
            ),
          );
        },
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => SelectionModel.of(context).clear(),
        child: _artist == null
            ? Consumer<TraxDatabase>(
                builder: (context, database, child) => database.isEmpty
                    ? const WelcomeWidget()
                    : const StartWidget(),
              )
            : BrowserContent(
                artist: _artist,
                menuActionStream: widget.menuActionStream,
              ),
      ),
    );

    return window;
  }

  void onSelectArtist(String? artist) {
    setState(() {
      SelectionModel.of(context).clear(notify: false);
      _artist = artist;
    });
  }

  void onEvent(event) {
    if (event is BackgroundActionStartEvent) {
      if (event.action == BackgroundAction.scan) {
        setState(() => _statusMessage = 'Scanning audio files');
      }
      if (event.action == BackgroundAction.import) {
        setState(() => _statusMessage = 'Parsing imported files');
      }
    } else if (event is BackgroundActionEndEvent) {
      setState(() => _statusMessage = null);
    } else if (event is SelectArtistEvent) {
      onSelectArtist(event.artist);
    }
  }
}
