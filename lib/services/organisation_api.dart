// lib/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
// --- DATA MODELS TO MATCH API RESPONSE ---

class ApiOrganization {
  final String name;
  final String userName;
  final String avatarUrl;
  final String parentUserName;
  final String description;

  const ApiOrganization({
    required this.name,
    required this.userName,
    required this.avatarUrl,
    required this.parentUserName,
    required this.description,
  });

  // Factory constructor to parse JSON
  factory ApiOrganization.fromJson(Map<String, dynamic> json) {
    return ApiOrganization(
      name: json['user']['name'] ?? 'Unknown Name',
      userName: json['user']['userName'] ?? '',
      avatarUrl: json['user']['avatarUrl'] ?? 'https://placehold.co/52x52/CCCCCC/FFFFFF?text=?',
      parentUserName: json['parentOrganisationUserUserName'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

// --- API SERVICE CLASS ---

class ApiService {
  static final String _baseUrl = dotenv.env['API_BASE_URL']!;

  // Fetches the list of organization types (e.g., "Board")
  Future<List<String>> fetchOrganizationTypes() async {
    final response = await http.get(Uri.parse('$_baseUrl/api/organisations/types'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<String>.from(data['data']);
    } else {
      throw Exception('Failed to load organization types');
    }
  }

  // Fetches all organizations for a given type
  Future<List<ApiOrganization>> fetchOrganizationsByType(String typeName) async {
    final response = await http.get(Uri.parse('$_baseUrl/api/organisations/by-type?typeName=$typeName'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> orgsJson = data['data'];
      return orgsJson.map((json) => ApiOrganization.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load organizations for type $typeName');
    }
  }
}