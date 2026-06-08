import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../models/daily_record.dart';

class ProteinChart extends StatelessWidget {
  final List<DailyRecord> records;

  const ProteinChart({
    super.key,
    required this.records,
  });

  @override
  Widget build(BuildContext context) {
    List<BarChartGroupData> barGroups = [];
    double maxProtein = 0;
    for (int i = 0; i < records.length; i++) {
      if (records[i].protein > maxProtein) maxProtein = records[i].protein;
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: records[i].protein,
              color: records[i].protein >= 90 ? Colors.green : Colors.orange,
              width: records.length > 10 ? 8 : 16,
              borderRadius: BorderRadius.circular(4),
            )
          ],
        )
      );
    }

    final double maxY = (maxProtein / 20).ceil() * 20.0 + 10.0;

    return BarChart(
      BarChartData(
        maxY: maxY == 10.0 ? 20.0 : maxY,
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                if (value == meta.max && value % meta.appliedInterval != 0) {
                  return const SizedBox.shrink();
                }
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 11, color: Colors.white54),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < records.length) {
                  if (records.length > 10 && value.toInt() % (records.length ~/ 5) != 0) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(DateFormat('MM/dd').format(records[value.toInt()].date), style: const TextStyle(fontSize: 10, color: Colors.white54)),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: barGroups,
      ),
    );
  }
}
