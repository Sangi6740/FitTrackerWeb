import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/storage_service.dart';
import '../../providers/daily_tracker_provider.dart';
import '../../widgets/glass_container.dart';
import '../../models/daily_record.dart';
import '../../models/food_item.dart';

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
              _buildScoreCard(record),
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
              _buildReadOnlySliderSection(
                title: 'Protein Intake (g) (Auto-calculated)',
                value: record.protein,
                goal: 200.0,
                icon: Icons.fitness_center,
                color: Colors.orange,
              ),
              const Divider(height: 32),
              _buildSliderSection(
                context: context,
                title: 'Water Intake (L)',
                value: record.water,
                max: 6,
                divisions: 60,
                onChanged: (val) => provider.updateWater(val),
                icon: Icons.water_drop,
                color: Colors.blue,
              ),
              const Divider(height: 32),
              _buildSliderSection(
                context: context,
                title: 'Sleep (hrs)',
                value: record.sleep,
                max: 12,
                divisions: 24,
                onChanged: (val) => provider.updateSleep(val),
                icon: Icons.bedtime,
                color: Colors.deepPurple,
              ),
              const Divider(height: 32),
              _buildSliderSection(
                context: context,
                title: 'Weight (kg)',
                value: record.weight,
                max: 150,
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

  // ─── Score card ─────────────────────────────────────────────────────────────

  Widget _buildScoreCard(DailyRecord record) {
    return GlassContainer(
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Daily Score',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 60,
                    width: 60,
                    child: CircularProgressIndicator(
                      value: record.completionPercentage / 100,
                      backgroundColor: Colors.white24,
                      color: record.completionPercentage >= 80
                          ? Colors.tealAccent
                          : (record.completionPercentage >= 50 ? Colors.amber : Colors.red),
                      strokeWidth: 8,
                    ),
                  ),
                  Text(
                    '${record.completionPercentage.toInt()}%',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 32, color: Colors.white24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMacroInfo('Calories', '${record.totalCalories.toInt()} kcal', Colors.orange),
              _buildMacroInfo('Carbs', '${record.totalCarbs.toInt()}g', Colors.blueAccent),
              _buildMacroInfo('Fats', '${record.totalFats.toInt()}g', Colors.redAccent),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMacroInfo(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
      ],
    );
  }

  Widget _buildReadOnlySliderSection({
    required String title,
    required double value,
    required double goal,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Text(
              '${value.toStringAsFixed(1)} / ${goal.toInt()}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: (value / goal).clamp(0.0, 1.0),
            minHeight: 12,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  // ─── Slider section ─────────────────────────────────────────────────────────

  void _showNumericInputDialog(BuildContext context, String title, double currentValue, Function(double) onChanged) {
    final ctrl = TextEditingController(text: currentValue.toStringAsFixed(1));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text('Set $title'),
        content: TextField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Value',
            labelStyle: const TextStyle(color: Colors.white70),
            filled: true,
            fillColor: Colors.black26,
          ),
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              final val = double.tryParse(ctrl.text) ?? currentValue;
              onChanged(val);
              Navigator.pop(ctx);
            },
            child: const Text('Save', style: TextStyle(color: Colors.tealAccent)),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderSection({
    required BuildContext context,
    required String title,
    required double value,
    required double max,
    required int divisions,
    required Function(double) onChanged,
    required IconData icon,
    required Color color,
  }) {
    final step = max / divisions;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            InkWell(
              onTap: () => _showNumericInputDialog(context, title, value, onChanged),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  value.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.tealAccent),
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove, color: Colors.white54),
              onPressed: () {
                final newVal = (value - step).clamp(0.0, max);
                onChanged(newVal);
              },
            ),
            Expanded(
              child: Slider(
                value: value.clamp(0.0, max),
                max: max,
                divisions: divisions,
                activeColor: color,
                onChanged: onChanged,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add, color: Colors.white54),
              onPressed: () {
                final newVal = (value + step).clamp(0.0, max);
                onChanged(newVal);
              },
            ),
          ],
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
                        _MealRow(
              label: 'Pre-Workout',
              isSelected: record.preWorkoutDone,
              entries: record.preWorkoutEntries,
              onSelected: (v) => provider.updateMeal('preWorkout', v),
              onAddFood: (v) => provider.addFoodToMeal('preWorkout', v),
              onRemoveFood: (index) => provider.removeFoodFromMeal('preWorkout', index),
            ),
            _MealRow(
              label: 'Post-Workout',
              isSelected: record.postWorkoutDone,
              entries: record.postWorkoutEntries,
              onSelected: (v) => provider.updateMeal('postWorkout', v),
              onAddFood: (v) => provider.addFoodToMeal('postWorkout', v),
              onRemoveFood: (index) => provider.removeFoodFromMeal('postWorkout', index),
            ),
            _MealRow(
              label: 'Breakfast',
              isSelected: record.breakfastDone,
              entries: record.breakfastEntries,
              onSelected: (v) => provider.updateMeal('breakfast', v),
              onAddFood: (v) => provider.addFoodToMeal('breakfast', v),
              onRemoveFood: (index) => provider.removeFoodFromMeal('breakfast', index),
            ),
            _MealRow(
              label: 'Lunch',
              isSelected: record.lunchDone,
              entries: record.lunchEntries,
              onSelected: (v) => provider.updateMeal('lunch', v),
              onAddFood: (v) => provider.addFoodToMeal('lunch', v),
              onRemoveFood: (index) => provider.removeFoodFromMeal('lunch', index),
            ),
            _MealRow(
              label: 'Snack',
              isSelected: record.snackDone,
              entries: record.snackEntries,
              onSelected: (v) => provider.updateMeal('snack', v),
              onAddFood: (v) => provider.addFoodToMeal('snack', v),
              onRemoveFood: (index) => provider.removeFoodFromMeal('snack', index),
            ),
            _MealRow(
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

// ─── _MealRow ────────────────────────────────────────────────────────────────

class _MealRow extends StatelessWidget {
  final String label;
  final bool isSelected;
  final List<MealEntry> entries;
  final ValueChanged<bool> onSelected;
  final ValueChanged<MealEntry> onAddFood;
  final ValueChanged<int> onRemoveFood;

  const _MealRow({
    required this.label,
    required this.isSelected,
    required this.entries,
    required this.onSelected,
    required this.onAddFood,
    required this.onRemoveFood,
  });

  void _openFoodSearch(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      builder: (sheetCtx) {
        return _FoodSearchSheet(
          onPicked: (MealEntry pickedEntry) {
            Navigator.of(sheetCtx).pop();
            onAddFood(pickedEntry);
            if (!isSelected) {
              Future.delayed(const Duration(milliseconds: 100), () {
                onSelected(true);
              });
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: GlassContainer(
        borderRadius: 16,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: isSelected,
                  onChanged: (val) {
                    if (entries.isEmpty && val == true) {
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please add a food item first!'),
                          duration: Duration(seconds: 1),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    } else {
                      onSelected(val ?? false);
                    }
                  },
                  activeColor: Colors.tealAccent,
                  checkColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.tealAccent),
                  onPressed: () => _openFoodSearch(context),
                ),
              ],
            ),
            if (entries.isNotEmpty) const Divider(color: Colors.white12),
            ...entries.asMap().entries.map((e) {
              final index = e.key;
              final entry = e.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(entry.name, style: const TextStyle(color: Colors.white, fontSize: 15)),
                          const SizedBox(height: 2),
                          Text(
                            '${entry.quantity % 1 == 0 ? entry.quantity.toInt() : entry.quantity.toStringAsFixed(1)} ${entry.unit} • ${entry.calories.toInt()} kcal',
                            style: const TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${entry.protein.toInt()}g P',
                      style: const TextStyle(color: Colors.tealAccent, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54, size: 20),
                      onPressed: () => onRemoveFood(index),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ─── _FoodSearchSheet ────────────────────────────────────────────────────────

class _FoodSearchSheet extends StatefulWidget {
  final ValueChanged<MealEntry> onPicked;

  const _FoodSearchSheet({required this.onPicked});

  @override
  State<_FoodSearchSheet> createState() => _FoodSearchSheetState();
}

class _FoodSearchSheetState extends State<_FoodSearchSheet> {
  List<FoodItem> _foods = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFoods();
  }

  void _loadFoods() async {
    final storage = context.read<StorageService>();
    final foods = await storage.getAllFoods();
    setState(() {
      _foods = foods;
      _isLoading = false;
    });
  }

  void _showQuantityDialog(FoodItem food) {
    final qtyController = TextEditingController(text: '1');
    String? errorText;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1A1A2E),
            title: Text('Amount of ${food.name}'),
            content: TextField(
              controller: qtyController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Quantity (${food.unit})',
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.black26,
                errorText: errorText,
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: (val) {
                if (errorText != null) {
                  setState(() => errorText = null);
                }
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
              ),
              TextButton(
                onPressed: () {
                  final qty = double.tryParse(qtyController.text) ?? 1.0;
                  if (qty <= 0) {
                    setState(() {
                      errorText = 'Must be greater than 0';
                    });
                    return;
                  }
                  final entry = MealEntry(
                    name: food.name,
                    quantity: qty,
                    unit: food.unit,
                    calories: food.calories * qty,
                    protein: food.protein * qty,
                    carbs: food.carbs * qty,
                    fats: food.fats * qty,
                  );
                  Navigator.pop(ctx);
                  widget.onPicked(entry);
                },
                child: const Text('Add', style: TextStyle(color: Colors.tealAccent)),
              ),
            ],
          );
        }
      ),
    );
  }

  void _showCreateFoodDialog() {
    final nameCtrl = TextEditingController();
    final unitCtrl = TextEditingController();
    final calCtrl = TextEditingController();
    final proCtrl = TextEditingController();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Create Custom Food'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Food Name', labelStyle: TextStyle(color: Colors.white70)), style: const TextStyle(color: Colors.white)),
              TextField(controller: unitCtrl, decoration: const InputDecoration(labelText: 'Serving Unit (e.g. glass, scoop)', labelStyle: TextStyle(color: Colors.white70)), style: const TextStyle(color: Colors.white)),
              TextField(controller: calCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Calories per serving', labelStyle: TextStyle(color: Colors.white70)), style: const TextStyle(color: Colors.white)),
              TextField(controller: proCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Protein per serving (g)', labelStyle: TextStyle(color: Colors.white70)), style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () async {
              final newFood = FoodItem(
                id: '',
                name: nameCtrl.text.trim(),
                calories: double.tryParse(calCtrl.text) ?? 0,
                protein: double.tryParse(proCtrl.text) ?? 0,
                carbs: 0,
                fats: 0,
                unit: unitCtrl.text.trim().isEmpty ? 'serving' : unitCtrl.text.trim(),
              );
              if (newFood.name.isNotEmpty) {
                await context.read<StorageService>().addFoodToDatabase(newFood);
                Navigator.pop(ctx);
                _showQuantityDialog(newFood);
              }
            },
            child: const Text('Save & Select', style: TextStyle(color: Colors.tealAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A2E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Select Food',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator(color: Colors.tealAccent)))
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _foods.length + 1,
                  itemBuilder: (ctx, i) {
                    if (i == _foods.length) {
                      return ListTile(
                        leading: const Icon(Icons.add, color: Colors.tealAccent),
                        title: const Text('Create Custom Food', style: TextStyle(color: Colors.tealAccent, fontWeight: FontWeight.bold)),
                        onTap: () => _showCreateFoodDialog(),
                      );
                    }
                    final food = _foods[i];
                    return ListTile(
                      title: Text(food.name, style: const TextStyle(color: Colors.white)),
                      subtitle: Text(
                        '${food.calories.toInt()} kcal • ${food.protein.toStringAsFixed(1)}g P per ${food.unit}',
                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                      onTap: () => _showQuantityDialog(food),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
