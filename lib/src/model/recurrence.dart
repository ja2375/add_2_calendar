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

  /// Specifies the days of the week where the recurrence rule repeats.
  final List<String>? days;

  /// (Android only) If you have a specific rule that cannot be matched with current parameters, you can specify a RRULE in RFC5545 format
  final String? rRule;
  Recurrence({
    required this.frequency,
    this.ocurrences,
    this.endDate,
    this.days,
    this.interval = 1,
    this.rRule,
  }) : assert(ocurrences == null || endDate == null,
            "Specify either ocurrences or endDate");

  Map<String, dynamic> toJson() => {
        'frequency': frequency?.index,
        'ocurrences': ocurrences,
        'endDate': endDate?.millisecondsSinceEpoch,
        'interval': interval,
        'rRule': rRule,
        'days': days,
      };
}
