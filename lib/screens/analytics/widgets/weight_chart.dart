import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../models/daily_record.dart';

class WeightChart extends StatelessWidget {
  final List<DailyRecord> records;

  const WeightChart({
    super.key,
    required this.records,
  });

  @override
  Widget build(BuildContext context) {
    final List<FlSpot> spots = [];
    for (int i = 0; i < records.length; i++) {
      if (records[i].weight > 0) {
        spots.add(FlSpot(i.toDouble(), records[i].weight));
      }
    }

    if (spots.isEmpty) return const Center(child: Text('No weight data'));

    final double dataMin = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    final double dataMax = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final double minY = (dataMin / 5).floor() * 5.0;
    final double maxY = (dataMax / 5).ceil() * 5.0 + 5.0;
    final double range = maxY - minY;

    double interval;
    if (range <= 20) {
      interval = 5;
    } else if (range <= 50) {
      interval = 10;
    } else {
      interval = 20;
    }

    return LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: interval,
          getDrawingHorizontalLine: (_) => const FlLine(
            color: Colors.white12,
            strokeWidth: 1,
            dashArray: [4, 4],
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: interval,
              getTitlesWidget: (value, meta) {
                if (value == minY && value % interval != 0) return const SizedBox.shrink();
                if (value == maxY && value % interval != 0) return const SizedBox.shrink();
                
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
                final idx = value.toInt();
                if (idx < 0 || idx >= records.length) return const SizedBox.shrink();
                final step = records.length <= 7 ? 1 : (records.length / 5).ceil();
                if (idx % step != 0) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    DateFormat('MM/dd').format(records[idx].date),
                    style: const TextStyle(fontSize: 10, color: Colors.white54),
                  ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.tealAccent,
            barWidth: 3,
            dotData: FlDotData(
              show: spots.length <= 14,
              getDotPainter: (spot, xPercentage, bar, index) => FlDotCirclePainter(
                radius: 3,
                color: Colors.tealAccent,
                strokeWidth: 0,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.tealAccent.withValues(alpha: 0.15),
            ),
          ),
        ],
      ),
    );
  }
}
