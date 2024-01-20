import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:haulier_tracking_app/models/utilization.dart';
import 'package:http/http.dart' as http;

class UpdateUtilization extends StatefulWidget {
  final Utilization utilization;

  UpdateUtilization({required this.utilization});

  @override
  _UpdateUtilizationState createState() => _UpdateUtilizationState();
}

class _UpdateUtilizationState extends State<UpdateUtilization> {
  final TextEditingController _driverNameController = TextEditingController();
  final TextEditingController _cargoCapacityController = TextEditingController();
  final TextEditingController _conditionController = TextEditingController();
  final TextEditingController _maintenanceController = TextEditingController();

  final String firebaseUrl =
      'haulier-tracking-system-2a686-default-rtdb.asia-southeast1.firebasedatabase.app';

  @override
  void initState() {
    super.initState();
    _driverNameController.text = widget.utilization.driverName;
    _cargoCapacityController.text = widget.utilization.cargoCapacity;
    _conditionController.text = widget.utilization.condition;
    _maintenanceController.text = widget.utilization.maintenance;
  }

 void _updateUtilization() async {
    final url = Uri.https(
      firebaseUrl,
      'Utilization/${widget.utilization.truckId}.json',
    );

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'driverName': _driverNameController.text,
          'condition': _conditionController.text,
          'cargoCapacity': _cargoCapacityController,
          'maintenance': _maintenanceController,

          
        }),
      );
      if (response.statusCode == 200) {
        Utilization updatedUtil = Utilization(
          driverId: widget.utilization.driverId,
          truckId: widget.utilization.truckId,
          driverName: _driverNameController.text,
          cargoCapacity: _cargoCapacityController.text,
         condition: _conditionController.text,
        maintenance: _maintenanceController.text,
          
        );
        Navigator.pop(context, updatedUtil);

      if (response.statusCode == 200) {
        Navigator.pop(context);
      } else {
        throw Exception('Failed to update schedule data in Firebase');
      }
      }
    } catch (error) {
      print('Error updating schedule data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Update Schedule',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Truck ID: ${widget.utilization.truckId}',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              readOnly: true, // Ensure that the field is not editable
            ),
            SizedBox(height: 20.0),
            TextFormField(
              controller: _driverNameController,
              decoration: InputDecoration(
                hintText: 'Enter Driver Name: ',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter driverName';
                }
                return null;
              },
            ),
            SizedBox(height: 20.0),
            TextFormField(
              controller: _cargoCapacityController,
              decoration: InputDecoration(
                hintText: 'Enter Cargo Capacity',
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
            SizedBox(height: 20.0),
            TextFormField(
              controller: _conditionController,
              decoration: InputDecoration(
                hintText: 'Enter Condition',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter condition';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _maintenanceController,
              decoration: InputDecoration(
                hintText: 'Enter maintenance',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter maintenance';
                }
                return null;
              },
            ),
            ElevatedButton(
              onPressed: () {
                _updateUtilization();
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
              ),
              child: Text(
                'Update Schedule',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }
}
