import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:haulier_tracking_app/models/truck.dart';
import 'package:intl/intl.dart';

class DriverSchedule extends StatefulWidget {
  final Truck truck;

  const DriverSchedule({super.key, required this.truck});
  @override
  _DriverScheduleState createState() => _DriverScheduleState();
}

class _DriverScheduleState extends State<DriverSchedule> {
  bool isStarted = false;
  bool isFinished = false;
  Map<String, bool?> scheduleStatus = {};
  List<Map<String, dynamic>> scheduleList =
      []; // List to store fetched schedules

  List<Map<String, dynamic>> userSchedules = [];
  List<dynamic> userScheduleskeys = [];

  Future<void> updateScheduleStatus(
      String truckId, String newStatus, String shceduleId) async {
    final url = Uri.https(firebaseUrl, 'Schedule/$shceduleId.json');

    try {
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'status': newStatus}),
      );

      if (response.statusCode == 200) {
        print('Success');
      } else {
        throw Exception('Failed to update schedule status in Firebase');
      }
    } catch (error) {
      print('Error updating schedule status: $error');
    }
  }

  final String firebaseUrl =
      'haulier-tracking-system-2a686-default-rtdb.asia-southeast1.firebasedatabase.app';

  @override
  void initState() {
    super.initState();
    getTruckSchedule(firebaseUrl, widget.truck.plateNumber);
  }

  void getTruckSchedule(String firebaseUrl, String plateNumber) async {
    final Uri url = Uri.https(firebaseUrl, 'Schedule.json');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> scheduleData = json.decode(response.body);
        userSchedules =
            scheduleData.values.cast<Map<String, dynamic>>().where((schedule) {
          return schedule['truckId'] == plateNumber;
        }).toList();

        for (final scheduleTemp in scheduleData.entries) {
          if (scheduleTemp.value['truckId'] == plateNumber) {
            print("keys in for loop  = ${scheduleTemp.key}");
            userScheduleskeys.add(scheduleTemp.key);
          }
        }
        print("what inside this = $userScheduleskeys");
      } else {
        print('Failed to fetch schedule data: ${response.statusCode}');
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
          itemCount: userSchedules.length,
          itemBuilder: (context, index) {
            // final schedule = userSchedules[index];
            return Card(
              margin: EdgeInsets.all(8.0),
              elevation: 4.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ListTile(
                    title: Text('Truck ID: ${userSchedules[index]['truckId']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pickup Point: ${userSchedules[index]['pickupPoint']}'),
                        Text('Delivery Point: ${userSchedules[index]['deliveryPoint']}'),
                        Text(
                          'Date: ${DateFormat('MM-dd-yyyy').format(DateTime.parse(userSchedules[index]['date']))}',
                        ),
                        Text(
                          'Time: ${userSchedules[index]['time']}',
                        ),
                      ],
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: 0.5,
                    child: ElevatedButton(
                      onPressed: () async {
                        String status;
                        // Check the current status of the schedule
                        bool? currentStatus = scheduleStatus[userScheduleskeys[index]];
                        if (currentStatus == true) {
                          // If the status is 'started', change to 'finished'
                          status = 'finish';
                          // Remove the schedule from the list when 'Finish' is clicked
                          userSchedules.removeAt(index);
                          userScheduleskeys.removeAt(index);
                        } else {
                          // If the status is not 'started', change to 'started'
                          status = 'start';
                        }
                        // Update the schedule status
                        await updateScheduleStatus(
                          widget.truck.truckId,
                          status,
                          userScheduleskeys[index],
                        );
                        // Update the UI to reflect the new status
                        getTruckSchedule(firebaseUrl, widget.truck.plateNumber);
                        // Toggle the status in the map
                        scheduleStatus[userScheduleskeys[index]] =
                        currentStatus == null ? true : !currentStatus;
                        setState(() {});
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.green, // Background color
                      ),
                      child: Text(
                        scheduleStatus[userScheduleskeys[index]] == true ? 'Finish' : 'Start',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
