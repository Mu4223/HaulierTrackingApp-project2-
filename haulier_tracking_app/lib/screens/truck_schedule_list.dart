import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:haulier_tracking_app/models/truck.dart';
import 'package:haulier_tracking_app/widgets/add_truck_schedule.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../models/schedule.dart';
import '../widgets/update_schedule.dart';

class TruckScheduleList extends StatefulWidget {
  final List<Truck> myTrucks;

  const TruckScheduleList({super.key, required this.myTrucks});
  @override
  _TruckScheduleListState createState() => _TruckScheduleListState();
}

class _TruckScheduleListState extends State<TruckScheduleList> {
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> scheduleList =
      []; // List to store fetched schedules

  final String firebaseUrl =
      'haulier-tracking-system-2a686-default-rtdb.asia-southeast1.firebasedatabase.app';

  @override
  void initState() {
    super.initState();
    fetchScheduleData();
  }

  void addSchedule() async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return AddTruckSchedule(truck: widget.myTrucks);
    }));

    setState(() {
      fetchScheduleData();
    });
  }

  void _editSchedule(Map<String, dynamic> scheduleData) {
    Schedule schedule = Schedule(
      truckId: scheduleData['truckId'],
      pickup: scheduleData['pickupPoint'],
      delivery: scheduleData['deliveryPoint'],
      date: DateTime.parse(scheduleData['date']),
      time: scheduleData['time'],
    );

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => UpdateSchedule(schedule: schedule)));
  }

  void _deleteTruck(String truckId, int index) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this truck?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () async {
                try {
                  final url = Uri.https(firebaseUrl, 'Trucks/$truckId.json');

                  final response = await http.delete(url);

                  if (response.statusCode == 200) {
                    setState(() {
                      widget.myTrucks.removeAt(index);
                    });
                    print('Truck deleted successfully');
                  } else {
                    print(
                        'Failed to delete truck. Error: ${response.statusCode}');
                  }
                } catch (error) {
                  print('Error deleting truck: $error');
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String _formatTimeOfDay(TimeOfDay timeOfDay) {
    return '${timeOfDay.hour}:${timeOfDay.minute}';
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
          scheduleList = schedules; // Assign the retrieved schedules to scheduleList
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
            return Card(
              elevation: 5.0,
              margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: ListTile(
                title: Text('Truck: ${schedule['truckId']}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pickup Point: ${schedule['pickupPoint']}'),
                    Text('Delivery Point: ${schedule['deliveryPoint']}'),
                    Text(
                      'Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}    Time: ${_formatTimeOfDay(schedule['time'])}',
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        _editSchedule(schedule);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        // _deleteTruck(s.truckId, index);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Schedule List',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add Schedule',
          ),
        ],
        currentIndex: 0,
        selectedItemColor: Colors.blue,
        onTap: (int index) {
          if (index == 1) {
            addSchedule();
          }
        },
      ),
    );
  }
}
