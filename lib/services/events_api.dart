import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../screens/events.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'auth_service.dart'; // Import AuthService

class ApiService {
  static final String _baseUrl = dotenv.env['API_BASE_URL']!;
  final AuthService _authService = AuthService();

  Future<List<Event>> fetchEvents() async {
    final fullUrl = '$_baseUrl/api/events/getAllEvents';

    // Get the token from secure storage
    final token = await _authService.getToken();

    if (token == null) {
      throw Exception('Not authenticated. Please log in.');
    }

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      // Include the JWT in the Authorization header
      'Authorization': 'Bearer $token',
    };

    debugPrint("Request URL: $fullUrl");
    debugPrint("Request Headers: $headers");

    final response = await http.get(Uri.parse(fullUrl), headers: headers);

    debugPrint("Response Status Code: ${response.statusCode}");
    debugPrint("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = json.decode(response.body);
      final List<dynamic> eventData = body['data'];
      return eventData.map((json) => Event.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load events. Status: ${response.statusCode}, Body: ${response.body}');
    }
  }
}