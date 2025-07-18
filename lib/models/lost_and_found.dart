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
  });
}