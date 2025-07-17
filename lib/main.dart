import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'dashboard.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Optional: Only use if you're handling raw key events
  // If not needed, you can remove this block entirely
  const MethodChannel('flutter/keyevent')
      .setMethodCallHandler((MethodCall call) async {
    // TODO: Handle key events if necessary
    return null;
  });

  // Load environment variables from .env file
  try {
    await dotenv.load(fileName: ".env");
    debugPrint('Environment variables loaded successfully.');
  } catch (e) {
    debugPrint('Failed to load .env file: $e');
    // Optional: fallback strategy or app exit
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Institute App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Bricolage Grotesque', // Fallback handled by Flutter
        scaffoldBackgroundColor: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const DashboardPage(),
    );
  }
}
