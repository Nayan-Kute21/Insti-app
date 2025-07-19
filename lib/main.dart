import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../screens/auth_wrapper.dart'; // Import the AuthWrapper
import 'package:insti_app/screens/notifications_screen.dart';
import 'package:insti_app/services/firebase_api.dart';
import 'package:firebase_core/firebase_core.dart'; // Core Firebase package
import 'firebase_options.dart';                   // Auto-generated options

Future<void> main() async {
  // Ensure Flutter is initialized before loading assets or plugins
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Initialize notifications AFTER Firebase is initialized
  await FirebaseApi().initNotifications();

  // Configure channel buffers to handle messages properly
  const MethodChannel('flutter/keyevent')
      .setMethodCallHandler((MethodCall call) async {
    // Handle key events if needed
    return null;
  });

  try {
    // Load environment variables from the root directory
    await dotenv.load();
  } catch (e) {
    debugPrint('Failed to load .env file: $e');
    // Continue without environment variables, using default values
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Institute App',
      navigatorKey: FirebaseApi.navigatorKey,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // Use system font as fallback if custom font fails
        fontFamily: 'Bricolage Grotesque',
      ),
      // Set AuthWrapper as the home screen to handle the login flow
      home: const AuthWrapper(),
      routes: {
        NotificationsScreen.route: (context) => const NotificationsScreen(),
      },
      debugShowCheckedModeBanner: false, // Hides the debug banner
    );
  }
}