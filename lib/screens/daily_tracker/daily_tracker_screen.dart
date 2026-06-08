import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/daily_tracker_provider.dart';
import 'widgets/score_card.dart';
import 'widgets/read_only_slider_section.dart';
import 'widgets/slider_section.dart';
import 'widgets/meal_row.dart';

// ─── Nav bar metrics (must match main_layout.dart) ──────────────────────────
// nav bar height 65px + bottom offset 24px + safe area ≈ 100px clearance.
const double _kNavBarClearance = 100.0;

class DailyTrackerScreen extends StatelessWidget {
  const DailyTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.orangeAccent),
            tooltip: 'Clear Day',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: const Color(0xFF1A1A2E),
                  title: const Text('Reset Today?'),
                  content: const Text('This will clear all meals, water, sleep, and workouts entered for this specific day. Cannot be undone.', style: TextStyle(color: Colors.white70)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<DailyTrackerProvider>().resetCurrentDay();
                        Navigator.pop(ctx);
                      },
                      child: const Text('Reset', style: TextStyle(color: Colors.orangeAccent)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<DailyTrackerProvider>(
        builder: (context, provider, child) {
          final record = provider.currentRecord;
          if (record == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            // Extra bottom clearance so the last meal row is never hidden by
            // the floating nav bar, even without any dropdowns open.
            padding: const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              _kNavBarClearance + 20,
            ),
            children: [
              _buildDateSelector(context, provider),
              const SizedBox(height: 20),
              ScoreCard(record: record),
              const SizedBox(height: 20),
              SwitchListTile(
                title: const Text(
                  'Gym Workout Completed',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Did you hit the gym today?'),
                value: record.gymDone,
                onChanged: (val) => provider.updateGymDone(val),
                secondary: const Icon(
                  Icons.sports_gymnastics,
                  size: 32,
                  color: Colors.tealAccent,
                ),
                activeTrackColor: Colors.tealAccent.withValues(alpha: 0.5),
                activeThumbColor: Colors.tealAccent,
              ),
              const Divider(height: 32),
              ReadOnlySliderSection(
                title: 'Protein Intake (g) (Auto-calculated)',
                value: record.protein,
                goal: 200.0,
                icon: Icons.fitness_center,
                color: Colors.orange,
              ),
              const Divider(height: 32),
              SliderSection(
                title: 'Water Intake (L)',
                value: record.water,
                maxVal: 6,
                divisions: 60,
                onChanged: (val) => provider.updateWater(val),
                icon: Icons.water_drop,
                color: Colors.blue,
              ),
              const Divider(height: 32),
              SliderSection(
                title: 'Sleep (hrs)',
                value: record.sleep,
                maxVal: 12,
                divisions: 24,
                onChanged: (val) => provider.updateSleep(val),
                icon: Icons.bedtime,
                color: Colors.deepPurple,
              ),
              const Divider(height: 32),
              SliderSection(
                title: 'Weight (kg)',
                value: record.weight,
                maxVal: 150,
                divisions: 1500,
                onChanged: (val) => provider.updateWeight(val),
                icon: Icons.monitor_weight,
                color: Colors.teal,
              ),
              const Divider(height: 32),
              _buildMealsSection(record, provider),
            ],
          );
        },
      ),
    );
  }

  // ─── Date selector ──────────────────────────────────────────────────────────

  Widget _buildDateSelector(
    BuildContext context,
    DailyTrackerProvider provider,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => provider.setDate(
            provider.selectedDate.subtract(const Duration(days: 1)),
          ),
        ),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: provider.selectedDate,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              provider.setDate(picked);
            }
          },
          child: Text(
            DateFormat('EEEE, MMM d').format(provider.selectedDate),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed:
              provider.selectedDate.isBefore(
                DateTime(
                  DateTime.now().year,
                  DateTime.now().month,
                  DateTime.now().day,
                ),
              )
              ? () => provider.setDate(
                  provider.selectedDate.add(const Duration(days: 1)),
                )
              : null,
        ),
      ],
    );
  }

  // ─── Meals section ──────────────────────────────────────────────────────────

  Widget _buildMealsSection(dynamic record, DailyTrackerProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.restaurant, color: Colors.orangeAccent),
            SizedBox(width: 8),
            Text(
              'Meals Logged',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          children: [
            MealRow(
              label: 'Pre-Workout',
              isSelected: record.preWorkoutDone,
              entries: record.preWorkoutEntries,
              onSelected: (v) => provider.updateMeal('preWorkout', v),
              onAddFood: (v) => provider.addFoodToMeal('preWorkout', v),
              onRemoveFood: (index) => provider.removeFoodFromMeal('preWorkout', index),
            ),
            MealRow(
              label: 'Post-Workout',
              isSelected: record.postWorkoutDone,
              entries: record.postWorkoutEntries,
              onSelected: (v) => provider.updateMeal('postWorkout', v),
              onAddFood: (v) => provider.addFoodToMeal('postWorkout', v),
              onRemoveFood: (index) => provider.removeFoodFromMeal('postWorkout', index),
            ),
            MealRow(
              label: 'Breakfast',
              isSelected: record.breakfastDone,
              entries: record.breakfastEntries,
              onSelected: (v) => provider.updateMeal('breakfast', v),
              onAddFood: (v) => provider.addFoodToMeal('breakfast', v),
              onRemoveFood: (index) => provider.removeFoodFromMeal('breakfast', index),
            ),
            MealRow(
              label: 'Lunch',
              isSelected: record.lunchDone,
              entries: record.lunchEntries,
              onSelected: (v) => provider.updateMeal('lunch', v),
              onAddFood: (v) => provider.addFoodToMeal('lunch', v),
              onRemoveFood: (index) => provider.removeFoodFromMeal('lunch', index),
            ),
            MealRow(
              label: 'Snack',
              isSelected: record.snackDone,
              entries: record.snackEntries,
              onSelected: (v) => provider.updateMeal('snack', v),
              onAddFood: (v) => provider.addFoodToMeal('snack', v),
              onRemoveFood: (index) => provider.removeFoodFromMeal('snack', index),
            ),
            MealRow(
              label: 'Dinner',
              isSelected: record.dinnerDone,
              entries: record.dinnerEntries,
              onSelected: (v) => provider.updateMeal('dinner', v),
              onAddFood: (v) => provider.addFoodToMeal('dinner', v),
              onRemoveFood: (index) => provider.removeFoodFromMeal('dinner', index),
            ),
          ],
        ),
      ],
    );
  }
}
