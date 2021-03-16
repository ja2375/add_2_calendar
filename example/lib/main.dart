import 'package:flutter/material.dart';

import 'package:add_2_calendar/add_2_calendar.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    Event event = Event(
      startDate: DateTime(2020, 1, 1, 9),
      endDate: DateTime(2020, 1, 1, 10),
      title: "Title",
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
              Add2Calendar.addEvent2Cal(event).then((success) {
                scaffoldMessengerKey.currentState!.showSnackBar(
                    SnackBar(content: Text(success! ? 'Success' : 'Error')));
              });
            },
          ),
        ),
      ),
    );
  }
}
