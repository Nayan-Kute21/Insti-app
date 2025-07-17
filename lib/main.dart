import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dashboard.dart';

Future<void> main() async {
  // Ensure Flutter is initialized before loading assets or plugins
  WidgetsFlutterBinding.ensureInitialized();

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
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // Use system font as fallback if custom font fails
        fontFamily: 'Bricolage Grotesque',
      ),
      home: const DashboardPage(),
    );
  }
}
