class User {
  final String name;
  final String? avatarUrl; // ADD THIS

  User({required this.name, this.avatarUrl}); // ADD THIS

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] ?? 'Unknown Owner',
      avatarUrl: json['avatarUrl'], // ADD THIS
    );
  }
}

// Make the same change for the Finder class
class Finder {
  final String name;
  final String? avatarUrl; // ADD THIS

  Finder({required this.name, this.avatarUrl}); // ADD THIS

  factory Finder.fromJson(Map<String, dynamic> json) {
    return Finder(
      name: json['name'] ?? 'Anonymous Finder',
      avatarUrl: json['avatarUrl'], // ADD THIS
    );
  }
}
// The main class for a lost or found item
class FoundItem {
  final String id;
  final String name;
  final String date;
  final String location;
  final String category;
  final String imageUrl;
  final bool isLost;
  final List<String> imageList;
  final String description;
  final User? owner;
  final Finder? finder;

  FoundItem({
    required this.id,
    required this.name,
    required this.date,
    required this.location,
    required this.category,
    required this.imageUrl,
    required this.isLost,
    this.imageList = const [],
    this.description = "",
    this.owner,
    this.finder,
  });

  factory FoundItem.fromJson(Map<String, dynamic> json) {
    bool isLostItem = json['type'] == 'LOST';
    String imageUrl =
        json['media']?['publicUrl'] ?? 'https://via.placeholder.com/150';

    return FoundItem(
      id: '#${isLostItem ? 'L' : 'F'}${json['id'].toString().padLeft(4, '0')}',
      name: json['extraInfo'] ?? 'No Title Provided',
      date: 'Date not provided', // API 'time' field is null
      location: json['landmarkName']?.trim() ?? 'Location unknown',
      category: 'General', // API doesn't provide a category
      imageUrl: imageUrl,
      isLost: isLostItem,
      imageList: [imageUrl],
      description: json['extraInfo'] ?? 'No description available.',
      owner: json['owner'] != null ? User.fromJson(json['owner']) : null,
      finder: json['finder'] != null ? Finder.fromJson(json['finder']) : null,
    );
  }
}