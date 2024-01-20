import 'package:flutter/material.dart';
import 'package:haulier_tracking_app/models/truck.dart';
import 'package:haulier_tracking_app/widgets/driver_drawer.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/utilization.dart';

class UtilizationForm extends StatefulWidget {
  final Truck truck;

  UtilizationForm({super.key, required this.truck});

  @override
  _UtilizationFormState createState() => _UtilizationFormState();
}

class _UtilizationFormState extends State<UtilizationForm> {
  String firebaseurl =
      'haulier-tracking-system-2a686-default-rtdb.asia-southeast1.firebasedatabase.app';
  final _formKey = GlobalKey<FormState>();
  List<Utilization> utilization = [];
  String keyId = '';
  TextEditingController cargoCapacityController = TextEditingController();
  String selectedCondition  = "Excellent";
  TextEditingController maintenanceController = TextEditingController();
  TextEditingController driverNameController = TextEditingController();

  List<String> truckConditions = [
    'Excellent',
    'Good',
    'Average',
    'Poor',
    'Needs Repairs',
  ];

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
          print("Truck Plate Number = ${widget.truck.plateNumber}");
          print(tempUtil.value['truckId']);
          if (widget.truck.plateNumber.toString().toUpperCase() ==
              tempUtil.value['truckId'].toString().toUpperCase()) {
                keyId = tempUtil.key;
            utilizationList.add(Utilization(
              driverId: tempUtil.value['driverId'],
              driverName: tempUtil.value['driverName'],
              truckId: tempUtil.value['truckId'],
              cargoCapacity: tempUtil.value['cargoCapacity'],
              condition: tempUtil.value['condition'],
              maintenance: tempUtil.value['maintenance'],
            ));
          }
        }
        print("Key =  $keyId");
        utilization = utilizationList;

        if (utilizationList.isNotEmpty) {
          driverNameController =
              TextEditingController(text: utilization[0].driverName);
          cargoCapacityController =
              TextEditingController(text: utilization[0].cargoCapacity);
          selectedCondition = utilization[0].condition;
          maintenanceController =
              TextEditingController(text: utilization[0].maintenance);
        }else{
          selectedCondition = 'Excellent';
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

  void _postUtilization(context) async {
    if (_formKey.currentState!.validate()) {
      final url = Uri.https(firebaseurl, 'Utilization.json');

      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'driverId': widget.truck.driverId,
            'truckId': widget.truck.plateNumber,
            'driverName': driverNameController.text,
            'cargoCapacity': cargoCapacityController.text,
            'condition': selectedCondition,
            'maintenance': maintenanceController.text,
          }),
        );

        if (response.statusCode == 200) {
          print('Succesfully added');
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (ctx) => DriverDrawer(truck: widget.truck)));
        } else {
          throw Exception('Failed to add truck data to Firebase');
        }
      } catch (error) {
        print('Error adding truck data: $error');
      }
    }
  }
   void _updateUtilization(context) async {
    if (_formKey.currentState!.validate() && keyId.isNotEmpty) {
      final url = Uri.https(firebaseurl, 'Utilization/${keyId}.json');

      try {
        final response = await http.put(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'driverId': widget.truck.driverId,
            'truckId': widget.truck.plateNumber,
            'driverName': driverNameController.text,
            'cargoCapacity': cargoCapacityController.text,
            'condition': selectedCondition,
            'maintenance': maintenanceController.text,
          }),
        );

        if (response.statusCode == 200) {
          print('Succesfully added');
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (ctx) => DriverDrawer(truck: widget.truck)));
        } else {
          throw Exception('Failed to add truck data to Firebase');
        }
      } catch (error) {
        print('Error adding truck data: $error');
      }
    }
  }

  @override
  void initState() {
    _getUtilization();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Truck ID: ${widget.truck.plateNumber}',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                readOnly: true, // Ensure that the field is not editable
              ),
              SizedBox(height: 20,),
              TextFormField(
                controller: driverNameController,
                decoration: InputDecoration(
                  labelText: 'Driver Name',
                  hintText: 'Enter Driver Name',
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
              SizedBox(height: 20,),
              TextFormField(
                controller: cargoCapacityController,
                decoration: InputDecoration(
                  labelText: 'Cargo Capacity',
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
              SizedBox(height: 20,),
              Text(' Truck Condition', style: TextStyle(fontSize: 16),),
              SizedBox(height: 10,),
              DropdownMenu<String>(
                enableSearch: true,
                width: MediaQuery.of(context).size.width * 0.9,
                initialSelection: selectedCondition,

                // Set to null if the list is empty,
                onSelected: (String? value) {
                  // This is called when the user selects an item.
                  setState(() {
                    selectedCondition = value!;
                  });
                },
                dropdownMenuEntries:
                truckConditions.map<DropdownMenuEntry<String>>((String value) {
                  return DropdownMenuEntry<String>(
                    value: value,
                    label: value,
                  );
                }).toList(),
              ),
              SizedBox(height: 20,),
              TextFormField(
                controller: maintenanceController,
                decoration: InputDecoration(
                  labelText: 'Maintenance Schedule',
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
                  if(utilization.isNotEmpty){
                    print("PUT REQUEST");
                    _updateUtilization(context);
                  }else{
                    print("POST REQUEST");
                    _postUtilization(context);
                  }
                  // _submitForm();
                },
                child: Text('Submit'),
              ),
            ],
          ),
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
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: Text('Utilization Form'),
        ),
        body: content);
  }
}
