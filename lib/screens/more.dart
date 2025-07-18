import 'package:flutter/material.dart';
import 'busSchedule.dart';
import 'lost_and_found.dart'; // 1. Import the Lost & Found screen

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(239, 243, 250, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(239, 243, 250, 1),
        elevation: 0,
        title: const Text(
          'More Options',
          style: TextStyle(
            color: Color.fromRGBO(19, 46, 158, 1),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildOptionCard(
            context,
            'Bus Schedule',
            Icons.directions_bus,
            'View campus bus timings and routes',
                () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BusSchedulePage()),
            ),
          ),
          const SizedBox(height: 16),

          // 2. Added the Lost & Found option card here
          _buildOptionCard(
            context,
            'Lost & Found',
            Icons.search_sharp, // Using a relevant icon
            'Find lost items or report found ones',
                () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LostAndFoundScreen()),
            ),
          ),
          const SizedBox(height: 16),

          _buildOptionCard(
            context,
            'Option 1',
            Icons.star,
            'Description for Option 1',
                () {},
          ),
          const SizedBox(height: 16),
          _buildOptionCard(
            context,
            'Option 2',
            Icons.settings,
            'Description for Option 2',
                () {},
          ),
        ],
      ),
    );
  }

  // This helper method remains unchanged
  Widget _buildOptionCard(
      BuildContext context,
      String title,
      IconData icon,
      String description,
      VoidCallback onTap,
      ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(52, 57, 77, 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}