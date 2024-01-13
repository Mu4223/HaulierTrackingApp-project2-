import 'package:flutter/material.dart';
import 'package:haulier_tracking_app/models/utilization.dart';
import 'package:haulier_tracking_app/widgets/add_utilization.dart';
import 'package:haulier_tracking_app/widgets/driver_drawer.dart';
import '/widgets/admin_drawer.dart';
import '../models/truck.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      // Wrap your app with MaterialApp
      title: 'Your App Title',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

enum UserType { login, admin }

class _MyHomePageState extends State<MyHomePage> {
  final List<Utilization> utilization = [];
  late Utilization util;
  UserType _userType = UserType.admin;
  final TextEditingController driverIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String firebaseurl =
      'haulier-tracking-system-2a686-default-rtdb.asia-southeast1.firebasedatabase.app';

  void _driverLogin() async {
    // final url = Uri.https(firebaseurl, 'Trucks.json');
    // List<Truck> anotherTempTruck = [];
    // try {
    //   final response = await http.get(url);
    //   if (response.statusCode == 200) {
    //     final Map<String, dynamic> data = json.decode(response.body);
    //     for (final tempTruck in data.entries) {
    //       anotherTempTruck.add(Truck(
    //         truckId: tempTruck.key,
    //         driverId: tempTruck.value['driverId'],
    //         brand: tempTruck.value['brand'],
    //         model: tempTruck.value['model'],
    //         plateNumber: tempTruck.value['plateNumber'],
    //       ));
    //     }
    //     print(response.body);
    //     for (final truck in anotherTempTruck) {
            
    //       driverIdController.text.toUpperCase().contains( truck.driverId) &&
    //           passwordController.text.toUpperCase().contains(truck.plateNumber)?  
            Navigator.of(context)
                .pushReplacement(MaterialPageRoute(builder: (ctx) {
              return UpdateUtilization(utilization: util);
            }));
            // :Container();
          
        }
  //     } else {
  //       print('failed to add data');
  //     }
  //   } catch (error) {
  //     print('Error = $error');
  //   }
  // }

  void _adminLogin() async {
    if (driverIdController.text == 'admin' &&
        passwordController.text == 'admin') {
      Navigator.push(context, MaterialPageRoute(
        builder: (context) {
          return const AdminDrawer();
        },
      ));
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Login Failed'),
            content: Text('Invalid username or password!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void _onLoginButtonPressed() {
    if (_userType == UserType.admin) {
      _adminLogin();
    } else {
      _driverLogin();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade400, Colors.greenAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20.0),
            child: Card(
              elevation: 5.0,
              color: const Color.fromARGB(255, 0, 151,
                  78), // Set the background color of the card to green
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: EdgeInsets.all(20.0),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'HAULIER TRACKING SYSTEM',
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                color:
                                    Colors.white, // Set the text color to white
                              ),
                            ),
                            SizedBox(height: 10.0),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      child: Image.network(
                        'https://mcdn.wallpapersafari.com/medium/2/58/IXerTc.jpg',
                        width: MediaQuery.of(context).size.width,
                      ),
                    ),
                    SizedBox(height: 40.0),
                    Container(
                      child: Center(
                        child: Text(
                          'LOGIN',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white, // Set the text color to white
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    TextFormField(
                      controller: driverIdController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        hintText: 'Enter username',
                        filled: true, // Set to true to enable filling
                        fillColor: Colors.white, // Set the background color
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter username';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20.0),
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter password',
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
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      child: Card(
                        child: Column(
                          children: [
                            RadioListTile<UserType>(
                              title: Text('Admin'),
                              value: UserType.admin,
                              groupValue: _userType,
                              onChanged: (UserType? value) {
                                setState(() {
                                  _userType = value!;
                                });
                              },
                            ),
                            RadioListTile<UserType>(
                              title: Text('Driver'),
                              value: UserType.login,
                              groupValue: _userType,
                              onChanged: (UserType? value) {
                                setState(() {
                                  _userType = value!;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: _onLoginButtonPressed,
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                      ),
                      child: Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.green,
                        ),
                      ),
                    ),
                    SizedBox(height: 20.0),
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
