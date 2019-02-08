import 'package:flutter/material.dart';
import 'dart:async';

import 'package:add_2_calendar/add_2_calendar.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  GlobalKey<ScaffoldState> scaffoldState = GlobalKey();
  @override
  Widget build(BuildContext context) {
    Event event = Event(
      title: 'Test event',
      description: 'example',
      location: 'Flutter app',
      startDate: DateTime(2019, 2, 8, 16, 49),
      endDate: DateTime(2019, 2, 9, 17, 01),
      allDay: true,
    );

    return MaterialApp(
      home: Scaffold(
        key: scaffoldState,
        appBar: AppBar(
          title: const Text('Add event to calendar example'),
        ),
        body: Center(
          child: RaisedButton(
            child: Text('Add test event to device calendar'),
            onPressed: () {
              Add2Calendar.addEvent2Cal(event).then((success) {
                scaffoldState.currentState.showSnackBar(
                    SnackBar(content: Text(success ? 'Success' : 'Error')));
              });
            },
          ),
        ),
      ),
    );
  }
}
