import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Import the data models from your screen file
import '../screens/busSchedule.dart';
import '../models/bus.dart';
class BusApiService {
  // Use the environment variable for the base URL.
  // The '!' asserts that the value is not null. Ensure it's set in your .env file.
  static final String _baseUrl = dotenv.env['API_BASE_URL']!;

  /// Fetches all bus numbers and then retrieves the schedule for each one.
  Future<List<BusSchedule>> fetchAllSchedules() async {
    try {
      // 1. Fetch all bus numbers
      final numbersResponse = await http.get(Uri.parse('$_baseUrl/api/bus-numbers'));
      if (numbersResponse.statusCode != 200) {
        throw Exception('Failed to load bus numbers');
      }
      final List<String> busNumbers = List<String>.from(json.decode(numbersResponse.body));

      // 2. Fetch the schedule for each bus number concurrently
      final List<Future<BusSchedule>> scheduleFutures = busNumbers.map((busNumber) async {
        final scheduleResponse = await http.get(Uri.parse('$_baseUrl/api/bus-schedule?busNumber=$busNumber'));
        print('RAW JSON for $busNumber: ${scheduleResponse.body}');
        if (scheduleResponse.statusCode == 200) {
          return BusSchedule.fromJson(json.decode(scheduleResponse.body));
        } else {
          // You might want to handle this more gracefully than throwing an error
          // that stops the entire process. For now, we'll throw.
          throw Exception('Failed to load schedule for bus $busNumber');
        }
      }).toList();

      // 3. Wait for all fetches to complete and return the list of schedules
      final List<BusSchedule> schedules = await Future.wait(scheduleFutures);
      return schedules;

    } catch (e) {
      // For a production app, use a proper logging service
      print('Error fetching bus schedules: $e');
      rethrow; // Rethrow the error to be caught by the FutureBuilder
    }
  }
}