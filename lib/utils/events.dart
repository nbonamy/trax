import 'package:event_bus/event_bus.dart';

final EventBus eventBus = EventBus();

enum BackgroundAction { scan, import }

class BackgroundActionStartEvent {
  final BackgroundAction action;
  BackgroundActionStartEvent(this.action);
}

class BackgroundActionEndEvent {
  final BackgroundAction action;
  BackgroundActionEndEvent(this.action);
}

class SelectArtistEvent {
  final String artist;
  SelectArtistEvent(this.artist);
}

class SelectArtistAlbumEvent {
  final String artist;
  final String album;
  SelectArtistAlbumEvent(this.artist, this.album);
}
