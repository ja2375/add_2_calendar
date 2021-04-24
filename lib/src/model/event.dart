/// Class that holds each event's info.
class Event {
  String title, description, location;
  String? timeZone;
  DateTime startDate, endDate;
  bool allDay;

  IOSParams iosParams;
  AndroidParams androidParams;
  Recurrence? recurrence;

  Event({
    required this.title,
    this.description = '',
    this.location = '',
    required this.startDate,
    required this.endDate,
    this.timeZone,
    this.allDay = false,
    this.iosParams = const IOSParams(),
    this.androidParams = const AndroidParams(),
    this.recurrence,
  });
}

class AndroidParams {
  final bool noUI;
  // final String? rRule;
  // final String? duration;
  final List<String>? emailInvites;

  const AndroidParams({
    // this.rRule,
    // this.duration,
    this.noUI = false,
    this.emailInvites,
  });
}

class IOSParams {
  //In iOS, you can set alert notification with duration. Ex. Duration(minutes:30) -> After30 min.
  final Duration? reminder;
  const IOSParams({this.reminder});
}

enum Frequency {
  /*not available on iOS: secondly, minutely, hourly, */
  daily,
  weekly,
  monthly,
  yearly
}

class Recurrence {
  /// The frequency of the recurrence rule.
  final Frequency? frequency;

  /// Indicates the numer of ocurrences until the rule ends.
  final int? ocurrences;

  /// Indicates when the recurrence rule ends.
  final DateTime? endDate;

  /// Specifies how often the recurrence rule repeats over the unit of time indicated by its frequency.
  final int interval;

  /// (required only on android noUI) The duration of the event in RFC5545 format. For example, a value of "PT1H" states that the event should last one hour, and a value of "P2W" indicates a duration of 2 weeks. This will ignore the original event duration
  final String? androidNoUIEventDuration;

  /// (Android only) If you have a specific rule that cannot be matched with current parameters, you can specify a RRULE in RFC5545 format
  final String? rRule;
  Recurrence({
    required this.frequency,
    this.ocurrences,
    this.endDate,
    this.androidNoUIEventDuration,
    this.interval = 1,
    this.rRule,
  }) : assert(ocurrences == null || endDate == null,
            "Specify either ocurrences or endDate");
}
