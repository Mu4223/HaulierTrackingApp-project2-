import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:haulier_tracking_app/models/schedule.dart';
import 'package:http/http.dart' as http;

class UpdateSchedule extends StatefulWidget {
  final Schedule schedule;
  final String firebaseKey;

  UpdateSchedule({required this.schedule, required this.firebaseKey});

  @override
  _UpdateScheduleState createState() => _UpdateScheduleState();
}

class _UpdateScheduleState extends State<UpdateSchedule> {
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  final TextEditingController _pickupPointController = TextEditingController();
  final TextEditingController _deliveryPointController =
      TextEditingController();

  final String firebaseUrl =
      'haulier-tracking-system-2a686-default-rtdb.asia-southeast1.firebasedatabase.app';

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.schedule.date;
    _selectedTime = widget.schedule.time;
    _pickupPointController.text = widget.schedule.pickup;
    _deliveryPointController.text = widget.schedule.delivery;
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
      initialDate: widget.schedule.date,
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
      initialTime: widget.schedule.time,
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

 void _updateSchedule() async {
    final url = Uri.https(
      firebaseUrl,
      'Schedule/${widget.firebaseKey}.json',
    );
    print('Schedule ${widget.firebaseKey}');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'truckId': widget.schedule.truckId,
          'pickupPoint': _pickupPointController.text,
          'deliveryPoint': _deliveryPointController.text,
          'date': _selectedDate.toIso8601String(),
          'time': _formatTime(_selectedTime),
        }),
      );
      if (response.statusCode == 200) {
        Schedule updatedTruck = Schedule(
          truckId: widget.schedule.truckId,
          pickup: _pickupPointController.text,
          delivery: _deliveryPointController.text,
         date: _selectedDate,
        time: _selectedTime,
          
        );

      if (response.statusCode == 200) {
        Navigator.pop(context, updatedTruck);
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
                hintText: 'Truck ID: ${widget.schedule.truckId}',
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
              controller: _pickupPointController,
              decoration: InputDecoration(
                labelText: 'Pickup Point',
                hintText: 'Enter Pickup Point',
                filled: true,
                fillColor: Colors.white,
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
                filled: true,
                fillColor: Colors.white,
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
                Text('Delivery Date: ${_formatDate(_selectedDate)}'),
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
                _updateSchedule();
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
