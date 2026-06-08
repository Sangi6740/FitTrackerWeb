import 'package:flutter/material.dart';
import '../../../widgets/glass_container.dart';
import '../../../models/daily_record.dart';
import 'food_search_sheet.dart';

class MealRow extends StatelessWidget {
  final String label;
  final bool isSelected;
  final List<MealEntry> entries;
  final ValueChanged<bool> onSelected;
  final ValueChanged<MealEntry> onAddFood;
  final ValueChanged<int> onRemoveFood;

  const MealRow({
    super.key,
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
        return FoodSearchSheet(
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
