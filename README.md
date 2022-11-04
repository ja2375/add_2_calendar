# add_2_calendar

A really simple Flutter plugin to add events to each platform's default calendar.

## Installation

In your `pubspec.yaml` file within your Flutter Project: 

```yaml
dependencies:
  add_2_calendar: ^2.1.2
```
### Android integration
The plugin doesn't need any special permissions by default to add events to the calendar. However, events can also be added without launching the calendar application, for this it is needed to add calendar permissions to your `AndroidManifest.xml`
```xml
<uses-permission android:name="android.permission.WRITE_CALENDAR" />
<uses-permission android:name="android.permission.READ_CALENDAR" />
```

Starting from API 30 Android requires package visibility configuration in your AndroidManifest.xml. A <queries> element must be added to your manifest as a child of the root element. See the Android documentation for examples of other queries.

``` xml
<queries>
  <intent>
    <action android:name="android.intent.action.INSERT" />
    <data android:mimeType="vnd.android.cursor.item/event" />
  </intent>
</queries>
 ```

### iOS integration

In order to make this plugin work on iOS 10+, be sure to add this to your `info.plist` file:

```xml
<key>NSCalendarsUsageDescription</key>
<string>INSERT_REASON_HERE</string>
```

`NSContactsUsageDescription` is required for the location autocomplete once Apple's UI is opened, so 
it is highly recommended that you also add the key, the app might crash otherwise.

```xml
<key>NSContactsUsageDescription</key>
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
      endDate: DateTime(/* Some date here */),
      iosParams: IOSParams( 
        reminder: Duration(/* Ex. hours:1 */), // on iOS, you can set alarm notification after your event.
        url: 'https://www.example.com', // on iOS, you can set url to your event.
      ),
      androidParams: AndroidParams( 
        emailInvites: [], // on Android, you can add invite emails to your event.
      ),
    );
...
Add2Calendar.addEvent2Cal(event);
...
```
This will launch the default calendar application to confirm the event and add it to your calendar.

## Recurring events
You can add recurrency to your events by specifying a frequency. Optional parameters such as `interval`, `ocurrances` and `endDate` can also be added.

``` dart
 Event(
   ...
  recurrence: Recurrence(
        frequency: Frequency.monthly,
        interval: 2,
        ocurrences: 6,
      ),
    );
```

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

