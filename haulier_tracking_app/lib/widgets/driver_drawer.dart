import 'package:flutter/material.dart';
import 'package:haulier_tracking_app/models/utilization.dart';
import 'package:haulier_tracking_app/widgets/driver_schedule.dart';
import '../screens/utilization_form.dart';
import '/main.dart';
import '/models/truck.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DriverDrawer extends StatefulWidget {
  final Truck truck;

  const DriverDrawer({super.key, required this.truck});

  @override
  // ignore: library_private_types_in_public_api
  _DriverDrawerState createState() => _DriverDrawerState();
}

class _DriverDrawerState extends State<DriverDrawer> {
  List<Truck> myTrucks = [];
  List<Utilization> utilization = [];
  bool isThereUtil = false;
  int _currentIndex = 0;
  final String firebaseUrl =
      'haulier-tracking-system-2a686-default-rtdb.asia-southeast1.firebasedatabase.app';

  List<Widget> _screens = [];

  void initPages() {
    _screens = [
      DriverSchedule(truck: widget.truck),
    UtilizationForm(truck: widget.truck),
    ];
  }

  final List<String> _drawerTitles = [
    'Schedule',
    'Truck Utilization',
  ];

  final List<IconData> _drawerIcons = [
    Icons.schedule,
    Icons.feed_outlined,
  ];

  String get drawerTitle => _drawerTitles[_currentIndex];
  IconData get drawerIcon => _drawerIcons[_currentIndex];

  void getUtilization() async {
    final url = Uri.https(firebaseUrl, 'Utilization.json');

    try {
      final response = await http.get(url);
      List<Utilization> truckUtil = [];
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        for (final tempUtil in data.entries) {
          truckUtil.add(Utilization(
              driverId: tempUtil.value['driverId'],
              driverName: tempUtil.value['driverName'],
              truckId: tempUtil.value['truckId'],
              cargoCapacity: tempUtil.value['cargoCapacity'],
              condition: tempUtil.value['condition'],
              maintenance: tempUtil.value['maintenance']));
        }
      }
      setState(() {
        utilization = truckUtil;
        initPages();
      });
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  void fetchData() async {
    final url = Uri.https(firebaseUrl, 'Trucks.json');

    try {
      final response = await http.get(url);
      List<Truck> anothertempUtil = [];
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        for (final tempUtil in data.entries) {
          anothertempUtil.add(Truck(
            truckId: tempUtil.key,
            driverId: tempUtil.value['driverId'],
            brand: tempUtil.value['brand'],
            model: tempUtil.value['model'],
            plateNumber: tempUtil.value['plateNumber'],
          ));
        }
      }
      setState(() {
        myTrucks = anothertempUtil;
        initPages();
      });
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  @override
  void initState() {
    initPages();
    getUtilization();
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HT App - $drawerTitle',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green
      ),
      body: _screens[_currentIndex],
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green,
              ),
              child: Text(
                drawerTitle,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            for (int i = 0; i < _drawerTitles.length; i++)
              ListTile(
                leading: Icon(_drawerIcons[i]),
                title: Text(_drawerTitles[i]),
                onTap: () {
                  setState(() {
                    _currentIndex = i;
                  });
                  Navigator.pop(context);
                },
              ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return MyApp();
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
