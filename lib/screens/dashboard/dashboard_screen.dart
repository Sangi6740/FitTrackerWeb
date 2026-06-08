import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/daily_tracker_provider.dart';
import '../../providers/analytics_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'widgets/summary_card.dart';
import 'widgets/stat_box.dart';
import 'widgets/daily_quote_card.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});

  final ValueNotifier<int> _manualOffset = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.tealAccent),
            tooltip: 'AI Coach',
            onPressed: () {
              context.push('/test');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.tealAccent),
            tooltip: 'Logout',
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
              DailyQuoteCard(manualOffset: _manualOffset),
              const SizedBox(height: 32),
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
                  SummaryCard(
                    title: 'Daily %',
                    value: '${todayRecord.completionPercentage.toInt()}%',
                    icon: Icons.check_circle,
                    color: Colors.green,
                  ),
                  SummaryCard(
                    title: 'Protein',
                    value: '${todayRecord.protein.toInt()}/110g',
                    icon: Icons.fitness_center,
                    color: Colors.orange,
                  ),
                  SummaryCard(
                    title: 'Water',
                    value: '${todayRecord.water.toStringAsFixed(1)}/3L',
                    icon: Icons.water_drop,
                    color: Colors.blue,
                  ),
                  SummaryCard(
                    title: 'Sleep',
                    value: '${todayRecord.sleep.toStringAsFixed(1)}/8h',
                    icon: Icons.bedtime,
                    color: Colors.deepPurple,
                  ),
                  SummaryCard(
                    title: 'Workout',
                    value: todayRecord.gymDone ? 'Done' : 'Pending',
                    icon: Icons.sports_gymnastics,
                    color: todayRecord.gymDone ? Colors.green : Colors.red,
                  ),
                  SummaryCard(
                    title: 'Weight',
                    value: '${todayRecord.weight.toStringAsFixed(1)} kg',
                    icon: Icons.monitor_weight,
                    color: Colors.teal,
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
                    child: StatBox(
                      title: 'Streak',
                      value: '${trackerProvider.currentStreak} Days',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: StatBox(
                      title: 'Week %',
                      value: '${weekCompletion.toInt()}%',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: StatBox(
                      title: 'Month %',
                      value: '${monthCompletion.toInt()}%',
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
}
