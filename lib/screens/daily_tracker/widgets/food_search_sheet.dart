import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/daily_record.dart';
import '../../../models/food_item.dart';
import '../../../services/storage_service.dart';

class FoodSearchSheet extends StatelessWidget {
  final ValueChanged<MealEntry> onPicked;

  const FoodSearchSheet({super.key, required this.onPicked});

  void _showQuantityDialog(BuildContext context, FoodItem food) {
    final qtyController = TextEditingController(text: '1');
    final errorNotifier = ValueNotifier<String?>(null);

    showDialog(
      context: context,
      builder: (ctx) => ValueListenableBuilder<String?>(
        valueListenable: errorNotifier,
        builder: (context, errorText, child) {
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
                if (errorNotifier.value != null) {
                  errorNotifier.value = null;
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
                    errorNotifier.value = 'Must be greater than 0';
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
                  onPicked(entry);
                },
                child: const Text('Add', style: TextStyle(color: Colors.tealAccent)),
              ),
            ],
          );
        }
      ),
    );
  }

  void _showCreateFoodDialog(BuildContext context) {
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
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                _showQuantityDialog(context, newFood);
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
    final storage = context.read<StorageService>();
    return FutureBuilder<List<FoodItem>>(
      future: storage.getAllFoods(),
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final foods = snapshot.data ?? [];

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
                if (isLoading)
                  const Expanded(child: Center(child: CircularProgressIndicator(color: Colors.tealAccent)))
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: foods.length + 1,
                      itemBuilder: (ctx, i) {
                        if (i == foods.length) {
                          return ListTile(
                            leading: const Icon(Icons.add, color: Colors.tealAccent),
                            title: const Text('Create Custom Food', style: TextStyle(color: Colors.tealAccent, fontWeight: FontWeight.bold)),
                            onTap: () => _showCreateFoodDialog(context),
                          );
                        }
                        final food = foods[i];
                        return ListTile(
                          title: Text(food.name, style: const TextStyle(color: Colors.white)),
                          subtitle: Text(
                            '${food.calories.toInt()} kcal • ${food.protein.toStringAsFixed(1)}g P per ${food.unit}',
                            style: const TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                          onTap: () => _showQuantityDialog(context, food),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      }
    );
  }
}
