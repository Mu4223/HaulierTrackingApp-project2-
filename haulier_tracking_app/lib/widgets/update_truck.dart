import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/models/truck.dart';

class UpdateTruck extends StatefulWidget {
  final Truck truck;
  UpdateTruck({super.key, required this.truck});
  @override
  _UpdateTruckState createState() => _UpdateTruckState();
}

class _UpdateTruckState extends State<UpdateTruck> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController driverIdController = TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final TextEditingController modelController = TextEditingController();
  final TextEditingController plateNumberController = TextEditingController();

  String firebaseurl =
      'haulier-tracking-system-2a686-default-rtdb.asia-southeast1.firebasedatabase.app';

  void _updateTruck(context) async {
    final plateNumber = plateNumberController.text;

    final url = Uri.https(firebaseurl, 'Trucks/${widget.truck.truckId}.json');

    try {
      final response = await http.put(
        url,
        body: json.encode({
          'driverId': driverIdController.text,
          'brand': brandController.text,
          'model': modelController.text,
          'plateNumber': plateNumberController.text,
        }),
      );

      if (response.statusCode == 200) {
        Truck updatedTruck = Truck(
          truckId: widget.truck.truckId,
          driverId: driverIdController.text,
          brand: brandController.text,
          model: modelController.text,
          plateNumber: plateNumberController.text,
        );
        Navigator.pop(context, updatedTruck);
        print('Truck data updated in Firebase');
      } else {
        print('Failed to update truck data: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    driverIdController.text = '${widget.truck.driverId}';
    brandController.text = '${widget.truck.brand}';
    modelController.text = '${widget.truck.model}';
    plateNumberController.text = '${widget.truck.plateNumber}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          'Update Truck',
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
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Card(
            elevation: 5,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text('Please fill up the form',
                        style: TextStyle(fontSize: 20)),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: driverIdController,
                      decoration: InputDecoration(
                        hintText: '${widget.truck.driverId}',
                        filled: true, // Set to true to enable filling
                        fillColor: Colors.white, // Set the background color
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter driver ID';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20.0),
                    TextFormField(
                      controller: brandController,
                      decoration: InputDecoration(
                        hintText: '${widget.truck.brand}',
                        filled: true, // Set to true to enable filling
                        fillColor: Colors.white, // Set the background color
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter brand';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20.0),
                    TextFormField(
                      controller: modelController,
                      decoration: InputDecoration(
                        hintText: '${widget.truck.model}',
                        filled: true, // Set to true to enable filling
                        fillColor: Colors.white, // Set the background color
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter model';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20.0),
                    TextFormField(
                      controller: plateNumberController,
                      decoration: InputDecoration(
                        hintText: '${widget.truck.plateNumber}',
                        filled: true, // Set to true to enable filling
                        fillColor: Colors.white, // Set the background color
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please plate number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            _updateTruck(context);
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.green, 
                      ),
                      child: Text(
                        'Update Truck',
                        style: TextStyle(
                          color: Colors.white, 
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
