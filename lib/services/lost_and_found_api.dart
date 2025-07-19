import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/lost_and_found.dart'; // Make sure you have this model
import 'package:image_picker/image_picker.dart';

class LostAndFoundApiService {
  // Get the base URL from environment variables, with a fallback
  static final String _apiBaseUrl = dotenv.env['API_BASE_URL']!;

  /// Fetches lost or found items from the API.
  Future<Map<String, dynamic>> _fetchUserDetails(String? username) async {
    if (username == null || username.isEmpty) {
      return {};
    }
    final Uri url = Uri.parse('$_apiBaseUrl/api/users/getUserLimited?username=$username');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        // CORRECTED: The decoded body is the user object itself.
        return json.decode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      print("Could not fetch details for $username: $e");
    }
    return {}; // Return empty map on failure
  }

  Future<List<FoundItem>> fetchItems(String type) async {
    final Uri url = Uri.parse('$_apiBaseUrl/api/lostnfound/?type=$type');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        final List<dynamic> itemsJson = body['data'] ?? [];

        // Create a list of futures that will enrich each item with user details
        List<Future<Map<String, dynamic>>> futures = itemsJson.map((item) async {
          final Map<String, dynamic> mutableItem = Map.from(item);

          // Fetch details for owner and finder in parallel
          final results = await Future.wait([
            _fetchUserDetails(mutableItem['owner']?['userName']),
            _fetchUserDetails(mutableItem['finder']?['userName']),
          ]);

          final ownerDetails = results[0];
          final finderDetails = results[1];

          // Update the item's owner and finder objects with the fetched name
          if (mutableItem['owner'] != null && ownerDetails['name'] != null) {
            mutableItem['owner']['name'] = ownerDetails['name'];
          }
          if (mutableItem['finder'] != null && finderDetails['name'] != null) {
            mutableItem['finder']['name'] = finderDetails['name'];
          }

          return mutableItem;
        }).toList();

        // Wait for all items to be enriched with user data
        final List<Map<String, dynamic>> enrichedItems = await Future.wait(futures);

        // Convert the final list of enriched JSON objects into FoundItem models
        return enrichedItems.map((itemJson) => FoundItem.fromJson(itemJson)).toList();
      } else {
        throw Exception('Failed to load items: Status code ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred while fetching items: $e');
    }
  }
  /// Fetches a list of locations from the /lostnfound/locations endpoint.
  Future<List<String>> fetchLocations() async {
    final Uri url = Uri.parse('$_apiBaseUrl/api/lostnfound/locations');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> apiResponse = json.decode(response.body);
        final List<dynamic> dataList = apiResponse['data'] ?? [];
        return dataList.map((item) => item.toString().trim()).toList();
      } else {
        throw Exception('Failed to load locations: Status code ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred while fetching locations: $e');
    }
  }

  Future<String> uploadImage({
    required XFile imageFile,
    required String authToken,
  }) async {
    final Uri url = Uri.parse('$_apiBaseUrl/api/lostnfound/image');
    var request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $authToken';
    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 201) {
        return json.decode(response.body)['data'];
      } else {
        throw Exception('Image upload failed: Status ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred during image upload: $e');
    }
  }

  // Method 2: Creates the post with a JSON body
  Future<void> createPost({
    required String landmarkName,
    required String type,
    required String extraInfo,
    required String mediaUrl, // The URL from the uploadImage step
    required String time,
    required String authToken,
  }) async {
    final Uri url = Uri.parse('$_apiBaseUrl/api/lostnfound/');
    final Map<String, dynamic> body = {
      "landmarkName": landmarkName,
      "type": type,
      "extraInfo": extraInfo,
      "status": true,
      "media": {"publicUrl": mediaUrl},
      "time": time
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $authToken',
        },
        body: json.encode(body),
      );
      if (response.statusCode != 201) {
        throw Exception('Failed to create post: Status ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred while creating post: $e');
    }
  }
}