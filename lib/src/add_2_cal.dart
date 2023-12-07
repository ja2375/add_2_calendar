import 'dart:async';

import 'package:add_2_calendar/src/model/event.dart';
import 'package:add_2_calendar/src/model/result.dart';
import 'package:flutter/services.dart';

class Add2Calendar {
  static const MethodChannel _channel = MethodChannel('add_2_calendar');

  /// Add an Event (object) to user's default calendar.
  static Future<Add2CalendarResult> addEvent2Cal(Event event) async {
    return _channel
        .invokeMethod<String>('add2Cal', event.toJson())
        .then((value) => Add2CalendarResult.values.byName(value!));
  }
}
