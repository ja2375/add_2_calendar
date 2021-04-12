# add_2_calendar

A really simple Flutter plugin to add events to each platform's default calendar.

## Installation

In your `pubspec.yaml` file within your Flutter Project: 

```yaml
dependencies:
  add_2_calendar: ^2.0.1
```
### Android integration
The plugin doesn't need any special permissions by default to add events to the calendar. However, events can also be added without launching the calendar application, for this it is needed to add calendar permissions to your `AndroidManifest.xml`
```xml
<uses-permission android:name="android.permission.WRITE_CALENDAR" />
<uses-permission android:name="android.permission.READ_CALENDAR" />
```

### iOS integration

In order to make this plugin work on iOS 10+, be sure to add this to your `info.plist` file:

```xml
<key>NSCalendarsUsageDescription</key>
<string>INSERT_REASON_HERE</string>
```

## Use it

```dart
import 'package:add_2_calendar/add_2_calendar.dart';

final Event event = Event(
      title: 'Event title',
      description: 'Event description',
      location: 'Event location',
      startDate: DateTime(/* Some date here */),
      alarmInterval: Duration(/* Ex. days:1 */), // on iOS, you can set alarm notification after your event. Android see below
      endDate: DateTime(/* Some date here */),
    );
...
Add2Calendar.addEvent2Cal(event);
...
```
This will launch the default calendar application to confirm the event and add it to your calendar.

## Android Reminders
Currently reminders will only be added on android by not launching the calendar app, to use this, simply call:

``` dart
Add2Calendar.addEvent2Cal(event, androidNoUI:true);
```
To call without UI, you will need permission beforehand, as this plugin is not intended for permissions, when trying to add to calendar, it will check for permissions and request if needed, canceling the current action. Once the permission has been granted, the event will be added. If you think this can be improved, a PR would be greatly appreciated.

## iOS language support
By default the ios screen that appears to save the event will be displayed in English, to support diffrent languages, add to your info.plist the languages you are supporting.


```xml
<key>CFBundleLocalizations</key>
	<array>
		<string>en</string>
		<string>es</string>
		<string>ja</string>
	</array>
```



Note: See [DateTime docs](https://api.flutter.dev/flutter/dart-core/DateTime-class.html) to know what valid date could be correct in above piece of code.

## Example

Please run the app in the `example/` folder to start playing!

