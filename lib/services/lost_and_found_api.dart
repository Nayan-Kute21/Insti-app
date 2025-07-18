import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // 1. Import the package
import 'package:http/http.dart' as http;

class LostAndFoundApiService {

  /// Fetches a list of locations from the /lostnfound/locations endpoint.
  Future<List<String>> fetchLocations() async {
    // 2. Get the base URL from environment variables
    final String? apiBaseUrl = dotenv.env['API_BASE_URL'];

    // 3. Add a check to ensure the URL was loaded correctly
    if (apiBaseUrl == null || apiBaseUrl.isEmpty) {
      throw Exception('API_BASE_URL is not set in the .env file');
    }

    final Uri url = Uri.parse('$apiBaseUrl/api/lostnfound/locations');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> apiResponse = json.decode(response.body);
        final List<dynamic> dataList = apiResponse['data'];
        final List<String> locations =
        dataList.map((item) => item.toString().trim()).toList();
        return locations;
      } else {
        throw Exception('Failed to load locations: Status code ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred while fetching locations: $e');
    }
  }
}