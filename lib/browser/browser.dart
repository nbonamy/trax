import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:macos_ui/macos_ui.dart';

import '../audioplayer/toolbar.dart';
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
  String _artist = Track.kArtistsHome;
  String? _initialAlbum;
  final StreamController<ActionInProgress?> _actionStream = StreamController();

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
                StreamBuilder(
                  stream: _actionStream.stream,
                  builder: (context, snapshot) {
                    if (snapshot.data != null) {
                      return StatusBarWidget(
                        message: snapshot.data!.statusMessage,
                        onStop: snapshot.data!.cancel,
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
      child: MacosScaffold(
        toolBar: const AudioPlayerToolBar(),
        children: [
          ContentArea(
            builder: (context, scrollController) => Container(
              color: CupertinoColors.white,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => SelectionModel.of(context).clear(),
                child: Builder(
                  builder: (context) {
                    if (_artist == Track.kArtistsHome) {
                      return DatabaseBuilder<bool>(
                        future: (database) => database.isEmpty,
                        builder: (context, database, isEmpty) => isEmpty
                            ? const WelcomeWidget()
                            : const StartWidget(),
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
            ),
          ),
        ],
      ),
    );

    return window;
  }

  void onSelectArtist(String? artist, {String? album}) {
    SelectionModel.of(context).clear(notify: false);
    setState(() {
      _artist = artist ?? Track.kArtistsHome;
      _initialAlbum = album;
    });
  }

  void onEvent(event) {
    // needed
    AppLocalizations t = AppLocalizations.of(context)!;
    if (event is BackgroundActionStartEvent) {
      switch (event.action) {
        case BackgroundAction.scan:
          _actionStream.sink.add(ActionInProgress(
            t.scanInProgress,
            cancel: stopScan,
          ));
          break;
        case BackgroundAction.import:
          _actionStream.sink.add(ActionInProgress(
            t.importInProgress,
          ));
          break;
        case BackgroundAction.save:
          _actionStream.sink.add(ActionInProgress(
            t.saveInProgress,
          ));
          break;
        case BackgroundAction.transcode:
          _actionStream.sink.add(ActionInProgress(
            t.transcodeInProgress(
              event.data['count'],
              event.data['index'],
            ),
            cancel: () => eventBus.fire(StopTranscodeEvent()),
          ));
          break;
      }
    } else if (event is BackgroundActionEndEvent) {
      _actionStream.sink.add(null);
    } else if (event is SelectArtistEvent) {
      onSelectArtist(event.artist);
    } else if (event is SelectArtistAlbumEvent) {
      onSelectArtist(event.artist, album: event.album);
    }
  }
}
