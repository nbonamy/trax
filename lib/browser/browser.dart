import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';

import '../components/database_builder.dart';
import '../components/search_box.dart';
import '../components/status_bar.dart';
import '../model/selection.dart';
import '../model/track.dart';
import '../screens/start.dart';
import '../screens/welcome.dart';
import '../utils/consts.dart';
import '../utils/events.dart';
import 'content.dart';
import 'sidebar.dart';

class BrowserWidget extends StatefulWidget {
  const BrowserWidget({super.key});

  @override
  State<BrowserWidget> createState() => BrowserWidgetState();
}

class BrowserWidgetState extends State<BrowserWidget> {
  String? _artist;
  String? _initialAlbum;
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
        child: DatabaseBuilder<bool>(
          future: (database) async {
            if (_artist == null) return false;
            if (_artist == Track.kArtistCompilations) return true;
            return database.artistExists(_artist!);
          },
          builder: (context, database, exists) {
            if (!exists) {
              return FutureBuilder<bool>(
                  future: database.isEmpty,
                  builder: (context, snapshot) =>
                      (snapshot.hasData == false || snapshot.data!)
                          ? const WelcomeWidget()
                          : const StartWidget());
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
    setState(() {
      SelectionModel.of(context).clear(notify: false);
      _artist = artist;
      _initialAlbum = album;
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
    } else if (event is SelectArtistAlbumEvent) {
      onSelectArtist(event.artist, album: event.album);
    }
  }
}
