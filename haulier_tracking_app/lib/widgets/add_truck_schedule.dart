import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:haulier_tracking_app/models/schedule.dart';
import 'package:http/http.dart' as http;

import '../models/truck.dart';

class AddTruckSchedule extends StatefulWidget {
  final List<Truck> truck;
  final Schedule? schedule;

  AddTruckSchedule({this.schedule, required this.truck});

  @override
  _AddTruckScheduleState createState() => _AddTruckScheduleState();
}

class _AddTruckScheduleState extends State<AddTruckSchedule> {
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  final TextEditingController _pickupPointController = TextEditingController();
  final TextEditingController _deliveryPointController =
      TextEditingController();
  String _plateNumber = '';

  final String firebaseUrl =
      'haulier-tracking-system-2a686-default-rtdb.asia-southeast1.firebasedatabase.app';

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.schedule?.date ?? DateTime.now();
    _selectedTime = widget.schedule?.time ?? TimeOfDay.now();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    final hours = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2021),
      lastDate: DateTime(2100),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        _selectedDate = pickedDate;
      });
    });
  }

  void _presentTimePicker() {
    showTimePicker(
      context: context,
      initialTime: _selectedTime,
      initialEntryMode: TimePickerEntryMode.input,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    ).then((pickedTime) {
      if (pickedTime == null) {
        return;
      }
      setState(() {
        _selectedTime = pickedTime;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add New Schedule',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownMenu<Truck>(
              enableSearch: true,
              width: MediaQuery.of(context).size.width * 0.9,
              initialSelection: widget.truck.first,

              // Set to null if the list is empty,
              onSelected: (Truck? value) {
                // This is called when the user selects an item.
                setState(() {
                  _plateNumber = value!.plateNumber;
                });
              },
              dropdownMenuEntries:
                  widget.truck.map<DropdownMenuEntry<Truck>>((Truck value) {
                return DropdownMenuEntry<Truck>(
                  value: value,
                  label: value.plateNumber,
                );
              }).toList(),
            ),
            SizedBox(height: 20.0),
            TextFormField(
              controller: _pickupPointController,
              decoration: InputDecoration(
                labelText: 'Pickup Point',
                hintText: 'Enter Pickup Point',
                filled: true, // Set to true to enable filling
                fillColor: Colors.white, // Set the background color
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter pickup point';
                }
                return null;
              },
            ),
            SizedBox(height: 20.0),
            TextFormField(
              controller: _deliveryPointController,
              decoration: InputDecoration(
                labelText: 'Delivery Point',
                hintText: 'Enter Delivery Point',
                filled: true, // Set to true to enable filling
                fillColor: Colors.white, // Set the background color
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter delivery point';
                }
                return null;
              },
            ),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    'Delivery Date: ${_formatDate(_selectedDate)}'), // Display formatted date
                TextButton(
                  onPressed: _presentDatePicker,
                  child: Text(
                    'Choose Date',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Delivery Time: ${_formatTime(_selectedTime)}'),
                TextButton(
                  onPressed: _presentTimePicker,
                  child: Text(
                    'Choose Time',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                _scheduleTruck();
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.green, // Background color
              ),
              child: Text(
                'Add Schedule',
                style: TextStyle(
                  color: Colors.white, // Text color
                ),
              ),
            ),
            SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }

  void _scheduleTruck() async {
    final url = Uri.https(firebaseUrl, 'Schedule/.json');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'truckId': _plateNumber,
          'pickupPoint': _pickupPointController.text,
          'deliveryPoint': _deliveryPointController.text,
          'date': _selectedDate.toIso8601String(),
          'time': _formatTime(_selectedTime),
        }),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context);
        // Successfully added to both tables
        _clearFields();
      } else {
        throw Exception('Failed to add truck data to Firebase');
      }
    } catch (error) {
      print('Error adding truck data: $error');
    }
  }

  void _clearFields() {
    _pickupPointController.clear();
    _deliveryPointController.clear();
    setState(() {
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay.now();
    });
  }
}
