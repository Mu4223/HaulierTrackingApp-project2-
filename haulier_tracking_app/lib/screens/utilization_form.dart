import 'package:flutter/material.dart';
import 'package:haulier_tracking_app/models/truck.dart';
import 'package:haulier_tracking_app/widgets/driver_drawer.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/utilization.dart';

class UtilizationForm extends StatefulWidget {
  final Truck truck;
  final Utilization utilization;

  UtilizationForm({super.key, required this.truck, required this.utilization});

  @override
  _UtilizationFormState createState() => _UtilizationFormState();
}

class _UtilizationFormState extends State<UtilizationForm> {
  String firebaseurl =
      'haulier-tracking-system-2a686-default-rtdb.asia-southeast1.firebasedatabase.app';
  final _formKey = GlobalKey<FormState>();
  List<Utilization> utilization = [];
  final TextEditingController cargoCapacityController = TextEditingController();
  final TextEditingController conditionController = TextEditingController();
  final TextEditingController maintenanceController = TextEditingController();
  final TextEditingController driverNameController = TextEditingController();

  bool loading = true;

  void _getUtilization() async {
    final url = Uri.https(firebaseurl, 'Utilization.json');
    List<Utilization> utilizationList = [];

    try {
      setState(() {
        loading = true;
      });

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        for (final tempUtil in data.entries) {
          utilizationList.add(Utilization(
            driverName: tempUtil.value['driverName'].toString(),
            truckId: widget.truck.truckId,
            cargoCapacity: tempUtil.value['cargoCapacity'].toString(),
            condition: tempUtil.value['condition'].toString(),
            maintenance: tempUtil.value['maintenance'].toString(),
          ));
        }

        // Check if the utilizationList is not empty before accessing its elements
        if (utilizationList.isNotEmpty) {
          utilizationList = utilizationList
              .where((element) => element.truckId == widget.truck.truckId)
              .toList();

          if (utilizationList.isNotEmpty &&
              utilizationList[0].cargoCapacity.isNotEmpty) {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) {
                return DriverDrawer(truck: widget.truck);
              },
            ));
          }
        }

        setState(() {
          loading = false;
        });
        print("Data added");
      } else {
        print('failed to add data');
        setState(() {
          loading = false;
        });
      }
    } catch (error) {
      print('Error = $error');
      setState(() {
        loading = false;
      });
    }
  }

  void _updateUtilization(context) async {
    final url = Uri.https(firebaseurl, 'Utilization.json');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'driverId': driverNameController.text,
          'truckId': widget.truck.truckId,
          'cargoCapacity': cargoCapacityController.text,
          'condition': conditionController.text,
          'maintenance': maintenanceController.text,
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
  void initState() {
    _getUtilization();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Driver ID: ${widget.truck.driverId}',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              readOnly: true, // Ensure that the field is not editable
            ),
            TextField(
              decoration: InputDecoration(
                hintText: 'Truck ID: ${widget.truck.truckId}',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              readOnly: true, // Ensure that the field is not editable
            ),
            TextFormField(
              controller: cargoCapacityController,
              decoration: InputDecoration(
                hintText: 'Cargo Capacity ${widget.utilization.cargoCapacity}',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter cargo capacity';
                }
                return null;
              },
            ),
            TextFormField(
              controller: conditionController,
              decoration: InputDecoration(
                labelText: 'Condition',
                hintText: 'Enter Truck Condition',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter Truck Condition';
                }
                return null;
              },
            ),
            TextFormField(
              controller: maintenanceController,
              decoration: InputDecoration(
                labelText: 'Maintenance',
                hintText: 'Enter Truck Maintenance Schedule',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter Truck Maintenance Schedule';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (ctx) => DriverDrawer(truck: widget.truck)));

                // _submitForm();
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
    if (loading) {
      content = Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
        appBar: AppBar(
          title: Text('Utilization Form'),
        ),
        body: content);
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Create a Utilization object with the entered data
      Utilization utilization = Utilization(
        driverName: driverNameController.text,
        truckId: widget.truck.truckId,
        cargoCapacity: cargoCapacityController.text,
        condition: conditionController.text,
        maintenance: maintenanceController.text,
      );

      // Use this utilization object as needed (e.g., add to Firebase)
      print('Utilization data submitted: $utilization');
    }
  }
}
