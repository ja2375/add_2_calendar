import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:add_2_calendar/add_2_calendar.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Event event = Event(
      title: 'Test event',
      description: 'example',
      location: 'Flutter app',
      startDate: DateTime(2018, 10, 29),
      endDate: DateTime(2018, 10, 30),
    );

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Add event to calendar example'),
        ),
        body: Center(
          child: RaisedButton(
            child: Text('Add test event to device calendar'),
            onPressed: () {
              Add2Calendar.addEvent2Cal(event);
            },
          ),
        ),
      ),
    );
  }
}
