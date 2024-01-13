import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:haulier_tracking_app/models/truck.dart';
import 'package:http/http.dart' as http;

class TruckMovement extends StatefulWidget {
  final List<Truck> myTrucks;

  const TruckMovement({super.key, required this.myTrucks});
  @override
  _TruckMovementState createState() => _TruckMovementState();
}

class _TruckMovementState extends State<TruckMovement> {
  List<Map<String, dynamic>> scheduleList =
      []; // List to store fetched schedules

  final String firebaseUrl =
      'haulier-tracking-system-2a686-default-rtdb.asia-southeast1.firebasedatabase.app';

  @override
  void initState() {
    super.initState();
    fetchScheduleData();
  }

  void fetchScheduleData() async {
    final url = Uri.https(firebaseUrl, 'Schedule.json'); // Firebase endpoint

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        List<Map<String, dynamic>> schedules = [];

        data.forEach((key, value) {
          // Convert 'time' from String to TimeOfDay
          TimeOfDay timeOfDay = TimeOfDay(
            hour: int.parse(value['time'].split(':')[0]),
            minute: int.parse(value['time'].split(':')[1]),
          );

          // Add the entire schedule data with the converted 'time' to the list
          schedules.add({
            ...value,
            'time': timeOfDay,
          });
        });

        setState(() {
          scheduleList =
              schedules; // Assign the retrieved schedules to scheduleList
        });
      } else {
        throw Exception('Failed to load schedule data');
      }
    } catch (error) {
      print('Error fetching schedule data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade400, Colors.greenAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView.builder(
          itemCount: scheduleList.length,
          itemBuilder: (context, index) {
            final schedule = scheduleList[index];
            String status = schedule['status'] ??
                ''; // Use '' as a default value if status is null

            // Check the status and conditionally display information
            if (status == 'start') {
              return Card(
                elevation: 5.0,
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListTile(
                  title: Text('Truck: ${schedule['truckId']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'The truck is on the way from: ${schedule['pickupPoint']} to ${schedule['deliveryPoint']}'),
                    ],
                  ),
                ),
              );
            } else if (status == 'finish') {
              return Card(
                elevation: 5.0,
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListTile(
                  title: Text('Truck: ${schedule['truckId']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('The truck has arrived at its destination'),
                    ],
                  ),
                ),
              );
            } else {
              // If the status is neither 'start' nor 'finish', do not show the schedule
              return SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }
}
