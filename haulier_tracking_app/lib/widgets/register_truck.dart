import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/models/truck.dart';

class RegisterTruck extends StatefulWidget {
  RegisterTruck({super.key});
  @override
  _RegisterTruckState createState() => _RegisterTruckState();
}

class _RegisterTruckState extends State<RegisterTruck> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController driverIdController = TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final TextEditingController modelController = TextEditingController();
  final TextEditingController plateNumberController = TextEditingController();

  String firebaseurl =
      'haulier-tracking-system-2a686-default-rtdb.asia-southeast1.firebasedatabase.app';

  void _registerTruck(context) async {

    final url = Uri.https(firebaseurl, 'Trucks.json');

    try {
      // final response = await http.get(url);
      // final bool driverExists =
      //     response.statusCode == 200 && json.decode(response.body) != null;
      // final bool truckExists =
      //     response.statusCode == 200 && json.decode(response.body) != null;

      // if (driverExists) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(content: Text('Driver ID already in exiset')),
      //   );
      // } else if (truckExists) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(content: Text('Truck already exist')),
      //   );
      // } else {
        final postResponse = await http.post(
          url,
          body: json.encode({
            'driverId': driverIdController.text,
            'password': plateNumberController.text,
            'brand': brandController.text,
            'model': modelController.text,
            'plateNumber': plateNumberController.text,
          }),
        );

        if (postResponse.statusCode == 200) {
          Truck newTruck = Truck(
            truckId: plateNumberController.text.toUpperCase(),
            driverId: driverIdController.text.toUpperCase(),
            brand: brandController.text,
            model: modelController.text,
            plateNumber: plateNumberController.text.toUpperCase(),
          );
          _addUtilization(context);
          Navigator.pop(context, newTruck);
          print('Truck data added to Firebase');
        } else {
          print('Failed to add truck data: ${postResponse.statusCode}');
        }
      // }
    } catch (error) {
      print('Error: $error');
    }
  }

  void _addUtilization(context) async {
    final url = Uri.https(firebaseurl, 'Utilization.json');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'driverId': driverIdController.text,
          'truckId': plateNumberController.text,
          'driverName': '',
          'cargoCapacity': '',
          'condition': '',
          'maintenance': '',
        }),
      );

      if (response.statusCode == 200) {
        print('Succesfully added');
      } else {
        throw Exception('Failed to add truck data to Firebase');
      }
    } catch (error) {
      print('Error adding truck data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          'Register Truck',
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
                        labelText: 'Driver ID',
                        hintText: 'Enter Driver ID',
                        filled: true, // Set to true to enable filling
                        fillColor: Colors.white, // Set the background color
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter password';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20.0),
                    TextFormField(
                      controller: brandController,
                      decoration: InputDecoration(
                        labelText: 'Truck Brand',
                        hintText: 'Enter Truck Brand',
                        filled: true, // Set to true to enable filling
                        fillColor: Colors.white, // Set the background color
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter password';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20.0),
                    TextFormField(
                      controller: modelController,
                      decoration: InputDecoration(
                        labelText: 'Truck Model',
                        hintText: 'Enter Truck Model',
                        filled: true, // Set to true to enable filling
                        fillColor: Colors.white, // Set the background color
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter password';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20.0),
                    TextFormField(
                      controller: plateNumberController,
                      decoration: InputDecoration(
                        labelText: 'Truck Plate Number',
                        hintText: 'Enter Truck Plate Number',
                        filled: true, // Set to true to enable filling
                        fillColor: Colors.white, // Set the background color
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter password';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _registerTruck(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.green, // Background color of the button
                      ),
                      child: Text(
                        'Register Truck',
                        style: TextStyle(
                          color: Colors.white, // Text color
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
