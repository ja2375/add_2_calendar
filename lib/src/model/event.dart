import 'package:flutter/foundation.dart';

/// Class that holds each event's info.
class Event {
  String title, description, location, timeZone;
  DateTime startDate, endDate;
  bool allDay;
  //In iOS, you can set alert notification with duration. Ex. Duration(minutes:30) -> After30 min.
  Duration? alarmInterval;

  Event({
    required this.title,
    this.description = '',
    this.location = '',
    required this.startDate,
    required this.endDate,
    this.alarmInterval,
    this.timeZone = '',
    this.allDay = false,
  });
}
