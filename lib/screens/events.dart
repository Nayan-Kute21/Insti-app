import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:timeago/timeago.dart' as timeago; // For relative timestamps
import '../services/events_api.dart'; // Import the new service
import 'club_screen.dart';

// Updated Event Model
class Event {
  final String ownerUsername;
  final String title;
  final String description;
  final DateTime eventDateTime; // Combined date and time
  final String? eventImageUrl; // Can be null if the list is empty

  // --- Mapped properties for UI ---
  String get organizer => ownerUsername; // Using username as organizer for now
  String get organizerImageUrl => 'https://placehold.co/40x40/FFC107/000000?text=${organizer.substring(0, 2).toUpperCase()}';
  String get timestamp => timeago.format(eventDateTime);
  String get date => DateFormat('d MMMM yyyy').format(eventDateTime); // e.g., 8 April 2025
  String get time => DateFormat('h:mm a').format(eventDateTime); // e.g., 9:00 PM
  String get location => 'Venue TBD'; // API doesn't provide location, so using a default

  Event({
    required this.ownerUsername,
    required this.title,
    required this.description,
    required this.eventDateTime,
    this.eventImageUrl,
  });

  // Factory constructor to parse JSON
  factory Event.fromJson(Map<String, dynamic> json) {
    // Combine date and startTime from the API into a single DateTime object
    final DateTime parsedDate = DateTime.parse(json['date']);
    final timeParts = json['startTime'].split(':');
    final DateTime eventDateTime = DateTime(
      parsedDate.year,
      parsedDate.month,
      parsedDate.day,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );

    // Use the first image URL if available, otherwise null
    final List<dynamic> mediaUrls = json['eventsMediauRL'];
    final String? imageUrl = mediaUrls.isNotEmpty ? mediaUrls.first : null;

    return Event(
      ownerUsername: json['ownerUsername'] ?? 'Unknown Organizer',
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? 'No Description Provided.',
      eventDateTime: eventDateTime,
      eventImageUrl: imageUrl,
    );
  }
}


class EventsAndClubsScreen extends StatefulWidget {
  const EventsAndClubsScreen({super.key});

  @override
  State<EventsAndClubsScreen> createState() => _EventsAndClubsScreenState();
}

class _EventsAndClubsScreenState extends State<EventsAndClubsScreen> {
  late Future<List<Event>> _eventsFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    // Fetch events when the widget is first created
    _eventsFuture = _apiService.fetchEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF3FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEFF3FA),
        elevation: 1,
        shadowColor: const Color(0xFFD9DBE0),
        title: Row(
          children: [
            const SizedBox(width: 8),
            Text(
              'Events and Clubs',
              style: GoogleFonts.bricolageGrotesque(
                color: const Color(0xFF132E9E),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            const Text('🎪', style: TextStyle(fontSize: 20)),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('All Events', showButton: true, context: context),
            _buildAllEventsList(), // This will now use a FutureBuilder
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // --- Reusable Widgets ---

  Widget _buildSectionHeader(String title, {bool showButton = false, required BuildContext context}) {
    // ... same as your original code
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.bricolageGrotesque(
              fontSize: 24,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (showButton)
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ClubsScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E47F7),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                elevation: 4,
                shadowColor: const Color(0x3F0041AB),
              ),
              child: Text(
                'View all Clubs',
                style: GoogleFonts.bricolageGrotesque(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
        ],
      ),
    );
  }

  // Updated to use FutureBuilder to display live data
  Widget _buildAllEventsList() {
    return FutureBuilder<List<Event>>(
      future: _eventsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while fetching data
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          // Show an error message if something went wrong
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          // Show a message if there are no events
          return const Center(child: Text('No events found.'));
        } else {
          // Data is loaded, build the list
          final events = snapshot.data!;
          return ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: events.length,
            itemBuilder: (context, index) => _buildEventCard(events[index]),
            separatorBuilder: (context, index) => const SizedBox(height: 16),
          );
        }
      },
    );
  }

  Widget _buildEventCard(Event event) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0x14000000),
            blurRadius: 16,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(event.organizerImageUrl),
                  backgroundColor: Colors.grey[200],
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.organizer,
                      style: GoogleFonts.bricolageGrotesque(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      event.timestamp,
                      style: GoogleFonts.rubik(
                        color: const Color(0xFF656565),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Card Body
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: GoogleFonts.rubik(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  event.description,
                  style: GoogleFonts.rubik(fontSize: 12, color: Colors.black),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Event Image (handles cases with no image)
          if (event.eventImageUrl != null)
            Image.network(
              event.eventImageUrl!,
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Display a placeholder if the image fails to load
                return Container(
                  height: 250,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported, color: Colors.grey),
                );
              },
            ),
          // Event Details
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDetailItem(Icons.calendar_today, event.date),
                _buildDetailItem(Icons.access_time, event.time),
                _buildDetailItem(
                    event.location == "Google Meet"
                        ? Icons.videocam
                        : Icons.location_on,
                    event.location),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String text) {
    // ... same as your original code
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF34384D)),
        const SizedBox(width: 6),
        Text(
          text,
          style: GoogleFonts.bricolageGrotesque(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavBar() {
    // ... same as your original code
    return Container(
      height: 65,
      decoration: BoxDecoration(
        color: const Color(0xFF34384D),
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 'Home', isSelected: false),
          _buildNavItem(Icons.calendar_today, 'Events', isSelected: true),
          _buildNavItem(Icons.more_horiz, 'More', isSelected: false),
          _buildNavItem(Icons.map, 'Maps', isSelected: false),
          _buildNavItem(Icons.restaurant, 'Mess', isSelected: false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label,
      {required bool isSelected}) {
    // ... same as your original code
    final color = isSelected ? const Color(0xFFD1D7F4) : const Color(0xFF9EA3B0);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isSelected)
          Container(
            height: 4,
            width: 55,
            decoration: BoxDecoration(
                color: const Color(0xFFA2E959),
                borderRadius: BorderRadius.circular(2)),
            margin: const EdgeInsets.only(bottom: 4),
          ),
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.bricolageGrotesque(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}