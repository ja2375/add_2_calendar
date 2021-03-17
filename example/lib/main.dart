import 'package:flutter/material.dart';

import 'package:add_2_calendar/add_2_calendar.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    Event event = Event(
      title: 'Test event',
      description: 'example',
      location: 'Flutter app',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(Duration(minutes: 30)),
      alarmInterval: Duration(minutes: 40),
      allDay: false,
    );

    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Add event to calendar example'),
        ),
        body: Center(
          child: ElevatedButton(
            child: const Text('Add test event to device calendar'),
            onPressed: () {
              Add2Calendar.addEvent2Cal(event, androidNoUI: false)
                  .then((success) {
                scaffoldMessengerKey.currentState!.showSnackBar(
                    SnackBar(content: Text(success ? 'Success' : 'Error')));
              });
            },
          ),
        ),
      ),
    );
  }
}
