import 'dart:async';

import 'package:add_2_calendar/src/model/event.dart';
import 'package:flutter/services.dart';

class Add2Calendar {
  static const MethodChannel _channel = const MethodChannel('add_2_calendar');

  /// Add an Event (object) to user's default calendar.
  static Future<bool> addEvent2Cal(Event event) async {
    return _channel
        .invokeMethod<bool?>('add2Cal', event.toJson())
        .then((value) => value ?? false);
  }
}
