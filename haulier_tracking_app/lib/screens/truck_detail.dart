import 'package:flutter/material.dart';
import 'package:haulier_tracking_app/models/truck.dart';

class TruckDetail extends StatefulWidget {
  final Truck truck;

  TruckDetail({required this.truck});

  @override
  _TruckDetailState createState() => _TruckDetailState();
}

class _TruckDetailState extends State<TruckDetail> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Truck Detail',
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
        child: Card(
          elevation: 4.0,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Truck Details',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Text('Brand: ${widget.truck.brand}'),
                    Text('Model: ${widget.truck.model}'),
                    Text('Plate Number: ${widget.truck.plateNumber}'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}
