import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../providers/analytics_provider.dart';
import '../../models/daily_record.dart';
import '../../widgets/glass_container.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Weekly'),
            Tab(text: 'Monthly'),
          ],
        ),
      ),
      body: Consumer<AnalyticsProvider>(
        builder: (context, provider, child) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildAnalyticsView(provider, isWeekly: true),
              _buildAnalyticsView(provider, isWeekly: false),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAnalyticsView(AnalyticsProvider provider, {required bool isWeekly}) {
    final records = isWeekly ? provider.getCurrentWeekRecords() : provider.getCurrentMonthRecords();
    
    if (records.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    records.sort((a, b) => a.date.compareTo(b.date));

    double avgProtein = provider.getAverageProtein(records);
    double avgWater = provider.getAverageWater(records);
    double avgSleep = provider.getAverageSleep(records);
    int workouts = provider.getWorkoutConsistency(records);
    int maxStreak = provider.getLongestStreak(records);
    
    double completion = records.fold(0.0, (s, r) => s + r.completionPercentage) / records.length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        Text(isWeekly ? 'Weekly Completion' : 'Monthly Completion', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text('${completion.toInt()}%', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.tealAccent, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        
        _buildAveragesRow(avgProtein, avgWater, avgSleep, workouts, records.length, maxStreak, completion.toInt()),
        
        const SizedBox(height: 32),
        const Text('Weight Trend (kg)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        SizedBox(
          height: 250,
          child: _buildWeightChart(records),
        ),
        const SizedBox(height: 32),
        const Text('Protein Trend (g)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        SizedBox(
          height: 250,
          child: _buildProteinChart(records),
        ),
      ],
    );
  }

  Widget _buildAveragesRow(double protein, double water, double sleep, int workouts, int totalDays, int maxStreak, int avgScore) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 2,
      children: [
        _buildAverageCard('Protein', '${protein.toInt()}g', Icons.fitness_center),
        _buildAverageCard('Water', '${water.toStringAsFixed(1)}L', Icons.water_drop),
        _buildAverageCard('Sleep', '${sleep.toStringAsFixed(1)}h', Icons.bedtime),
        _buildAverageCard('Workouts', '$workouts/$totalDays', Icons.sports_gymnastics),
        _buildAverageCard('Max Streak', '$maxStreak Days', Icons.local_fire_department),
        _buildAverageCard('Avg Score', '$avgScore%', Icons.score),
      ],
    );
  }

  Widget _buildAverageCard(String title, String value, IconData icon) {
    return GlassContainer(
      padding: const EdgeInsets.all(12),
      borderRadius: 12,
      child: Row(
        children: [
          Icon(icon, color: Colors.tealAccent, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildWeightChart(List<DailyRecord> records) {
    final List<FlSpot> spots = [];
    for (int i = 0; i < records.length; i++) {
      if (records[i].weight > 0) {
        spots.add(FlSpot(i.toDouble(), records[i].weight));
      }
    }

    if (spots.isEmpty) return const Center(child: Text('No weight data'));

    // ── Y-axis range ────────────────────────────────────────────────────────
    // Floor the minimum to the nearest 5 kg and add 5 kg headroom above the
    // maximum so the line never touches the top/bottom edges.
    final double dataMin = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    final double dataMax = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final double minY = (dataMin / 5).floor() * 5.0;
    final double maxY = (dataMax / 5).ceil() * 5.0 + 5.0;
    final double range = maxY - minY;

    // Choose a label interval that gives roughly 4-6 labels regardless of range.
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
          // ── Left (Y) axis ─────────────────────────────────────────────
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: interval,
              getTitlesWidget: (value, meta) {
                // fl_chart generates values at absolute intervals (e.g. 20, 30, 40)
                // or at min/max. We only want to show labels for the grid intervals.
                if (value == minY && value % interval != 0) return const SizedBox.shrink();
                if (value == maxY && value % interval != 0) return const SizedBox.shrink();
                
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 11, color: Colors.white54),
                );
              },
            ),
          ),
          // ── Bottom (X) axis ───────────────────────────────────────────
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= records.length) return const SizedBox.shrink();
                // For ≤ 7 records show every label; otherwise show ~5 evenly.
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

  Widget _buildProteinChart(List<DailyRecord> records) {
    List<BarChartGroupData> barGroups = [];
    for (int i = 0; i < records.length; i++) {
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

    return BarChart(
      BarChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < records.length) {
                  if (records.length > 10 && value.toInt() % (records.length ~/ 5) != 0) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(DateFormat('MM/dd').format(records[value.toInt()].date), style: const TextStyle(fontSize: 10)),
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
