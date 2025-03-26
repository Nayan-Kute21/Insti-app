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

  // Store global keys for each meal card to measure their height
  final Map<String, GlobalKey> _mealCardKeys = {};

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

  // Show report issue dialog
  void _showReportIssueDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Report Mess Issue'),
          content: const Text('Please report any mess issues to mess@abc.com'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String currentMeal = getCurrentMealType();
    final Color currentTimelineColor = Color.fromRGBO(14, 34, 119, 1);
    final Color currentTimeColor = Color.fromRGBO(24, 57, 198, 1);

    return Scaffold(
      backgroundColor: const Color.fromRGBO(239, 243, 250, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(239, 243, 250, 1),
        toolbarHeight: 70, // Increase toolbar height to make AppBar thicker
        elevation: 0,
        leadingWidth: 40, // Reduce leading width to bring title closer to back button
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        titleSpacing: 0, // Reduce spacing to move title right next to back button
        title: const Text(
          'Mess Menu 👩‍🍳',
          style: TextStyle(
            color: Color.fromRGBO(19, 46, 158, 1),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        // centerTitle: true, // Removed to align title to the left
        actions: [
          TextButton(
            onPressed: _showReportIssueDialog,
            child: const Text(
              'Report mess issue',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80), // Reduced height of tab bar
          child: Column(
            children: [
              Container(height: 1, color: Colors.grey),
              Padding(
                padding: const EdgeInsets.only(bottom: 8), // Reduced bottom padding
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
                padding: const EdgeInsets.only(bottom: 2, left: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FilterChip(
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
                        labelPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: -2),
                        padding: const EdgeInsets.all(4),
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
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
                        labelPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: -2),
                        padding: const EdgeInsets.all(4),
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
        children: List.generate(7, (index) => buildDayMenu(index, currentMeal, currentTimelineColor, currentTimeColor)),
      ),
    );
  }

  Widget buildDayMenu(int dayIndex, String currentMeal, Color currentTimelineColor, Color currentTimeColor) {
    List<Meal> filteredMeals =
        meals.where((meal) => meal.day == dayIndex).toList();

    List<Widget> mealWidgets = [];

    for (int i = 0; i < filteredMeals.length; i++) {
      var meal = filteredMeals[i];
      bool isCurrentMeal = meal.type == currentMeal;
      bool isLastMeal = i == filteredMeals.length - 1;
      
      // Create a unique key for this meal card
      String keyId = '${dayIndex}_${meal.type}';
      _mealCardKeys[keyId] = _mealCardKeys[keyId] ?? GlobalKey();

      // Select icon based on meal type
      IconData mealIcon;
      switch (meal.type) {
        case 'Breakfast':
          mealIcon = Icons.brightness_5;
          break;
        case 'Lunch':
          mealIcon = Icons.wb_sunny;
          break;
        case 'Snacks':
          mealIcon = Icons.brightness_4;
          break;
        case 'Dinner':
          mealIcon = Icons.nightlight_round;
          break;
        default:
          mealIcon = Icons.wb_sunny;
      }

      mealWidgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0), // Reduced horizontal padding
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline widget with dynamic height
              !isLastMeal 
                ? DynamicTimelineWidget(
                    mealCardKey: _mealCardKeys[keyId]!,
                    mealIcon: mealIcon,
                    isCurrentMeal: isCurrentMeal,
                    currentTimelineColor: currentTimelineColor,
                  )
                : SizedBox(
                    width: 24,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Icon(
                        mealIcon,
                        color: isCurrentMeal ? currentTimelineColor : Colors.grey,
                        size: 21,
                      ),
                    ),
                  ),
              const SizedBox(width: 8), // Slightly reduced space
              // Meal content - aligned all the way left
              Expanded(
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
                        color: isCurrentMeal ? currentTimeColor : Colors.grey,
                      ),
                    ),
                    Transform.translate(
                      offset: Offset(-16, 0), // Negative offset to remove implicit padding
                      child: MealCard(
                        key: _mealCardKeys[keyId],
                        meal: meal,
                        showVeg: showVeg,
                        showNonVeg: showNonVeg,
                        isCurrentMeal: isCurrentMeal,
                        currentMealBorderColor: const Color.fromRGBO(70, 97, 209, 1),
                      ),
                    ),
                  ],
                ),
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

// New widget for dynamic timeline
class DynamicTimelineWidget extends StatefulWidget {
  final GlobalKey mealCardKey;
  final IconData mealIcon;
  final bool isCurrentMeal;
  final Color currentTimelineColor;

  const DynamicTimelineWidget({
    super.key,
    required this.mealCardKey,
    required this.mealIcon,
    required this.isCurrentMeal,
    required this.currentTimelineColor,
  });

  @override
  State<DynamicTimelineWidget> createState() => _DynamicTimelineWidgetState();
}

class _DynamicTimelineWidgetState extends State<DynamicTimelineWidget> {
  double _lineHeight = 120; // Default height
  
  @override
  void initState() {
    super.initState();
    // Wait for the layout to complete then measure the card
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateLineHeight();
    });
  }

  void _updateLineHeight() {
    final RenderBox? renderBox = widget.mealCardKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      setState(() {
        // Set line height to card height plus extra margin
        _lineHeight = renderBox.size.height + 15;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Icon(
              widget.mealIcon,
              color: widget.isCurrentMeal ? widget.currentTimelineColor : Colors.grey,
              size: 21,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: 1.5,
            height: _lineHeight,
            color: widget.isCurrentMeal ? widget.currentTimelineColor : Colors.grey[300],
          ),
        ],
      ),
    );
  }
}
