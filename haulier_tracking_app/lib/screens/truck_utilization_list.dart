import 'package:flutter/material.dart';
import 'package:haulier_tracking_app/models/truck.dart';
import 'package:haulier_tracking_app/models/utilization.dart';
import 'package:haulier_tracking_app/screens/truck_utilization.dart';
import 'package:http/http.dart' as http;

class TruckUtilizationList extends StatefulWidget {
  final List<Truck> myTrucks;
  final List<Utilization> utilization;

  const TruckUtilizationList(
      {required this.myTrucks, required this.utilization});

  @override
  _TruckUtilizationListState createState() => _TruckUtilizationListState();
}

class _TruckUtilizationListState extends State<TruckUtilizationList> {
  final String firebaseUrl =
      'haulier-tracking-system-2a686-default-rtdb.asia-southeast1.firebasedatabase.app';

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
          // itemCount: widget.myTrucks.length,
          itemCount: widget.utilization.length,

          itemBuilder: (context, index) {
            final truck = widget.utilization[index];
            return Card(
              margin: EdgeInsets.all(8.0),
              elevation: 4.0,
              child: ListTile(
                title: Text(truck.truckId),
                subtitle: Text(truck.driverName),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TruckUtilization(
                          utilization: truck),
                    ),
                  );
                  ;
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
