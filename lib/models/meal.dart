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
  final Map<String, DayMenu> weekMenu;

  MessMenuResponse({required this.weekMenu});
  factory MessMenuResponse.fromJson(Map<String, dynamic> json) {
    Map<String, DayMenu> weekMenu = {};
    
    // Handle different possible API response formats
    if (json.containsKey('data') && json['data'] is Map<String, dynamic>) {
      // If the API wraps the menu in a 'data' field
      json = json['data'] as Map<String, dynamic>;
    }
    
    json.forEach((day, menu) {
      if (menu is Map<String, dynamic>) {
        weekMenu[day] = DayMenu.fromJson(menu);
      }
    });
    
    return MessMenuResponse(weekMenu: weekMenu);
  }
}

class DayMenu {
  final String breakfast;
  final String lunch;
  final String snacks;
  final String dinner;

  DayMenu({
    required this.breakfast,
    required this.lunch,
    required this.snacks,
    required this.dinner,
  });
  factory DayMenu.fromJson(Map<String, dynamic> json) {
    // Helper function to safely extract string values from json
    String getMenuItemSafely(dynamic value) {
      if (value is String) {
        return value;
      } else if (value is List) {
        return value.join(', ');
      } else if (value is Map) {
        return value.values.join(', ');
      }
      return '';
    }
    
    return DayMenu(
      breakfast: getMenuItemSafely(json['breakfast']),
      lunch: getMenuItemSafely(json['lunch']),
      snacks: getMenuItemSafely(json['snacks']),
      dinner: getMenuItemSafely(json['dinner']),
    );
  }
}
