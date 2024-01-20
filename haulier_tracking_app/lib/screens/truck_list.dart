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

  void _viewTruckDetail(Truck truck) {
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

            return Card(
              margin: EdgeInsets.all(8.0),
              elevation: 4.0,
              child: ListTile(
                title: Text(widget.myTrucks[index].plateNumber),
                subtitle: Text(widget.myTrucks[index].brand),
                onTap: () {
                  _viewTruckDetail(widget.myTrucks[index]);
                },
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () async{
                        try{
                          Truck updateTruck = await Navigator.push(context, MaterialPageRoute(builder: (context) =>  UpdateTruck(truck: widget.myTrucks[index])));
                          setState(() {
                            widget.myTrucks[index]= updateTruck;
                          });
                        }
                        catch (error){
                          print(error);
                        }
                        },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        _deleteTruck(widget.myTrucks[index].truckId, index);
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
          Truck? newTruck = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RegisterTruck(myTrucks: widget.myTrucks,)),
          );

          // Check if newTruck is not null before using it
          if (newTruck != null) {
            setState(() {
              widget.myTrucks.add(newTruck);
            });
          } else {
            print('Registration canceled or encountered an error.');
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
