import 'dart:async';

import 'package:event_bus/event_bus.dart';

import '../model/menu_actions.dart';

extension MenuBus on EventBus {
  StreamSubscription listenForMenuAction(Function f) {
    return on<MenuActionEvent>().listen((event) => f(event.action));
  }
}

final EventBus eventBus = EventBus();

enum BackgroundAction { scan, import, save, transcode }

class BackgroundActionStartEvent {
  final BackgroundAction action;
  final Map<String, dynamic> data;
  BackgroundActionStartEvent(this.action, {this.data = const {}});
}

class BackgroundActionEndEvent {
  final BackgroundAction action;
  BackgroundActionEndEvent(this.action);
}

class MenuActionEvent {
  final MenuAction action;
  MenuActionEvent(this.action);
}

class SelectArtistEvent {
  final String artist;
  SelectArtistEvent(this.artist);
}

class SelectArtistAlbumEvent {
  final String? artist;
  final String? album;
  SelectArtistAlbumEvent(this.artist, this.album);
}

class StopTranscodeEvent {}
