import 'package:event_bus/event_bus.dart';

EventBus eventBus = new EventBus();
enum DataEventType {
  HomeDialed,
}

class DataEventHome {
  // final DataEventType type;
  final String from;
  final String to;
  DataEventHome({this.from, this.to});
}
