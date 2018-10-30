# add_2_calendar

A really simple Flutter plugin to add events to each platform's default calendar.

## Installation

In your `pubspec.yaml` file within your Flutter Project: 

```yaml
dependencies:
  add_2_calendar: ^1.0.0
```

## Use it

```dart
import 'package:add_2_calendar/add_2_calendar.dart';

final Event event = Event(
      title: 'Event title',
      description: 'Event description',
      location: 'Event location',
      startDate: DateTime(/* Some date here */),
      endDate: DateTime(/* Some date here */),
    );
...
Add2Calendar.addEvent2Cal(event);
...
```

## Example

Please run the app in the `example/` folder to start playing!

