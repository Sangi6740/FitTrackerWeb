import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/analytics_provider.dart';
import 'widgets/average_card.dart';
import 'widgets/weight_chart.dart';
import 'widgets/protein_chart.dart';

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
          child: WeightChart(records: records),
        ),
        const SizedBox(height: 32),
        const Text('Protein Trend (g)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        SizedBox(
          height: 250,
          child: ProteinChart(records: records),
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
        AverageCard(title: 'Protein', value: '${protein.toInt()}g', icon: Icons.fitness_center),
        AverageCard(title: 'Water', value: '${water.toStringAsFixed(1)}L', icon: Icons.water_drop),
        AverageCard(title: 'Sleep', value: '${sleep.toStringAsFixed(1)}h', icon: Icons.bedtime),
        AverageCard(title: 'Workouts', value: '$workouts/$totalDays', icon: Icons.sports_gymnastics),
        AverageCard(title: 'Max Streak', value: '$maxStreak Days', icon: Icons.local_fire_department),
        AverageCard(title: 'Avg Score', value: '$avgScore%', icon: Icons.score),
      ],
    );
  }
}
