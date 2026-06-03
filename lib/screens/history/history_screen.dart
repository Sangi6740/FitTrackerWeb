import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../services/storage_service.dart';
import '../../models/daily_record.dart';
import '../../widgets/glass_container.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, DailyRecord> _recordsMap = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData();
  }

  void _loadData() {
    final storage = context.read<StorageService>();
    final allRecords = storage.getAllRecords();

    Map<DateTime, DailyRecord> newMap = {};
    for (var r in allRecords) {
      final normalizedDate = DateTime(r.date.year, r.date.month, r.date.day);
      newMap[normalizedDate] = r;
    }

    setState(() {
      _recordsMap = newMap;
    });
  }

  DailyRecord? _getRecordForDay(DateTime day) {
    final normalizedDate = DateTime(day.year, day.month, day.day);
    return _recordsMap[normalizedDate];
  }

  void _showDayDetails(BuildContext context, DailyRecord record) {
    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          DateFormat('EEEE, MMMM d, yyyy').format(record.date),
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    Icons.score, 
                    'Completion Score', 
                    '${record.completionPercentage.toInt()}%${record.completionPercentage >= 100 ? ' 🔥' : ''}', 
                    Colors.tealAccent
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(Icons.fitness_center, 'Protein', '${record.protein.toInt()}g', Colors.orange),
                  const SizedBox(height: 12),
                  _buildDetailRow(Icons.water_drop, 'Water', '${record.water.toStringAsFixed(1)}L', Colors.blue),
                  const SizedBox(height: 12),
                  _buildDetailRow(Icons.bedtime, 'Sleep', '${record.sleep.toStringAsFixed(1)}h', Colors.deepPurple),
                  const SizedBox(height: 12),
                  _buildDetailRow(Icons.sports_gymnastics, 'Workout', record.gymDone ? 'Completed' : 'Skipped', record.gymDone ? Colors.green : Colors.red),
                  const SizedBox(height: 12),
                  _buildDetailRow(Icons.monitor_weight, 'Weight', '${record.weight.toStringAsFixed(1)} kg', Colors.grey),
                  const SizedBox(height: 12),
                  _buildMealsHistoryRow(record),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMealsHistoryRow(DailyRecord record) {
    int mealsDone = 0;
    List<Widget> foodRows = [];

    void addFoodRow(String title, bool done, String food) {
      if (done) {
        mealsDone++;
        if (food.isNotEmpty) {
          foodRows.add(Padding(
            padding: const EdgeInsets.only(top: 4, left: 36),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(color: Colors.white70)),
                Text('$title: ', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
                Expanded(child: Text(food, style: const TextStyle(color: Colors.white))),
              ],
            ),
          ));
        }
      }
    }

    addFoodRow('Pre-Workout', record.preWorkoutDone, record.preWorkoutFood);
    addFoodRow('Post-Workout', record.postWorkoutDone, record.postWorkoutFood);
    addFoodRow('Breakfast', record.breakfastDone, record.breakfastFood);
    addFoodRow('Lunch', record.lunchDone, record.lunchFood);
    addFoodRow('Snack', record.snackDone, record.snackFood);
    addFoodRow('Dinner', record.dinnerDone, record.dinnerFood);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow(
          Icons.restaurant, 
          'Meals Logged', 
          '$mealsDone/6', 
          mealsDone == 6 ? Colors.orangeAccent : Colors.white54
        ),
        if (foodRows.isNotEmpty) ...foodRows,
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value, Color color) {
    return GlassContainer(
      padding: const EdgeInsets.all(12),
      borderRadius: 12,
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(fontSize: 16, color: Colors.white70)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Streak Calendar'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          child: GlassContainer(
            padding: const EdgeInsets.all(8),
            borderRadius: 24,
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarFormat: CalendarFormat.month,
              availableCalendarFormats: const {CalendarFormat.month: 'Month'},
              startingDayOfWeek: StartingDayOfWeek.monday,
              headerStyle: HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
                titleTextStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                leftChevronIcon: const Icon(Icons.chevron_left, color: Colors.white),
                rightChevronIcon: const Icon(Icons.chevron_right, color: Colors.white),
              ),
              calendarStyle: CalendarStyle(
                defaultTextStyle: const TextStyle(color: Colors.white),
                weekendTextStyle: const TextStyle(color: Colors.white70),
                outsideDaysVisible: false,
                todayDecoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                  color: Colors.teal,
                  shape: BoxShape.circle,
                ),
              ),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                
                final record = _getRecordForDay(selectedDay);
                if (record != null) {
                  _showDayDetails(context, record);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No data recorded for this date.')),
                  );
                }
              },
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  final record = _getRecordForDay(date);
                  if (record != null && record.completionPercentage >= 50.0) {
                    if (record.completionPercentage >= 100.0) {
                      return const Positioned(
                        right: 2,
                        bottom: 2,
                        child: Text('🔥', style: TextStyle(fontSize: 14)),
                      );
                    }
                    return Positioned(
                      bottom: 4,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: record.completionPercentage >= 80 ? Colors.tealAccent : Colors.amber,
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  }
                  return null;
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
