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
  List<Schedule> scheduleList =
      []; // List to store fetched schedules
      List<String> firebaseKeys = [];

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

  void _editSchedule(Schedule schedule, String firebaseKey) async {

    try{
      Schedule newSchedule = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => UpdateSchedule(schedule: schedule,firebaseKey: firebaseKey,)));
      int index = scheduleList.indexWhere((element) => identical(element, schedule));
      setState(() {
        scheduleList[index] = newSchedule;
      });
    }catch(error){
      print("Truck shcedule list. error = $error");
    }
  }

  void _deleteSchedule(Schedule schedule, int index, String firebaseKey) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this Schedule?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () async {
                try {
                  final url = Uri.https(firebaseUrl, 'Schedule/$firebaseKey.json');

                  final response = await http.delete(url);

                  if (response.statusCode == 200) {
                    setState(() {
                      widget.myTrucks.removeAt(index);
                    });
                    print('Schedule deleted successfully');
                  } else {
                    print(
                        'Failed to delete Schedule. Error: ${response.statusCode}');
                  }
                } catch (error) {
                  print('Error deleting truck: $error');
                }
                setState(() {
                  scheduleList.removeAt(index);
                });
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
    final url = Uri.https(firebaseUrl, 'Schedule.json');
    List<Schedule> tempSchedule = [];
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);


        data.forEach((key, value) {
          print(value['date']);
          firebaseKeys.add(key);
          tempSchedule.add(
            Schedule(
                truckId: value['truckId'],
                pickup: value['pickupPoint'],
                delivery: value['deliveryPoint'],
                date: DateTime.parse(value['date']),
                time: TimeOfDay(hour: int.parse(value['time'].toString().split(":")[0]),
                    minute:int.parse(value['time'].toString().split(":")[1]))
          ));
        });

        setState(() {
          scheduleList = tempSchedule; // Assign the retrieved schedules to scheduleList
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
            
            return Card(
              elevation: 5.0,
              margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: ListTile(
                title: Text('Truck: ${scheduleList[index].truckId}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pickup Point: ${scheduleList[index].pickup}'),
                    Text('Delivery Point: ${scheduleList[index].delivery}'),
                    Text(
                      'Date: ${DateFormat('yyyy-MM-dd').format(scheduleList[index].date)}    Time: ${_formatTimeOfDay(scheduleList[index].time)}',
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        _editSchedule(scheduleList[index],firebaseKeys[index]);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        _deleteSchedule(scheduleList[index], index,firebaseKeys[index]);
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
