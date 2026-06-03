import 'package:flutter/material.dart';
import '../models/daily_record.dart';
import '../services/storage_service.dart';

class AnalyticsProvider extends ChangeNotifier {
  final StorageService _storageService;

  AnalyticsProvider(this._storageService) {
    _storageService.addListener(() {
      notifyListeners();
    });
  }

  List<DailyRecord> getRecordsForDateRange(DateTime start, DateTime end) {
    final allRecords = _storageService.getAllRecords();
    return allRecords.where((record) {
      // Normalize dates to remove time parts
      final recordDate = DateTime(record.date.year, record.date.month, record.date.day);
      final startDate = DateTime(start.year, start.month, start.day);
      final endDate = DateTime(end.year, end.month, end.day);
      
      return (recordDate.isAtSameMomentAs(startDate) || recordDate.isAfter(startDate)) &&
             (recordDate.isAtSameMomentAs(endDate) || recordDate.isBefore(endDate));
    }).toList();
  }

  List<DailyRecord> getCurrentWeekRecords() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    return getRecordsForDateRange(startOfWeek, now);
  }

  List<DailyRecord> getCurrentMonthRecords() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    return getRecordsForDateRange(startOfMonth, now);
  }

  double getAverageProtein(List<DailyRecord> records) {
    if (records.isEmpty) return 0;
    final total = records.fold(0.0, (sum, record) => sum + record.protein);
    return total / records.length;
  }

  double getAverageWater(List<DailyRecord> records) {
    if (records.isEmpty) return 0;
    final total = records.fold(0.0, (sum, record) => sum + record.water);
    return total / records.length;
  }

  double getAverageSleep(List<DailyRecord> records) {
    if (records.isEmpty) return 0;
    final total = records.fold(0.0, (sum, record) => sum + record.sleep);
    return total / records.length;
  }

  int getWorkoutConsistency(List<DailyRecord> records) {
    return records.where((record) => record.gymDone).length;
  }

  int getLongestStreak(List<DailyRecord> records) {
    if (records.isEmpty) return 0;
    
    final sorted = List<DailyRecord>.from(records)
      ..sort((a, b) => a.date.compareTo(b.date));
    
    int maxStreak = 0;
    int currentStreak = 0;
    DateTime? prevDate;
    
    for (var record in sorted) {
      if (record.completionPercentage >= 50.0) { // Using 50% as the threshold for a 'streak'
        final normalizedDate = DateTime(record.date.year, record.date.month, record.date.day);
        
        if (prevDate == null) {
          currentStreak = 1;
        } else {
          final diff = normalizedDate.difference(prevDate).inDays;
          if (diff == 1) {
            currentStreak++;
          } else if (diff > 1) {
            currentStreak = 1;
          }
        }
        
        if (currentStreak > maxStreak) {
          maxStreak = currentStreak;
        }
        prevDate = normalizedDate;
      } else {
        currentStreak = 0;
      }
    }
    return maxStreak;
  }
}
