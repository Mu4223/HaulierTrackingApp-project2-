import 'package:flutter/material.dart';

class Schedule {
  String truckId;
  String pickup;
  String delivery;
  DateTime date; // Date only, without time
  TimeOfDay time; // Time only, without date

  Schedule({
    required this.truckId,
    required this.pickup,
    required this.delivery,
    required this.date,
    required this.time,
  });
}
