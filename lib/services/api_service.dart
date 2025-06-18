import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import '../models/meal.dart';

class ApiService {
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080';
    static Future<MessMenuResponse> getMessMenu(int year, String month) async {
    final url = Uri.parse('$baseUrl/mess-menu?year=$year&month=$month');
    
    try {
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        // Log success for debugging
        debugPrint('Successfully fetched mess menu data');
        return MessMenuResponse.fromJson(jsonData);
      } else {
        // More detailed error logging
        debugPrint('API error: Status code ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to load mess menu: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('API exception: $e');
      throw Exception('Failed to connect to server: $e');
    }
  }
    static List<Meal> convertToMealsList(MessMenuResponse menuResponse, int year, String month) {
    List<Meal> meals = [];
    final Map<String, int> dayMapping = {
      'monday': 0,
      'tuesday': 1,
      'wednesday': 2,
      'thursday': 3,
      'friday': 4,
      'saturday': 5,
      'sunday': 6,
    };
    
    menuResponse.weekMenu.forEach((day, dayMenu) {
      // Make sure the day string is trimmed and lowercase for more robust mapping
      final String normalizedDay = day.trim().toLowerCase();
      final int dayIndex = dayMapping[normalizedDay] ?? 0;
      
      // Add breakfast
      meals.add(Meal(
        year: year,
        month: getMonthNumber(month),
        day: dayIndex,
        type: 'Breakfast',
        time: Meal.getMealTime('Breakfast'),
        dailyItem: dayMenu.breakfast,
        regulars: 'Standard breakfast items',
        vegspecials: '',
        nonvegspecials: '',
      ));
      
      // Add lunch
      meals.add(Meal(
        year: year,
        month: getMonthNumber(month),
        day: dayIndex,
        type: 'Lunch',
        time: Meal.getMealTime('Lunch'),
        dailyItem: dayMenu.lunch,
        regulars: 'Standard lunch items',
        vegspecials: '',
        nonvegspecials: '',
      ));
      
      // Add snacks
      meals.add(Meal(
        year: year,
        month: getMonthNumber(month),
        day: dayIndex,
        type: 'Snacks',
        time: Meal.getMealTime('Snacks'),
        dailyItem: dayMenu.snacks,
        regulars: 'Standard snack items',
        vegspecials: '',
        nonvegspecials: '',
      ));
      
      // Add dinner
      meals.add(Meal(
        year: year,
        month: getMonthNumber(month),
        day: dayIndex,
        type: 'Dinner',
        time: Meal.getMealTime('Dinner'),
        dailyItem: dayMenu.dinner,
        regulars: 'Standard dinner items',
        vegspecials: '',
        nonvegspecials: '',
      ));
    });
    
    return meals;
  }
  
  static int getMonthNumber(String month) {
    final Map<String, int> monthMapping = {
      'january': 1,
      'february': 2,
      'march': 3,
      'april': 4,
      'may': 5,
      'june': 6,
      'july': 7,
      'august': 8,
      'september': 9,
      'october': 10,
      'november': 11,
      'december': 12,
    };
    
    return monthMapping[month.toLowerCase()] ?? 1;
  }
}
