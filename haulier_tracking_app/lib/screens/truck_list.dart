import 'package:flutter/material.dart';
import 'package:haulier_tracking_app/models/truck.dart';
import 'package:haulier_tracking_app/widgets/update_truck.dart';
import 'package:haulier_tracking_app/widgets/register_truck.dart';
import 'package:http/http.dart' as http;
import 'truck_detail.dart';

class TruckList extends StatefulWidget {
  final List<Truck> myTrucks;

  const TruckList({super.key, required this.myTrucks});
  @override
  _TruckListState createState() => _TruckListState();
}

class _TruckListState extends State<TruckList> {
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

  void _viewTruckSchedule(Truck truck) {
    // Navigate to TruckScheduleList passing the truck details
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TruckDetail(truck: truck),
      ),
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
          itemCount: widget.myTrucks.length,
          itemBuilder: (context, index) {
            final truck = widget.myTrucks[index];
            return Card(
              margin: EdgeInsets.all(8.0),
              elevation: 4.0,
              child: ListTile(
                title: Text(truck.plateNumber),
                subtitle: Text(truck.brand),
                onTap: () {
                  _viewTruckSchedule(truck);
                },
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) =>  UpdateTruck(truck: truck)));
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        _deleteTruck(truck.truckId, index);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigate to the RegisterTruck screen and wait for a result
          Truck? newTruck = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RegisterTruck()),
          );

          // Check if newTruck is not null before using it
          if (newTruck != null) {
            // Update the state with the newTruck if it's not null
            setState(() {
              widget.myTrucks.add(newTruck);
            });
          } else {
            // Handle the case where newTruck is null (user canceled or an error occurred)
            print('Registration canceled or encountered an error.');
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
