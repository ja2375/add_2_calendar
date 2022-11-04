import 'dart:io';

import 'package:add_2_calendar/src/model/recurrence.dart';

/// Class that holds each event's info.
class Event {
  String title;
  String? description;
  String? location;
  String? timeZone;
  DateTime startDate;
  DateTime endDate;
  bool allDay;

  IOSParams iosParams;
  AndroidParams androidParams;
  Recurrence? recurrence;

  Event({
    required this.title,
    this.description,
    this.location,
    required this.startDate,
    required this.endDate,
    this.timeZone,
    this.allDay = false,
    this.iosParams = const IOSParams(),
    this.androidParams = const AndroidParams(),
    this.recurrence,
  });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> params = {
      'title': title,
      'desc': description,
      'location': location,
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate.millisecondsSinceEpoch,
      'timeZone': timeZone,
      'allDay': allDay,
      'recurrence': recurrence?.toJson(),
    };

    if (Platform.isIOS) {
      params['alarmInterval'] = iosParams.reminder?.inSeconds.toDouble();
      params['url'] = iosParams.url;
    } else {
      params['invites'] = androidParams.emailInvites?.join(",");
    }

    return params;
  }
}

class AndroidParams {
  final List<String>? emailInvites;

  const AndroidParams({this.emailInvites});
}

class IOSParams {
  //In iOS, you can set alert notification with duration. Ex. Duration(minutes:30) -> After30 min.
  final Duration? reminder;
  final String? url;

  const IOSParams({this.reminder, this.url});
}
