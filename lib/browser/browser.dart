import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:trax/l10n/app_localizations.dart';
import 'package:macos_ui/macos_ui.dart';

import '../audioplayer/glass_player.dart';
import '../components/database_builder.dart';
import '../components/inspector.dart';
import '../components/pill_button.dart';
import '../components/search_box.dart';
import '../components/status_bar.dart';
import '../components/trax_colors.dart';
import '../model/library_health.dart';
import '../model/selection.dart';
import '../model/track.dart';
import '../processors/scanner.dart';
import '../screens/start.dart';
import '../screens/welcome.dart';
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

  // what is searched, or reviewed, instead of an artist
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;
  String _query = '';
  ReviewKind? _review;

  final StreamController<ActionInProgress?> _actionStream = StreamController();

  bool get _searching => _query.isNotEmpty;
  bool get _showingHome =>
      _artist == Track.kArtistsHome && !_searching && _review == null;

  @override
  void initState() {
    super.initState();
    eventBus.on().listen(onEvent);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TraxColors colors = TraxColors.of(context);
    Widget window = MacosWindow(
      sidebar: Sidebar(
        minWidth: 240,
        padding: const EdgeInsets.fromLTRB(10, 16, 10, 10),
        decoration: BoxDecoration(color: colors.sidebar),
        top: SearchBoxWidget(
          controller: _searchController,
          onChanged: _onSearchChanged,
        ),
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
                    artist: (_searching || _review != null) ? '_' : _artist,
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
        toolBar: ToolBar(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 4),
          automaticallyImplyLeading: false,
          leading: _showingHome
              ? null
              : Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: PillButton(
                    label: AppLocalizations.of(context)!.back,
                    icon: CupertinoIcons.chevron_back,
                    style: PillStyle.plain,
                    onPressed: () => onSelectArtist(null),
                  ),
                ),
          decoration: BoxDecoration(color: colors.background),
          dividerColor: const Color(0x00000000),
        ),
        children: [
          ContentArea(
            builder: (context, scrollController) => Container(
              color: colors.background,
              child: Row(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () => SelectionModel.of(context).clear(),
                            child: Builder(
                              builder: (context) {
                                if (_showingHome) {
                                  return DatabaseBuilder<bool>(
                                    future: (database) => database.isEmpty,
                                    builder: (context, database, isEmpty) =>
                                        isEmpty
                                            ? const WelcomeWidget()
                                            : const StartWidget(),
                                  );
                                } else {
                                  final bool collection =
                                      _searching || _review != null;
                                  return BrowserContent(
                                    artist: collection ? null : _artist,
                                    initialAlbum: _initialAlbum,
                                    query: _review == null ? _query : null,
                                    review: _review,
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                        const Positioned(
                          left: 0,
                          right: 0,
                          bottom: 24,
                          child: GlassPlayerBar(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    // the inspector is a drawer on its own: it runs the full height of the
    // window, up to the title bar, while the toolbar stops at its edge
    return Row(
      children: [
        Expanded(child: window),
        if (!_showingHome) const InspectorPanel(),
      ],
    );
  }

  void onSelectArtist(String? artist, {String? album}) {
    SelectionModel.of(context).clear(notify: false);
    _searchDebounce?.cancel();
    _searchController.clear();
    setState(() {
      _artist = artist ?? Track.kArtistsHome;
      _initialAlbum = album;
      _query = '';
      _review = null;
    });
  }

  // filter as you type: a short pause lets fast typists finish the word
  void _onSearchChanged(String text) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 180), () {
      if (!mounted) return;
      final String query = text.trim();
      if (query == _query) return;
      SelectionModel.of(context).clear(notify: false);
      setState(() {
        _query = query;
        _review = null;
        _initialAlbum = null;
      });
    });
  }

  void _showReview(ReviewKind kind) {
    SelectionModel.of(context).clear(notify: false);
    _searchDebounce?.cancel();
    _searchController.clear();
    setState(() {
      _query = '';
      _review = kind;
      _initialAlbum = null;
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
      Future.delayed(Duration.zero, () {});
    } else if (event is BackgroundActionEndEvent) {
      _actionStream.sink.add(null);
      Future.delayed(Duration.zero, () {});
    } else if (event is SelectArtistEvent) {
      onSelectArtist(event.artist);
    } else if (event is SelectArtistAlbumEvent) {
      onSelectArtist(event.artist, album: event.album);
    } else if (event is ShowReviewEvent) {
      _showReview(event.kind);
    }
  }
}
