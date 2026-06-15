import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: AddToCalendarPage());
  }
}

class AddToCalendarPage extends StatelessWidget {
  const AddToCalendarPage({super.key});

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

  void showResultSnackbar(BuildContext context, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: success ? Colors.green : Colors.red,
        content: Text(success
            ? 'Event added to calendar'
            : 'Failed to add event to calendar'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add event to calendar example'),
      ),
      body: ListView(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ListTile(
            title: const Text('Add normal event'),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final success = await Add2Calendar.addEvent2Cal(
                buildEvent(),
              );
              if (context.mounted) {
                showResultSnackbar(context, success);
              }
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Add event with recurrence 1'),
            subtitle: const Text("weekly for 3 months"),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final success = await Add2Calendar.addEvent2Cal(buildEvent(
                recurrence: Recurrence(
                  frequency: Frequency.weekly,
                  endDate: DateTime.now().add(const Duration(days: 60)),
                ),
              ));
              if (context.mounted) {
                showResultSnackbar(context, success);
              }
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Add event with recurrence 2'),
            subtitle: const Text("every 2 months for 6 times (1 year)"),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final success = await Add2Calendar.addEvent2Cal(buildEvent(
                recurrence: Recurrence(
                  frequency: Frequency.monthly,
                  interval: 2,
                  ocurrences: 6,
                ),
              ));
              if (context.mounted) {
                showResultSnackbar(context, success);
              }
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Add event with recurrence 3'),
            subtitle:
                const Text("RRULE (android only) every year for 10 years"),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final success = await Add2Calendar.addEvent2Cal(buildEvent(
                recurrence: Recurrence(
                  frequency: Frequency.yearly,
                  rRule: 'FREQ=YEARLY;COUNT=10;WKST=SU',
                ),
              ));
              if (context.mounted) {
                showResultSnackbar(context, success);
              }
            },
          ),
          const Divider(),
        ],
      ),
    );
  }
}
