import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Helper function to parse time strings like "17:30:00" into TimeOfDay
TimeOfDay _parseTime(String timeString) {
  final parts = timeString.split(':');
  return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
}

// Helper function to format TimeOfDay into a "hh:mm a" string
String formatTime(TimeOfDay time) {
  final now = DateTime.now();
  final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
  return DateFormat('hh:mm a').format(dt);
}


// DATA MODELS
enum ScheduleType { WEEKDAY, WEEKEND, ALL_DAYS }

class RouteStop {
  final String locationName;
  final int stopOrder;
  final TimeOfDay arrivalTime;
  final TimeOfDay departureTime;

  RouteStop({
    required this.locationName,
    required this.stopOrder,
    required this.arrivalTime,
    required this.departureTime,
  });

  factory RouteStop.fromJson(Map<String, dynamic> json) {
    return RouteStop(
      locationName: json['locationName'],
      stopOrder: json['stopOrder'],
      arrivalTime: _parseTime(json['arrivalTime']),
      departureTime: _parseTime(json['departureTime']),
    );
  }
}

class BusRoute {
  final String routeName;
  final List<RouteStop> stops;

  BusRoute({required this.routeName, required this.stops});

  factory BusRoute.fromJson(Map<String, dynamic> json) {
    var stopsList = json['stops'] as List;
    List<RouteStop> stops =
    stopsList.map((i) => RouteStop.fromJson(i)).toList();
    stops.sort((a, b) => a.stopOrder.compareTo(b.stopOrder));
    return BusRoute(
      routeName: json['routeName'],
      stops: stops,
    );
  }
}

class BusRun {
  final String busNumber;
  final BusRoute route;
  final TimeOfDay startTime;
  final ScheduleType scheduleType;

  BusRun({
    required this.busNumber,
    required this.route,
    required this.startTime,
    required this.scheduleType,
  });

  factory BusRun.fromJson(Map<String, dynamic> json) {
    return BusRun(
      busNumber: json['busNumber'],
      route: BusRoute.fromJson(json['route']),
      startTime: _parseTime(json['startTime']),
      scheduleType: (json['scheduleType'] as String).toLowerCase() == 'weekday'
          ? ScheduleType.WEEKDAY
          : ScheduleType.WEEKEND,
    );
  }
}

class BusSchedule {
  final String busNumber;
  final List<BusRun> runs;

  BusSchedule({required this.busNumber, required this.runs});

  factory BusSchedule.fromJson(Map<String, dynamic> json) {
    var runsList = json['runs'] as List;
    List<BusRun> runs = runsList.map((i) => BusRun.fromJson(i)).toList();
    return BusSchedule(
      busNumber: json['busNumber'],
      runs: runs,
    );
  }
}
