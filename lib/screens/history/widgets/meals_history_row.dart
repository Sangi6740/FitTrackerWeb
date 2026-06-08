import 'package:flutter/material.dart';
import '../../../models/daily_record.dart';
import 'detail_row.dart';

class MealsHistoryRow extends StatelessWidget {
  final DailyRecord record;

  const MealsHistoryRow({
    super.key,
    required this.record,
  });

  @override
  Widget build(BuildContext context) {
    int mealsDone = 0;
    List<Widget> foodRows = [];

    void addFoodRow(String title, bool done, List<MealEntry> entries) {
      if (done) {
        mealsDone++;
        if (entries.isNotEmpty) {
          foodRows.add(Padding(
            padding: const EdgeInsets.only(top: 8, left: 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$title:', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
                ...entries.map((e) => Text('• ${e.name} (${e.quantity.toInt()}${e.unit})', style: const TextStyle(color: Colors.white))),
              ],
            ),
          ));
        }
      }
    }

    addFoodRow('Pre-Workout', record.preWorkoutDone, record.preWorkoutEntries);
    addFoodRow('Post-Workout', record.postWorkoutDone, record.postWorkoutEntries);
    addFoodRow('Breakfast', record.breakfastDone, record.breakfastEntries);
    addFoodRow('Lunch', record.lunchDone, record.lunchEntries);
    addFoodRow('Snack', record.snackDone, record.snackEntries);
    addFoodRow('Dinner', record.dinnerDone, record.dinnerEntries);

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
