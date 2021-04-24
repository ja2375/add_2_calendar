import 'dart:async';
import 'dart:io';

import 'package:add_2_calendar/src/model/event.dart';
import 'package:flutter/services.dart';

class Add2Calendar {
  static const MethodChannel _channel =
      const MethodChannel('flutter.javih.com/add_2_calendar');

  /// Add an Event (object) to user's default calendar.
  static Future<bool> addEvent2Cal(Event event) async {
    Map<String, dynamic> params = {
      'title': event.title,
      'desc': event.description,
      'location': event.location,
      'startDate': event.startDate.millisecondsSinceEpoch,
      'endDate': event.endDate.millisecondsSinceEpoch,
      'timeZone': event.timeZone,
      'allDay': event.allDay,
    };

    if (Platform.isIOS) {
      params['alarmInterval'] = event.iosParams.reminder?.inSeconds.toDouble();
    } else {
      // params['rRule'] = event.androidParams.rRule;
      // params['duration'] = event.androidParams.duration;
      params['noUI'] = event.androidParams.noUI;
      params['invites'] = event.androidParams.emailInvites?.join(",");
    }
    if (event.recurrence != null) {
      Map<String, dynamic> recurrence = {
        'frequency': event.recurrence!.frequency?.index,
        'ocurrences': event.recurrence!.ocurrences,
        'endDate': event.recurrence!.endDate?.millisecondsSinceEpoch,
        'interval': event.recurrence!.interval,
        'androidNoUIEventDuration': event.recurrence!.androidNoUIEventDuration,
        'rRule': event.recurrence!.rRule,
      };

      assert(
          !event.androidParams.noUI ||
              (event.androidParams.noUI &&
                  event.recurrence!.androidNoUIEventDuration != null),
          "Specify androidNoUIEventDuration when using noUI");

      params['recurrence'] = recurrence;
    }

    return _channel
        .invokeMethod<bool?>('add2Cal', params)
        .then((value) => value ?? false);
  }
}
