import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import '../widgets/mealCard.dart';
import '../models/meal.dart';

class MessMenuPage extends StatefulWidget {
  const MessMenuPage({super.key});

  @override
  _MessMenuPageState createState() => _MessMenuPageState();
}

class _MessMenuPageState extends State<MessMenuPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Meal> meals = [];
  bool showVeg = true;
  bool showNonVeg = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 7, vsync: this, initialIndex: DateTime.now().weekday - 1);
    loadJsonAsset();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> loadJsonAsset() async {
    final String jsonString =
        await rootBundle.loadString('assets/messMenu.json');
    final Map<String, dynamic> jsonData = jsonDecode(jsonString);

    List<Meal> parsedMeals = [];

    for (var item in jsonData['menuData']) {
      parsedMeals.add(Meal(
        year: item['year'],
        month: item['month'],
        day: item['day'],
        type: 'Breakfast',
        time: '7:30 - 10:00 AM',
        dailyItem: item['menuItemBreakfast']['daily'],
        regulars: item['menuItemBreakfast']['regulars'],
        vegspecials: item['menuItemBreakfast']['specials']['veg'],
        nonvegspecials: item['menuItemBreakfast']['specials']['nonveg'],
      ));
      parsedMeals.add(Meal(
        year: item['year'],
        month: item['month'],
        day: item['day'],
        type: 'Lunch',
        time: '12:15 - 2:30 PM',
        dailyItem: item['menuItemLunch']['daily'],
        regulars: item['menuItemLunch']['regulars'],
        vegspecials: item['menuItemLunch']['specials']['veg'],
        nonvegspecials: item['menuItemLunch']['specials']['nonveg'],
      ));
      parsedMeals.add(Meal(
        year: item['year'],
        month: item['month'],
        day: item['day'],
        type: 'Snacks',
        time: '5:30 - 6:30 PM',
        dailyItem: item['menuItemSnacks']['daily'],
        regulars: item['menuItemSnacks']['regulars'],
        vegspecials: item['menuItemSnacks']['specials']['veg'],
        nonvegspecials: item['menuItemSnacks']['specials']['nonveg'],
      ));
      parsedMeals.add(Meal(
        year: item['year'],
        month: item['month'],
        day: item['day'],
        type: 'Dinner',
        time: '7:30 - 10:00 PM',
        dailyItem: item['menuItemDinner']['daily'],
        regulars: item['menuItemDinner']['regulars'],
        vegspecials: item['menuItemDinner']['specials']['veg'],
        nonvegspecials: item['menuItemDinner']['specials']['nonveg'],
      ));
    }

    setState(() {
      meals = parsedMeals;
    });
  }

  String getCurrentMealType() {
    final now = DateTime.now();
    final format = DateFormat.Hm();

    Map<String, List<String>> mealTimes = {
      "Breakfast": ["07:30", "10:00"],
      "Lunch": ["12:15", "14:30"],
      "Snacks": ["17:30", "18:30"],
      "Dinner": ["19:30", "22:00"],
    };

    String currentTime = format.format(now);

    for (var entry in mealTimes.entries) {
      if (currentTime.compareTo(entry.value[0]) >= 0 &&
          currentTime.compareTo(entry.value[1]) <= 0) {
        return entry.key;
      }
    }

    return "";
  }

  @override
  Widget build(BuildContext context) {
    String currentMeal = getCurrentMealType();

    return Scaffold(
      backgroundColor: const Color.fromRGBO(239, 243, 250, 1),
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text('Mess Menu 👩‍🍳'),
        ),
        backgroundColor: const Color.fromRGBO(239, 243, 250, 1),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              Container(height: 1, color: Colors.grey),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.green,
                  tabs: const [
                    Tab(text: 'MONDAY'),
                    Tab(text: 'TUESDAY'),
                    Tab(text: 'WEDNESDAY'),
                    Tab(text: 'THURSDAY'),
                    Tab(text: 'FRIDAY'),
                    Tab(text: 'SATURDAY'),
                    Tab(text: 'SUNDAY'),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4, left: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FilterChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.circle,
                                size: 10, color: Colors.green),
                            const SizedBox(width: 6),
                            Text(
                              "Veg",
                              style: TextStyle(
                                color: showVeg ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),
                        selected: showVeg,
                        onSelected: (selected) {
                          if (!selected && !showNonVeg) return;
                          setState(() {
                            showVeg = selected;
                          });
                        },
                        selectedColor: const Color.fromARGB(255, 34, 100, 243),
                        backgroundColor: Colors.white,
                        showCheckmark: false,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      const SizedBox(width: 10),
                      FilterChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.circle,
                                size: 10, color: Colors.red),
                            const SizedBox(width: 6),
                            Text(
                              "Non-Veg",
                              style: TextStyle(
                                color: showNonVeg ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),
                        selected: showNonVeg,
                        onSelected: (selected) {
                          if (!selected && !showVeg) return;
                          setState(() {
                            showNonVeg = selected;
                          });
                        },
                        selectedColor: const Color.fromARGB(255, 34, 100, 243),
                        backgroundColor: Colors.white,
                        showCheckmark: false,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: List.generate(7, (index) => buildDayMenu(index, currentMeal)),
      ),
    );
  }

  Widget buildDayMenu(int dayIndex, String currentMeal) {
    List<Meal> filteredMeals =
        meals.where((meal) => meal.day == dayIndex).toList();

    List<Widget> mealWidgets = [];

    for (var meal in filteredMeals) {
      bool isCurrentMeal = meal.type == currentMeal;

      mealWidgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                meal.type,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                meal.time,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isCurrentMeal ? Colors.blue : Colors.grey,
                ),
              ),
              MealCard(
                meal: meal,
                showVeg: showVeg,
                showNonVeg: showNonVeg,
                isCurrentMeal: isCurrentMeal,
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: mealWidgets,
    );
  }
}
