import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  static const route = '/notifications';

  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Retrieve the message from the route arguments
    final message = ModalRoute.of(context)!.settings.arguments as RemoteMessage;

    // --- START OF CORRECTION ---
    // Read title and body from the DATA payload, not the notification object
    final title = message.data['title'] ?? 'No Title From Data';
    final body = message.data['body'] ?? 'No Body From Data';
    final imageUrl = message.data['image']; // Use 'image' key from backend
    // --- END OF CORRECTION ---

    return Scaffold(
      appBar: AppBar(
        // Use the title from the data payload
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView( // Added for long content
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title, // Use the title from the data payload
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                body, // Use the body from the data payload
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              // Display the image if the URL is in the data payload
              if (imageUrl != null && imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.network(imageUrl),
                )
              else
                const Text('No image attached.'),
            ],
          ),
        ),
      ),
    );
  }
}