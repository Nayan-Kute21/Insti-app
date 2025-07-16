import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import '../models/meal.dart';

class ApiService {
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? 'https://iitj-insti-app-backend.onrender.com/api';
  
  static Future<MessMenuResponse> getMessMenu(int year, String month) async {
    // Convert month name to number for the API
    int monthNumber = getMonthNumber(month);
    final url = Uri.parse('$baseUrl/mess-menu?year=$year&month=$monthNumber');
    
    try {
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        // Log success for debugging
        debugPrint('Successfully fetched mess menu data');
        
        // Handle the case where the response is a List
        if (jsonData is List) {
          return MessMenuResponse.fromJson(jsonData);
        } else {
          throw Exception('Unexpected API response format');
        }
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
    
    for (var dailyMenu in menuResponse.dailyMenus) {
      // Parse breakfast
      var breakfastData = parseMenuItemToJson(dailyMenu.menuItemBreakfast);
      meals.add(Meal(
        year: dailyMenu.year,
        month: dailyMenu.month,
        day: dailyMenu.day,
        type: 'Breakfast',
        time: Meal.getMealTime('Breakfast'),
        dailyItem: breakfastData['commonItems'] ?? '',
        regulars: breakfastData['compulsoryItems'] ?? '',
        vegspecials: breakfastData['vegSpecials'] ?? '',
        nonvegspecials: breakfastData['nonVegSpecials'] ?? '',
      ));
      
      // Parse lunch
      var lunchData = parseMenuItemToJson(dailyMenu.menuItemLunch);
      meals.add(Meal(
        year: dailyMenu.year,
        month: dailyMenu.month,
        day: dailyMenu.day,
        type: 'Lunch',
        time: Meal.getMealTime('Lunch'),
        dailyItem: lunchData['commonItems'] ?? '',
        regulars: lunchData['compulsoryItems'] ?? '',
        vegspecials: lunchData['vegSpecials'] ?? '',
        nonvegspecials: lunchData['nonVegSpecials'] ?? '',
      ));
      
      // Parse snacks
      var snacksData = parseMenuItemToJson(dailyMenu.menuItemSnacks);
      meals.add(Meal(
        year: dailyMenu.year,
        month: dailyMenu.month,
        day: dailyMenu.day,
        type: 'Snacks',
        time: Meal.getMealTime('Snacks'),
        dailyItem: snacksData['commonItems'] ?? '',
        regulars: snacksData['compulsoryItems'] ?? '',
        vegspecials: snacksData['vegSpecials'] ?? '',
        nonvegspecials: snacksData['nonVegSpecials'] ?? '',
      ));
      
      // Parse dinner
      var dinnerData = parseMenuItemToJson(dailyMenu.menuItemDinner);
      meals.add(Meal(
        year: dailyMenu.year,
        month: dailyMenu.month,
        day: dailyMenu.day,
        type: 'Dinner',
        time: Meal.getMealTime('Dinner'),
        dailyItem: dinnerData['commonItems'] ?? '',
        regulars: dinnerData['compulsoryItems'] ?? '',
        vegspecials: dinnerData['vegSpecials'] ?? '',
        nonvegspecials: dinnerData['nonVegSpecials'] ?? '',
      ));
    }
    
    return meals;
  }
  
  // Helper methods to extract different parts of the menu item
  static String _extractCommonItems(String menuItem) {
    if (menuItem.contains('Common items:')) {
      String commonPart = menuItem.split('Common items:')[1];
      if (commonPart.contains('; VEG MESS:')) {
        commonPart = commonPart.split('; VEG MESS:')[0];
      }
      return commonPart.trim();
    }
    return '';
  }
  
  static String _extractVegSpecials(String menuItem) {
    RegExp vegRegex = RegExp(r'VEG MESS:\s*([^;]+)');
    Match? match = vegRegex.firstMatch(menuItem);
    if (match != null) {
      String vegPart = match.group(1)?.trim() ?? '';
      return (vegPart.isEmpty || vegPart == '-') ? '' : vegPart;
    }
    return '';
  }
  
  static String _extractNonVegSpecials(String menuItem) {
    RegExp nonVegRegex = RegExp(r'NON-VEG MESS:\s*([^;]+)');
    Match? match = nonVegRegex.firstMatch(menuItem);
    if (match != null) {
      String nonVegPart = match.group(1)?.trim() ?? '';
      return (nonVegPart.isEmpty || nonVegPart == '-') ? '' : nonVegPart;
    }
    return '';
  }
  
  static String _extractCompulsoryItems(String menuItem) {
    RegExp compulsoryRegex = RegExp(r'COMPULSORY ITEMS:\s*(.+)$');
    Match? match = compulsoryRegex.firstMatch(menuItem);
    if (match != null) {
      return match.group(1)?.trim() ?? '';
    }
    return '';
  }
  
  // Enhanced method to create a structured JSON-like representation
  static Map<String, dynamic> parseMenuItemToJson(String menuItem) {
    return {
      'commonItems': _extractCommonItems(menuItem),
      'vegSpecials': _extractVegSpecials(menuItem),
      'nonVegSpecials': _extractNonVegSpecials(menuItem),
      'compulsoryItems': _extractCompulsoryItems(menuItem),
      'fullText': menuItem,
    };
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
