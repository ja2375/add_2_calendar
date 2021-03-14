import 'dart:async';

import 'package:add_2_calendar/src/model/event.dart';
import 'package:flutter/services.dart';

class Add2Calendar {
  static const MethodChannel _channel =
      const MethodChannel('flutter.javih.com/add_2_calendar');

  /// Add an Event (object) to user's default calendar.
  static Future<bool?> addEvent2Cal(Event event) async {
    final bool? isAdded =
        await _channel.invokeMethod('add2Cal', <String, dynamic>{
      'title': event.title,
      'desc': event.description,
      'location': event.location,
      'startDate': event.startDate.millisecondsSinceEpoch,
      'endDate': event.endDate.millisecondsSinceEpoch,
      'timeZone': event.timeZone,
      'alarmInterval': event.alarmInterval?.inSeconds?.toDouble(),
      'allDay': event.allDay,
    });
    return isAdded;
  }
}
