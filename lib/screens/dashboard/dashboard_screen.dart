import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/daily_tracker_provider.dart';
import '../../providers/analytics_provider.dart';
import '../../widgets/glass_container.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.tealAccent),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          )
        ],
      ),
      body: Consumer2<DailyTrackerProvider, AnalyticsProvider>(
        builder: (context, trackerProvider, analyticsProvider, child) {
          final todayRecord = trackerProvider.currentRecord;
          if (todayRecord == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final currentWeek = analyticsProvider.getCurrentWeekRecords();
          final currentMonth = analyticsProvider.getCurrentMonthRecords();

          double weekCompletion = currentWeek.isEmpty
              ? 0
              : currentWeek.fold(0.0, (s, r) => s + r.completionPercentage) /
                    currentWeek.length;
          double monthCompletion = currentMonth.isEmpty
              ? 0
              : currentMonth.fold(0.0, (s, r) => s + r.completionPercentage) /
                    currentMonth.length;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              Text(
                'Today\'s Summary',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.tealAccent,
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: [
                  _buildSummaryCard(
                    'Daily %',
                    '${todayRecord.completionPercentage.toInt()}%',
                    Icons.check_circle,
                    Colors.green,
                  ),
                  _buildSummaryCard(
                    'Protein',
                    '${todayRecord.protein.toInt()}/110g',
                    Icons.fitness_center,
                    Colors.orange,
                  ),
                  _buildSummaryCard(
                    'Water',
                    '${todayRecord.water.toStringAsFixed(1)}/3L',
                    Icons.water_drop,
                    Colors.blue,
                  ),
                  _buildSummaryCard(
                    'Sleep',
                    '${todayRecord.sleep.toStringAsFixed(1)}/8h',
                    Icons.bedtime,
                    Colors.deepPurple,
                  ),
                  _buildSummaryCard(
                    'Workout',
                    todayRecord.gymDone ? 'Done' : 'Pending',
                    Icons.sports_gymnastics,
                    todayRecord.gymDone ? Colors.green : Colors.red,
                  ),
                  _buildSummaryCard(
                    'Weight',
                    '${todayRecord.weight.toStringAsFixed(1)} kg',
                    Icons.monitor_weight,
                    Colors.teal,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                'Quick Stats',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.tealAccent,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatBox(
                      'Streak',
                      '${trackerProvider.currentStreak} Days',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatBox(
                      'Week %',
                      '${weekCompletion.toInt()}%',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatBox(
                      'Month %',
                      '${monthCompletion.toInt()}%',
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return GlassContainer(
      borderRadius: 16,
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 14, color: Colors.white70),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String title, String value) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.tealAccent,
            ),
          ),
        ],
      ),
    );
  }
}
