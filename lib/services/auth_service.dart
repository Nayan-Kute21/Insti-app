import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();
  static final String _baseUrl = dotenv.env['API_BASE_URL']!;
  static const String _callbackUrlScheme = 'instiapp';
  static const String _tokenStorageKey = 'jwt_token';

  // --- Public Methods ---

  /// Initiates the OAuth 2.0 login flow.
  /// Returns true on success, false on failure.
  Future<bool> signInWithOAuth() async {
    final url = '$_baseUrl/oauth2/authorization/google?state=mobile';

    try {
      // Present the OAuth login page to the user.
      final result = await FlutterWebAuth2.authenticate(
        url: url,
        callbackUrlScheme: _callbackUrlScheme,
      );

      // Extract the token from the redirect URL.
      // The redirect URL will be like: instiapp://callback?token=...
      final token = Uri.parse(result).queryParameters['token'];

      if (token != null && token.isNotEmpty) {
        // Store the token securely.
        await _storage.write(key: _tokenStorageKey, value: token);
        debugPrint("Auth Success: Token stored.");
        return true;
      } else {
        debugPrint("Auth Error: Token not found in redirect URL.");
        return false;
      }
    } catch (e) {
      debugPrint("Auth Exception: $e");
      return false;
    }
  }

  /// Signs the user out by deleting the token.
  Future<void> signOut() async {
    await _storage.delete(key: _tokenStorageKey);
    debugPrint("User signed out.");
  }

  /// Retrieves the stored JWT token.
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenStorageKey);
  }

  /// Checks if a user is currently authenticated.
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null;
  }
}