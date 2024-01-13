import 'package:flutter/material.dart';
import 'package:haulier_tracking_app/models/utilization.dart';

class TruckUtilization extends StatefulWidget {
  final Utilization utilization;

  TruckUtilization({required this.utilization});

  @override
  _TruckUtilizationState createState() => _TruckUtilizationState();
}

class _TruckUtilizationState extends State<TruckUtilization> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Truck Utilization',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade400, Colors.greenAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child:
      Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: ListTile(
                title: Text('Driver Name'),
                subtitle: Text('Driver Name: ${widget.utilization.driverName}'),
              ),
            ),
            Card(
              child: ListTile(
                title: Text('Truck'),
                subtitle: Text('Truck Id: ${widget.utilization.truckId}'),
              ),
            ),
            Card(
              child: ListTile(
                title: Text('Cargo Capacity'),
                subtitle:
                    Text('Current Load: ${widget.utilization.cargoCapacity}'),
              ),
            ),
            Card(
              child: ListTile(
                title: Text('Condition'),
                subtitle: Text('Condition: ${widget.utilization.condition}'),
              ),
            ),
            Card(
              child: ListTile(
                title: Text('Maintenance Schedule'),
                subtitle:
                    Text('Next Maintenance: ${widget.utilization.maintenance}'),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
