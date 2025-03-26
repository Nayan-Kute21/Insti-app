import 'package:flutter/material.dart';
import '../models/meal.dart';

class MealCard extends StatefulWidget {
  final Meal meal;
  final bool showVeg;
  final bool showNonVeg;
  final bool isCurrentMeal;
  final Color currentMealBorderColor;

  const MealCard({
    super.key,
    required this.meal,
    required this.showVeg,
    required this.showNonVeg,
    required this.isCurrentMeal,
    this.currentMealBorderColor = const Color.fromRGBO(70, 97, 209, 1),
  });

  @override
  // ignore: library_private_types_in_public_api
  _MealCardState createState() => _MealCardState();
}

class _MealCardState extends State<MealCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8), // Reduced horizontal margin to increase width
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: widget.isCurrentMeal
            ? BorderSide(color: widget.currentMealBorderColor, width: 1.5) // Blue outline
            : BorderSide.none,
      ),
      color: Colors.white,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Text(
                  "DAILY",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Divider(color: Colors.grey, thickness: 1),
                ),
              ],
            ),
            Text(
              widget.meal.dailyItem.isNotEmpty
                  ? widget.meal.dailyItem
                  : widget.meal.regulars,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            if ((widget.showVeg && widget.meal.vegspecials.isNotEmpty) ||
                (widget.showNonVeg &&
                    widget.meal.nonvegspecials.isNotEmpty)) ...[
              const Row(
                children: [
                  Text(
                    "SPECIALS",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Divider(color: Colors.grey, thickness: 1),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              if (widget.showVeg && widget.meal.vegspecials.isNotEmpty)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Icon(Icons.circle, size: 10, color: Colors.green),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        widget.meal.vegspecials,
                        style: const TextStyle(fontSize: 14),
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
              if (widget.showNonVeg && widget.meal.nonvegspecials.isNotEmpty)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 4), // Align with text
                      child: Icon(Icons.circle, size: 10, color: Colors.red),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        widget.meal.nonvegspecials,
                        style: const TextStyle(fontSize: 14),
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
            ],
            GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Row(
                children: [
                  const Text(
                    "REGULARS",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Divider(color: Colors.grey, thickness: 1),
                  ),
                ],
              ),
            ),
            if (_isExpanded)
              Padding(
                padding: const EdgeInsets.only(top: 0),
                child: Text(
                  widget.meal.regulars,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
