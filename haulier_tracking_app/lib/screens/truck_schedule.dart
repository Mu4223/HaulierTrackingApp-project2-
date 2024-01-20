import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/models/truck.dart';
import '../models/schedule.dart';

class TruckSchedules extends StatefulWidget {
  final Truck truck;

  TruckSchedules({required this.truck});
  @override
  _TruckSchedulesState createState() => _TruckSchedulesState();
}

class _TruckSchedulesState extends State<TruckSchedules> {
  List<Schedule> schedules = [];
  DateTime selectedDate = DateTime.now();

  Future<void> fetchSchedules(DateTime date) async {
    final String firebaseUrl =
        'haulier-tracking-system-2a686-default-rtdb.asia-southeast1.firebasedatabase.app';
    final url = Uri.https(firebaseUrl, 'Trucks/schedule.json');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        setState(() {
          schedules = data.entries
    .where((entry) =>
        DateTime.parse(entry.value['date']).isAtSameMomentAs(date))
    .map((entry) => Schedule(
          truckId: widget.truck.truckId,
          date: DateTime.parse(entry.value['date']),
          pickup: entry.value['pickup'], // Make sure these keys exist in your Firebase data
          delivery: entry.value['delivery'],
          time: TimeOfDay.fromDateTime(DateTime.parse(entry.value['time'])),
        ))
    .toList();

        });
      } else {
        throw Exception('Failed to fetch schedules');
      }
    } catch (error) {
      print('Error fetching schedules: $error');
    }
  }

  @override
  void initState() {
    fetchSchedules(selectedDate);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Truck Schedules'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 20),
          Text('Select a day to view schedules:'),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2025),
              );
              if (pickedDate != null) {
                setState(() {
                  selectedDate = pickedDate;
                });
                fetchSchedules(selectedDate);
              }
            },
            child: Text('Choose Date'),
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: schedules.length,
              itemBuilder: (context, index) {
                final schedule = schedules[index];
                return ListTile(
                  title: Text(schedule.pickup),
                  subtitle: Text(schedule.delivery),
                  // Display more schedule details here
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
