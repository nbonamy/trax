import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';

import '../components/database_builder.dart';
import '../components/search_box.dart';
import '../components/status_bar.dart';
import '../model/selection.dart';
import '../model/track.dart';
import '../processors/scanner.dart';
import '../screens/start.dart';
import '../screens/welcome.dart';
import '../utils/consts.dart';
import '../utils/events.dart';
import 'content.dart';
import 'sidebar.dart';

class ActionInProgress {
  final String statusMessage;
  final Function? cancel;
  ActionInProgress(this.statusMessage, {this.cancel});
}

class BrowserWidget extends StatefulWidget {
  const BrowserWidget({super.key});

  @override
  State<BrowserWidget> createState() => BrowserWidgetState();
}

class BrowserWidgetState extends State<BrowserWidget> {
  String? _artist;
  String? _initialAlbum;
  ActionInProgress? _actionInProgress;

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
                if (_actionInProgress != null)
                  StatusBarWidget(
                    message: _actionInProgress!.statusMessage,
                    onStop: _actionInProgress!.cancel,
                  )
              ],
            ),
          );
        },
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => SelectionModel.of(context).clear(),
        child: Builder(
          builder: (context) {
            if (_artist == null || _artist == Track.kArtistsHome) {
              return DatabaseBuilder<bool>(
                future: (database) => database.isEmpty,
                builder: (context, database, isEmpty) =>
                    isEmpty ? const WelcomeWidget() : const StartWidget(),
              );
            } else {
              return BrowserContent(
                artist: _artist,
                initialAlbum: _initialAlbum,
              );
            }
          },
        ),
      ),
    );

    return window;
  }

  void onSelectArtist(String? artist, {String? album}) {
    SelectionModel.of(context).clear(notify: false);
    setState(() {
      _artist = artist;
      _initialAlbum = album;
    });
  }

  void onEvent(event) {
    if (event is BackgroundActionStartEvent) {
      if (event.action == BackgroundAction.scan) {
        setState(
          () => _actionInProgress = ActionInProgress(
            'Scanning audio files',
            cancel: stopScan,
          ),
        );
      }
      if (event.action == BackgroundAction.import) {
        setState(
          () => _actionInProgress = ActionInProgress('Parsing imported files'),
        );
      }
    } else if (event is BackgroundActionEndEvent) {
      setState(() => _actionInProgress = null);
    } else if (event is SelectArtistEvent) {
      onSelectArtist(event.artist);
    } else if (event is SelectArtistAlbumEvent) {
      onSelectArtist(event.artist, album: event.album);
    }
  }
}
