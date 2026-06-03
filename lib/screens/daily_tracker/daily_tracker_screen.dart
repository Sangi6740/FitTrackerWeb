import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/storage_service.dart';
import '../../providers/daily_tracker_provider.dart';
import '../../widgets/glass_container.dart';

// ─── Nav bar metrics (must match main_layout.dart) ──────────────────────────
// nav bar height 65px + bottom offset 24px + safe area ≈ 100px clearance.
const double _kNavBarClearance = 100.0;

class DailyTrackerScreen extends StatelessWidget {
  const DailyTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Tracker')),
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
              _buildScoreCard(record.completionPercentage),
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
              _buildSliderSection(
                title: 'Protein Intake (g)',
                value: record.protein,
                max: 200,
                divisions: 200,
                onChanged: (val) => provider.updateProtein(val),
                icon: Icons.fitness_center,
                color: Colors.orange,
              ),
              const Divider(height: 32),
              _buildSliderSection(
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

  Widget _buildScoreCard(double score) {
    return GlassContainer(
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      child: Row(
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
                  value: score / 100,
                  backgroundColor: Colors.white24,
                  color: score >= 80
                      ? Colors.tealAccent
                      : (score >= 50 ? Colors.amber : Colors.red),
                  strokeWidth: 8,
                ),
              ),
              Text(
                '${score.toInt()}%',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Slider section ─────────────────────────────────────────────────────────

  Widget _buildSliderSection({
    required String title,
    required double value,
    required double max,
    required int divisions,
    required Function(double) onChanged,
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
              value.toStringAsFixed(1),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Slider(
          value: value,
          max: max,
          divisions: divisions,
          activeColor: color,
          onChanged: onChanged,
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
              foodText: record.preWorkoutFood,
              onSelected: (v) => provider.updateMeal('preWorkout', v),
              onFoodChanged: (v) => provider.updateMealFood('preWorkout', v),
            ),
            _MealRow(
              label: 'Post-Workout',
              isSelected: record.postWorkoutDone,
              foodText: record.postWorkoutFood,
              onSelected: (v) => provider.updateMeal('postWorkout', v),
              onFoodChanged: (v) => provider.updateMealFood('postWorkout', v),
            ),
            _MealRow(
              label: 'Breakfast',
              isSelected: record.breakfastDone,
              foodText: record.breakfastFood,
              onSelected: (v) => provider.updateMeal('breakfast', v),
              onFoodChanged: (v) => provider.updateMealFood('breakfast', v),
            ),
            _MealRow(
              label: 'Lunch',
              isSelected: record.lunchDone,
              foodText: record.lunchFood,
              onSelected: (v) => provider.updateMeal('lunch', v),
              onFoodChanged: (v) => provider.updateMealFood('lunch', v),
            ),
            _MealRow(
              label: 'Snack',
              isSelected: record.snackDone,
              foodText: record.snackFood,
              onSelected: (v) => provider.updateMeal('snack', v),
              onFoodChanged: (v) => provider.updateMealFood('snack', v),
            ),
            _MealRow(
              label: 'Dinner',
              isSelected: record.dinnerDone,
              foodText: record.dinnerFood,
              onSelected: (v) => provider.updateMeal('dinner', v),
              onFoodChanged: (v) => provider.updateMealFood('dinner', v),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── _MealRow ────────────────────────────────────────────────────────────────
// A StatefulWidget so it can manage the custom-food TextField controller
// independently without needing to bubble state up to the provider on every
// keystroke, while still committing changes via the callbacks.

class _MealRow extends StatefulWidget {
  final String label;
  final bool isSelected;
  final String foodText;
  final ValueChanged<bool> onSelected;
  final ValueChanged<String> onFoodChanged;

  const _MealRow({
    required this.label,
    required this.isSelected,
    required this.foodText,
    required this.onSelected,
    required this.onFoodChanged,
  });

  @override
  State<_MealRow> createState() => _MealRowState();
}

class _MealRowState extends State<_MealRow> {
  static const List<String> _presets = [
    'Protein Shake',
    'Oats',
    'Boiled Eggs',
    'Salad with Protein',
    'Banana',
  ];

  late TextEditingController _customController;
  bool _isEditingCustom = false;
  bool _initialized = false;

  bool _checkIfCustom(String text) {
    if (text.isEmpty || text == 'Custom...') return true;
    if (_presets.contains(text)) return false;

    try {
      final storage = context.read<StorageService>();
      final customFoods = storage.getCustomFoods(_presets);
      if (customFoods.contains(text)) return false;
    } catch (_) {}
    return true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _isEditingCustom = _checkIfCustom(widget.foodText);
      _customController = TextEditingController(
        text: _isEditingCustom ? widget.foodText : '',
      );
      _initialized = true;
    }
  }

  @override
  void didUpdateWidget(_MealRow old) {
    super.didUpdateWidget(old);
    // Sync controller only when the external value changes to something that
    // isn't already reflected (avoid overwriting mid-edit).
    if (old.foodText != widget.foodText &&
        _isEditingCustom &&
        _customController.text != widget.foodText) {
      _customController.text = widget.foodText;
      _customController.selection = TextSelection.collapsed(
        offset: widget.foodText.length,
      );
    }
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  // ── Food picker bottom sheet ────────────────────────────────────────────────
  // Uses showModalBottomSheet which is a full overlay route — it always renders
  // above every in-page widget including the custom floating nav bar, completely
  // eliminating any z-order conflict on web, Android, and iOS.
  void _openFoodPicker() {
    final storage = context.read<StorageService>();
    final customFoods = storage.getCustomFoods(_presets);

    final currentValue = _isEditingCustom
        ? 'Custom...'
        : (widget.foodText.isEmpty ? _presets.first : widget.foodText);

    showModalBottomSheet<void>(
      context: context,
      // isScrollControlled lets the sheet grow up to 60% of screen height.
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      // useRootNavigator pushes the route onto the root navigator so it sits
      // above the MainLayout Stack — guaranteed to clear the floating nav bar.
      useRootNavigator: true,
      builder: (sheetCtx) {
        return _FoodPickerSheet(
          presets: _presets,
          customFoods: customFoods,
          selected: currentValue,
          onPicked: (choice) {
            Navigator.of(sheetCtx).pop();
            if (choice == 'Custom...') {
              widget.onFoodChanged('');
              setState(() {
                _isEditingCustom = true;
                _customController.text = '';
              });
            } else {
              widget.onFoodChanged(choice);
              setState(() {
                _isEditingCustom = false;
              });
              if (!widget.isSelected) {
                Future.delayed(const Duration(milliseconds: 100), () {
                  widget.onSelected(true);
                });
              }
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayLabel = _isEditingCustom
        ? (widget.foodText.isEmpty ? 'Tap to choose…' : widget.foodText)
        : widget.foodText.isEmpty
        ? _presets.first
        : widget.foodText;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: GlassContainer(
        borderRadius: 16,
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Completion checkbox ────────────────────────────────────────
            Checkbox(
              value: widget.isSelected,
              onChanged: (val) => widget.onSelected(val ?? false),
              activeColor: Colors.tealAccent,
              checkColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),

            // ── Food selector + optional custom text field ─────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tappable row that opens the modal bottom sheet picker.
                  InkWell(
                    onTap: _openFoodPicker,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.label,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  displayLabel,
                                  style: TextStyle(
                                    color:
                                        _isEditingCustom &&
                                            widget.foodText.isEmpty
                                        ? Colors.white38
                                        : Colors.white,
                                    fontSize: 15,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.tealAccent,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Custom food text field — visible only when "Custom..." is active.
                  if (_isEditingCustom) ...[
                    const SizedBox(height: 8),
                    TextField(
                      controller: _customController,
                      onChanged: (val) {
                        widget.onFoodChanged(val);
                        if (val.isNotEmpty && !widget.isSelected) {
                          Future.delayed(
                            const Duration(milliseconds: 100),
                            () => widget.onSelected(true),
                          );
                        }
                        if (val.isEmpty && widget.isSelected) {
                          Future.delayed(
                            const Duration(milliseconds: 100),
                            () => widget.onSelected(false),
                          );
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'Type custom food…',
                        hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.black26,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      style: const TextStyle(color: Colors.tealAccent),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── _FoodPickerSheet ────────────────────────────────────────────────────────
// The modal content rendered inside showModalBottomSheet. Extracted into its
// own widget so it can manage its own scroll controller cleanly.

class _FoodPickerSheet extends StatelessWidget {
  final List<String> presets;
  final List<String> customFoods;
  final String selected;
  final ValueChanged<String> onPicked;

  const _FoodPickerSheet({
    required this.presets,
    required this.customFoods,
    required this.selected,
    required this.onPicked,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      // SafeArea handles both device notches and the system bottom bar.
      // Because useRootNavigator: true was set, this correctly accounts for
      // the real safe area rather than the nav-bar-adjusted one.
      child: Container(
        constraints: BoxConstraints(
          // Cap at 60% of the screen height so there is always visible
          // context behind the sheet.
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A2E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Drag handle ────────────────────────────────────────────────
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),

            // ── Title ──────────────────────────────────────────────────────
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Choose Food',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.tealAccent,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Divider(color: Colors.white12, height: 1),

            // ── Scrollable options list ────────────────────────────────────
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                children: [
                  _buildSectionHeader('DEFAULT PRESETS'),
                  ...presets.map((option) => _buildOptionRow(option)),

                  if (customFoods.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Divider(color: Colors.white12, height: 24),
                    ),
                    _buildSectionHeader('YOUR CUSTOM FOODS'),
                    ...customFoods.map((option) => _buildOptionRow(option)),
                  ],

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Divider(color: Colors.white12, height: 24),
                  ),
                  _buildOptionRow('Custom...'),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 8, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildOptionRow(String option) {
    final isSelected = option == selected;
    final isCustom = option == 'Custom...';

    return InkWell(
      onTap: () => onPicked(option),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        color: isSelected
            ? Colors.tealAccent.withValues(alpha: 0.12)
            : Colors.transparent,
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? Colors.tealAccent : Colors.transparent,
                border: Border.all(
                  color: isSelected ? Colors.tealAccent : Colors.white24,
                  width: 1.5,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  color: isCustom
                      ? Colors.tealAccent
                      : isSelected
                      ? Colors.white
                      : Colors.white70,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 15,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check, color: Colors.tealAccent, size: 18),
          ],
        ),
      ),
    );
  }
}
