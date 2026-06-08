import 'package:flutter/material.dart';
import '../../../models/daily_record.dart';
import 'detail_row.dart';

class MealsHistoryRow extends StatelessWidget {
  final DailyRecord record;

  const MealsHistoryRow({
    super.key,
    required this.record,
  });

  List<Widget> _buildFoodRows(List<MealEntry> entries, String title) {
    if (entries.isEmpty) return [];
    return [
      Padding(
        padding: const EdgeInsets.only(top: 8, left: 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$title:', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
            ...entries.map((e) => Text('• ${e.name} (${e.quantity.toInt()}${e.unit})', style: const TextStyle(color: Colors.white))),
          ],
        ),
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    int mealsDone = 0;
    List<Widget> foodRows = [];

    if (record.preWorkoutDone) { mealsDone++; foodRows.addAll(_buildFoodRows(record.preWorkoutEntries, 'Pre-Workout')); }
    if (record.postWorkoutDone) { mealsDone++; foodRows.addAll(_buildFoodRows(record.postWorkoutEntries, 'Post-Workout')); }
    if (record.breakfastDone) { mealsDone++; foodRows.addAll(_buildFoodRows(record.breakfastEntries, 'Breakfast')); }
    if (record.lunchDone) { mealsDone++; foodRows.addAll(_buildFoodRows(record.lunchEntries, 'Lunch')); }
    if (record.snackDone) { mealsDone++; foodRows.addAll(_buildFoodRows(record.snackEntries, 'Snack')); }
    if (record.dinnerDone) { mealsDone++; foodRows.addAll(_buildFoodRows(record.dinnerEntries, 'Dinner')); }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DetailRow(
          icon: Icons.restaurant, 
          title: 'Meals Logged', 
          value: '$mealsDone/6', 
          color: mealsDone == 6 ? Colors.orangeAccent : Colors.white54
        ),
        if (foodRows.isNotEmpty) ...foodRows,
      ],
    );
  }
}
