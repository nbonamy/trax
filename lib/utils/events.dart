import 'package:event_bus/event_bus.dart';

final EventBus eventBus = EventBus();

enum BackgroundAction { scan }

class BackgroundActionStartEvent {
  final BackgroundAction action;
  BackgroundActionStartEvent(this.action);
}

class BackgroundActionEndEvent {
  final BackgroundAction action;
  BackgroundActionEndEvent(this.action);
}
