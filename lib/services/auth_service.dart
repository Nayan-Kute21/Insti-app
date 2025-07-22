import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import 'package:http_parser/http_parser.dart';

import 'firebase_api.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();
  static final String baseUrl = dotenv.env['API_BASE_URL']!;
  // This is the OAuth client ID you get from Google Cloud Console for your backend.
  static final String? _serverClientId = dotenv.env['GOOGLE_SERVER_CLIENT_ID'];
  static const String _tokenStorageKey = 'jwt_token';

  // Instance of GoogleSignIn
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // This is required for the web platform
    clientId: _serverClientId,

    scopes: ['email', 'profile'],
    serverClientId: _serverClientId,
  );

  /// Initiates the Google Sign-In flow and exchanges the token with your backend.
  /// Returns true on success, false on failure.
  Future<bool> signInWithOAuth() async {
    try {
      // 1. Trigger the Google authentication flow.
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // The user canceled the sign-in.
        debugPrint("Auth Cancelled: User closed the Google Sign-In prompt.");
        return false;
      }

      // 2. Obtain the auth details from the request.
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        debugPrint("Auth Error: idToken is null.");
        return false;
      }

      // 3. Exchange the Google idToken for your backend's JWT.
      return await _exchangeTokenForJwt(idToken);

    } catch (e) {
      debugPrint("Auth Exception: $e");
      return false;
    }
  }

  /// Sends the Google idToken to the backend and stores the returned JWT.
  Future<bool> _exchangeTokenForJwt(String idToken) async {
    // IMPORTANT: Replace with your actual backend endpoint for verifying Google tokens.
    final url = Uri.parse('$baseUrl/api/v1/auth/google/signin');
    debugPrint("id Token: $idToken");
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'token': idToken}),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final jwtToken = responseBody['accessToken']; // IMPORTANT: Adjust key based on your backend response.

        if (jwtToken != null && jwtToken.isNotEmpty) {
          await _storage.write(key: _tokenStorageKey, value: jwtToken);
          debugPrint("Auth Success: JWT from backend stored.");
          FirebaseApi().registerDeviceTokenAfterLogin();
          _sendWelcomeNotification();
          return true;
        } else {
          debugPrint("Auth Error: JWT not found in backend response.");
          return false;
        }
      } else {
        debugPrint("Auth Error: Backend returned status ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("Backend Exchange Exception: $e");
      return false;
    }
  }

  /// Signs the user out from Google and deletes the local token.
  Future<void> signOut() async {
    await _googleSignIn.signOut(); // Sign out from Google.
    await _storage.delete(key: _tokenStorageKey); // Delete local JWT.
    debugPrint("User signed out from Google and app.");
  }

  /// Retrieves the stored JWT token.
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenStorageKey);
  }

  /// Checks if a user is currently authenticated with a valid JWT.
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    // In a real app, you might also want to verify if the token is expired.
    return token != null;
  }
  /// Sends a welcome push notification to the user after they log in.
  Future<void> _sendWelcomeNotification() async {
    // Get the JWT that was just stored.
    final jwt = await getToken();
    if (jwt == null) {
      debugPrint("Welcome Notification Error: Could not retrieve JWT.");
      return;
    }

    // The backend endpoint for sending a single notification.
    final url = Uri.parse('$baseUrl/api/notification/single');

    try {
      // 1. Create a multipart request since the endpoint expects form-data.
      final request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $jwt';

      // 2. Create the JSON part of the request payload.
      final notificationPayload = {
        'title': 'Welcome to IITJ Insti-App!',
        'body': 'We\'re glad to see you here. Explore events, schedules, and more.',
        'topic': 'Welcome' // Or any default topic you prefer
      };

      // 3. Add the JSON data as a 'request' part. This must match the @RequestPart name.
      request.files.add(http.MultipartFile.fromString(
        'request',
        json.encode(notificationPayload),
        contentType: MediaType('application', 'json'),
      ));

      // Note: We are not adding a 'file' part, which is correctly handled as optional by your backend.

      // 4. Send the request and log the outcome.
      final response = await request.send();

      if (response.statusCode == 200) {
        debugPrint("Welcome notification sent successfully.");
      } else {
        final responseBody = await response.stream.bytesToString();
        debugPrint("Failed to send welcome notification. Status: ${response.statusCode}, Body: $responseBody");
      }
    } catch (e) {
      debugPrint("Exception while sending welcome notification: $e");
    }
  }
}