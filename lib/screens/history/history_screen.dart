import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../services/storage_service.dart';
import '../../models/daily_record.dart';
import '../../widgets/glass_container.dart';
import 'widgets/detail_row.dart';
import 'widgets/meals_history_row.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _focusedDay = ValueNotifier<DateTime>(DateTime.now());
  final _selectedDay = ValueNotifier<DateTime?>(null);
  final _recordsMap = ValueNotifier<Map<DateTime, DailyRecord>>({});

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

    _recordsMap.value = newMap;
  }

  DailyRecord? _getRecordForDay(DateTime day) {
    final normalizedDate = DateTime(day.year, day.month, day.day);
    return _recordsMap.value[normalizedDate];
  }

  @override
  void dispose() {
    _focusedDay.dispose();
    _selectedDay.dispose();
    _recordsMap.dispose();
    super.dispose();
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
                  DetailRow(
                    icon: Icons.score, 
                    title: 'Completion Score', 
                    value: '${record.completionPercentage.toInt()}%${record.completionPercentage >= 100 ? ' 🔥' : ''}', 
                    color: Colors.tealAccent
                  ),
                  const SizedBox(height: 12),
                  DetailRow(icon: Icons.fitness_center, title: 'Protein', value: '${record.protein.toInt()}g', color: Colors.orange),
                  const SizedBox(height: 12),
                  DetailRow(icon: Icons.water_drop, title: 'Water', value: '${record.water.toStringAsFixed(1)}L', color: Colors.blue),
                  const SizedBox(height: 12),
                  DetailRow(icon: Icons.bedtime, title: 'Sleep', value: '${record.sleep.toStringAsFixed(1)}h', color: Colors.deepPurple),
                  const SizedBox(height: 12),
                  DetailRow(icon: Icons.sports_gymnastics, title: 'Workout', value: record.gymDone ? 'Completed' : 'Skipped', color: record.gymDone ? Colors.green : Colors.red),
                  const SizedBox(height: 12),
                  DetailRow(icon: Icons.monitor_weight, title: 'Weight', value: '${record.weight.toStringAsFixed(1)} kg', color: Colors.grey),
                  const SizedBox(height: 12),
                  MealsHistoryRow(record: record),
                ],
              ),
            ),
          ),
        );
      },
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
            child: ListenableBuilder(
              listenable: Listenable.merge([_focusedDay, _selectedDay, _recordsMap]),
              builder: (context, _) {
                return TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay.value,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay.value, day),
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
                _selectedDay.value = selectedDay;
                _focusedDay.value = focusedDay;
                
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
            );
          },
        ),
      ),
    ),
  ),
);
  }
}
