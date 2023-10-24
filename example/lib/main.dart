import 'package:flutter/material.dart';

import 'package:add_2_calendar/add_2_calendar.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  MyApp({super.key});

  Event buildEvent({Recurrence? recurrence}) {
    return Event(
      title: 'Test event',
      description: 'example',
      location: 'Flutter app',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(minutes: 30)),
      allDay: false,
      iosParams: const IOSParams(
        reminder: Duration(minutes: 40),
        url: "http://example.com",
      ),
      androidParams: const AndroidParams(
        emailInvites: ["test@example.com"],
      ),
      recurrence: recurrence,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Add event to calendar example'),
        ),
        body: ListView(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ListTile(
              title: const Text('Add normal event'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () {
                Add2Calendar.addEvent2Cal(
                  buildEvent(),
                );
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Add event with recurrence 1'),
              subtitle: const Text("weekly for 3 months"),
              trailing: const Icon(Icons.calendar_today),
              onTap: () {
                Add2Calendar.addEvent2Cal(buildEvent(
                  recurrence: Recurrence(
                    frequency: Frequency.weekly,
                    endDate: DateTime.now().add(const Duration(days: 60)),
                  ),
                ));
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Add event with recurrence 2'),
              subtitle: const Text("every 2 months for 6 times (1 year)"),
              trailing: const Icon(Icons.calendar_today),
              onTap: () {
                Add2Calendar.addEvent2Cal(buildEvent(
                  recurrence: Recurrence(
                    frequency: Frequency.monthly,
                    interval: 2,
                    ocurrences: 6,
                  ),
                ));
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Add event with recurrence 3'),
              subtitle:
                  const Text("RRULE (android only) every year for 10 years"),
              trailing: const Icon(Icons.calendar_today),
              onTap: () {
                Add2Calendar.addEvent2Cal(buildEvent(
                  recurrence: Recurrence(
                    frequency: Frequency.yearly,
                    rRule: 'FREQ=YEARLY;COUNT=10;WKST=SU',
                  ),
                ));
              },
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }
}
