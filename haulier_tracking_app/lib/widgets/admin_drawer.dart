import 'package:flutter/material.dart';
import 'package:haulier_tracking_app/models/utilization.dart';
import '../screens/truck_movement.dart';
import '/main.dart';
import '/models/truck.dart';
import '../screens/truck_list.dart';
import '../screens/truck_schedule_list.dart';
import '../screens/truck_utilization_list.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminDrawer extends StatefulWidget {
  const AdminDrawer({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _AdminDrawerState createState() => _AdminDrawerState();
}

class _AdminDrawerState extends State<AdminDrawer> {
  List<Truck> myTrucks = [];
  List<Utilization> utilization = [];
  bool isThereUtil = false;
  int _currentIndex = 0;
  final String firebaseUrl =
      'haulier-tracking-system-2a686-default-rtdb.asia-southeast1.firebasedatabase.app';

  List<Widget> _screens = [];

  void initPages() {
    _screens = [
      TruckList(myTrucks: myTrucks),
      TruckScheduleList(myTrucks: myTrucks),
      TruckMovement(myTrucks: myTrucks),
      TruckUtilizationList(
        myTrucks: myTrucks,
        utilization: utilization,
      ),
    ];
  }

  final List<String> _drawerTitles = [
    'Truck List',
    'Truck Schedule',
    'Truck Movement',
    'Truck Utilization',
  ];

  final List<IconData> _drawerIcons = [
    Icons.list_alt_outlined,
    Icons.schedule_outlined,
    Icons.local_shipping_sharp,
    Icons.feed_outlined,
    Icons.login,
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
              truckId: tempUtil.value['truckId'],
              driverName: tempUtil.value['driverName'],
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
      List<Truck> tempTrucks = [];
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        for (final tempTruck in data.entries) {
          tempTrucks.add(Truck(
            truckId: tempTruck.key,
            driverId: tempTruck.value['driverId'],
            brand: tempTruck.value['brand'],
            model: tempTruck.value['model'],
            plateNumber: tempTruck.value['plateNumber'],
          ));
        }
      }
      setState(() {
        myTrucks = tempTrucks;
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
       title: Text(
        '$drawerTitle',
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.green,
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
