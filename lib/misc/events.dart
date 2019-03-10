import 'package:daily_pics/misc/bean.dart';
import 'package:event_bus/event_bus.dart';

EventBus eventBus = EventBus();

class OnPageChangedEvent {
  final int value;

  OnPageChangedEvent(this.value);
}

class ReceivedDataEvent {
  final int from;
  final Picture data;

  ReceivedDataEvent(this.from, this.data);
}
