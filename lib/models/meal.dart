class Meal {
  final int year;
  final int month;
  final int day;
  final String type;
  final String time;
  final String dailyItem;
  final String regulars;
  final String vegspecials;
  final String nonvegspecials;

  Meal({
    required this.year,
    required this.month,
    required this.day,
    required this.type,
    required this.time,
    required this.dailyItem,
    required this.regulars,
    required this.vegspecials,
    required this.nonvegspecials,
  });

  static String getMealTime(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return '7:30 - 10:00 AM';
      case 'lunch':
        return '12:15 - 2:30 PM';
      case 'snacks':
        return '5:30 - 6:30 PM';
      case 'dinner':
        return '7:30 - 10:00 PM';
      default:
        return '';
    }
  }
}

class MessMenuResponse {
  final List<DailyMenu> dailyMenus;

  MessMenuResponse({required this.dailyMenus});

  factory MessMenuResponse.fromJson(List<dynamic> jsonList) {
    List<DailyMenu> dailyMenus = [];
    
    for (var item in jsonList) {
      if (item is Map<String, dynamic>) {
        dailyMenus.add(DailyMenu.fromJson(item));
      }
    }
    
    return MessMenuResponse(dailyMenus: dailyMenus);
  }
}

class DailyMenu {
  final int year;
  final int month;
  final int day;
  final String menuItemBreakfast;
  final String menuItemLunch;
  final String menuItemSnacks;
  final String menuItemDinner;

  DailyMenu({
    required this.year,
    required this.month,
    required this.day,
    required this.menuItemBreakfast,
    required this.menuItemLunch,
    required this.menuItemSnacks,
    required this.menuItemDinner,
  });

  factory DailyMenu.fromJson(Map<String, dynamic> json) {
    return DailyMenu(
      year: json['year'] ?? 0,
      month: json['month'] ?? 0,
      day: json['day'] ?? 0,
      menuItemBreakfast: json['menuItemBreakfast'] ?? '',
      menuItemLunch: json['menuItemLunch'] ?? '',
      menuItemSnacks: json['menuItemSnacks'] ?? '',
      menuItemDinner: json['menuItemDinner'] ?? '',
    );
  }
}
