import 'package:flutter/material.dart';
import '../../../widgets/glass_container.dart';
import '../../../models/daily_record.dart';

class ScoreCard extends StatelessWidget {
  final DailyRecord record;

  const ScoreCard({
    super.key,
    required this.record,
  });

  Widget _buildMacroInfo(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
}
