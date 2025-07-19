// lib/clubs_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/organisation_api.dart'; // Import the new service

class ClubsScreen extends StatefulWidget {
  const ClubsScreen({super.key});

  @override
  State<ClubsScreen> createState() => _ClubsScreenState();
}

class _ClubsScreenState extends State<ClubsScreen> {
  final ApiService _apiService = ApiService();
  late Future<Map<String, List<ApiOrganization>>> _organizationsFuture;

  @override
  void initState() {
    super.initState();
    _organizationsFuture = _fetchAllOrganizations();
  }

  Future<Map<String, List<ApiOrganization>>> _fetchAllOrganizations() async {
    final types = await _apiService.fetchOrganizationTypes();
    final Map<String, List<ApiOrganization>> organizationsMap = {};
    for (var type in types) {
      organizationsMap[type] = await _apiService.fetchOrganizationsByType(type);
    }
    return organizationsMap;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, List<ApiOrganization>>>(
      future: _organizationsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text('Error: ${snapshot.error}')));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Scaffold(body: Center(child: Text('No organizations found.')));
        }

        final organizationsMap = snapshot.data!;
        final types = organizationsMap.keys.toList();

        return DefaultTabController(
          length: types.length,
          child: Scaffold(
            backgroundColor: const Color(0xFFEFF3FA),
            appBar: AppBar(
              backgroundColor: const Color(0xFFEFF3FA),
              elevation: 0,
              // MODIFIED: Added a functional leading IconButton for back navigation
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  size: 20,
                  color: Color(0xFF132E9E),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              // MODIFIED: Title is now just the Text widget
              title: Text(
                'Clubs',
                style: GoogleFonts.bricolageGrotesque(
                  color: const Color(0xFF132E9E),
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              bottom: TabBar(
                isScrollable: true,
                labelColor: const Color(0xFF0D0F14),
                unselectedLabelColor: const Color(0xFF687A8C),
                indicatorColor: const Color(0xFF97DB50),
                indicatorWeight: 3,
                tabs: types.map((type) => Tab(text: type)).toList(),
                labelStyle: GoogleFonts.bricolageGrotesque(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // MODIFIED: The Column and its child Expanded are no longer needed
            body: TabBarView(
              children: types.map((type) {
                final orgs = organizationsMap[type]!;
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: orgs.length,
                  itemBuilder: (context, index) {
                    return OrganizationTile(organization: orgs[index]);
                  },
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
// REMOVED: The _buildSearchBar method is no longer needed
}

class OrganizationTile extends StatelessWidget {
  final ApiOrganization organization;
  const OrganizationTile({super.key, required this.organization});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD9DBE0), width: 0.5),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundImage: NetworkImage(organization.avatarUrl),
            onBackgroundImageError: (_, __) {},
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  organization.name,
                  style: GoogleFonts.bricolageGrotesque(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (organization.description.isNotEmpty)
                  Text(
                    organization.description,
                    style: GoogleFonts.rubik(
                      color: const Color(0xFF434B66),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}