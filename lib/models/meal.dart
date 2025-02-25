class Meal {
  final String type;
  final String time;
  final String dailyItem;
  final List<String> specials;
  final List<String> regulars;

  Meal({
    required this.type,
    required this.time,
    required this.dailyItem,
    this.specials = const [],
    this.regulars = const [],
  });
}
