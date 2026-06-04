import 'package:flutter/material.dart';
import '../models/daily_record.dart';
import '../services/storage_service.dart';

class DailyTrackerProvider extends ChangeNotifier {
  final StorageService _storageService;

  DateTime _selectedDate = DateTime.now();
  DailyRecord? _currentRecord;

  /// Cached streak value — updated on every save and storage change.
  int _currentStreak = 0;

  DailyTrackerProvider(this._storageService) {
    _storageService.addListener(_onStorageUpdate);
    _loadRecordForDate(_selectedDate);
    // Compute initial streak once storage is populated.
    _recalculateStreak();
  }

  // ─── Storage listener ───────────────────────────────────────────────────────

  void _onStorageUpdate() {
    _loadRecordForDate(_selectedDate);
    _recalculateStreak();
    notifyListeners();
  }

  // ─── Getters ────────────────────────────────────────────────────────────────

  DateTime get selectedDate => _selectedDate;
  DailyRecord? get currentRecord => _currentRecord;

  /// Live streak — always up-to-date; no recompute on every build.
  int get currentStreak => _currentStreak;

  /// Kept for backward compatibility — returns the cached value.
  int getCurrentStreak() => _currentStreak;

  // ─── Date navigation ────────────────────────────────────────────────────────

  void setDate(DateTime date) {
    _selectedDate = date;
    _loadRecordForDate(date);
    notifyListeners();
  }

  void _loadRecordForDate(DateTime date) {
    _currentRecord =
        _storageService.getRecord(date) ?? DailyRecord.empty(date);
        
    // Enforce rule: cannot be checked if no items exist.
    if (_currentRecord != null) {
      if (_currentRecord!.preWorkoutEntries.isEmpty) _currentRecord!.preWorkoutDone = false;
      if (_currentRecord!.postWorkoutEntries.isEmpty) _currentRecord!.postWorkoutDone = false;
      if (_currentRecord!.breakfastEntries.isEmpty) _currentRecord!.breakfastDone = false;
      if (_currentRecord!.lunchEntries.isEmpty) _currentRecord!.lunchDone = false;
      if (_currentRecord!.snackEntries.isEmpty) _currentRecord!.snackDone = false;
      if (_currentRecord!.dinnerEntries.isEmpty) _currentRecord!.dinnerDone = false;
    }
  }

  // ─── Field update methods ────────────────────────────────────────────────────

  Future<void> updateGymDone(bool done) async {
    if (_currentRecord == null) return;
    _currentRecord!.gymDone = done;
    await _saveCurrentRecord();
  }

  Future<void> updateWater(double water) async {
    if (_currentRecord == null) return;
    _currentRecord!.water = water;
    await _saveCurrentRecord();
  }

  Future<void> updateSleep(double sleep) async {
    if (_currentRecord == null) return;
    _currentRecord!.sleep = sleep;
    await _saveCurrentRecord();
  }

  Future<void> updateWeight(double weight) async {
    if (_currentRecord == null) return;
    _currentRecord!.weight = weight;
    await _saveCurrentRecord();
  }

  Future<void> updateMeal(String mealType, bool done) async {
    if (_currentRecord == null) return;
    final entries = _getEntriesForMeal(mealType);
    
    // Enforce rule: cannot be checked if no items exist.
    if (done && entries.isEmpty) {
      done = false;
    }
    
    switch (mealType) {
      case 'preWorkout':
        _currentRecord!.preWorkoutDone = done;
        break;
      case 'postWorkout':
        _currentRecord!.postWorkoutDone = done;
        break;
      case 'breakfast':
        _currentRecord!.breakfastDone = done;
        break;
      case 'lunch':
        _currentRecord!.lunchDone = done;
        break;
      case 'snack':
        _currentRecord!.snackDone = done;
        break;
      case 'dinner':
        _currentRecord!.dinnerDone = done;
        break;
    }
    await _saveCurrentRecord();
  }

  List<MealEntry> _getEntriesForMeal(String mealType) {
    if (_currentRecord == null) return [];
    switch (mealType) {
      case 'preWorkout': return _currentRecord!.preWorkoutEntries;
      case 'postWorkout': return _currentRecord!.postWorkoutEntries;
      case 'breakfast': return _currentRecord!.breakfastEntries;
      case 'lunch': return _currentRecord!.lunchEntries;
      case 'snack': return _currentRecord!.snackEntries;
      case 'dinner': return _currentRecord!.dinnerEntries;
      default: return [];
    }
  }

  Future<void> addFoodToMeal(String mealType, MealEntry entry) async {
    if (_currentRecord == null) return;
    final entries = _getEntriesForMeal(mealType);
    
    // Check if food already exists (aggregate)
    final existingIndex = entries.indexWhere((e) => e.name == entry.name && e.unit == entry.unit);
    if (existingIndex != -1) {
      final existing = entries[existingIndex];
      entries[existingIndex] = MealEntry(
        name: existing.name,
        quantity: existing.quantity + entry.quantity,
        unit: existing.unit,
        calories: existing.calories + entry.calories,
        protein: existing.protein + entry.protein,
        carbs: existing.carbs + entry.carbs,
        fats: existing.fats + entry.fats,
      );
    } else {
      entries.add(entry);
    }
    
    await _saveCurrentRecord();
  }

  Future<void> removeFoodFromMeal(String mealType, int index) async {
    if (_currentRecord == null) return;
    final entries = _getEntriesForMeal(mealType);
    if (index >= 0 && index < entries.length) {
      entries.removeAt(index);
      
      if (entries.isEmpty) {
        switch (mealType) {
          case 'preWorkout': _currentRecord!.preWorkoutDone = false; break;
          case 'postWorkout': _currentRecord!.postWorkoutDone = false; break;
          case 'breakfast': _currentRecord!.breakfastDone = false; break;
          case 'lunch': _currentRecord!.lunchDone = false; break;
          case 'snack': _currentRecord!.snackDone = false; break;
          case 'dinner': _currentRecord!.dinnerDone = false; break;
        }
      }
      
      await _saveCurrentRecord();
    }
  }

  Future<void> resetCurrentDay() async {
    _currentRecord = DailyRecord.empty(_selectedDate);
    await _saveCurrentRecord();
  }

  // ─── Save ────────────────────────────────────────────────────────────────────

  Future<void> _saveCurrentRecord() async {
    if (_currentRecord == null) return;
    
    // Auto-calculate macros
    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFats = 0;
    
    void addMacros(List<MealEntry> entries) {
      for (var entry in entries) {
        totalCalories += entry.calories;
        totalProtein += entry.protein;
        totalCarbs += entry.carbs;
        totalFats += entry.fats;
      }
    }
    
    addMacros(_currentRecord!.preWorkoutEntries);
    addMacros(_currentRecord!.postWorkoutEntries);
    addMacros(_currentRecord!.breakfastEntries);
    addMacros(_currentRecord!.lunchEntries);
    addMacros(_currentRecord!.snackEntries);
    addMacros(_currentRecord!.dinnerEntries);
    
    _currentRecord!.totalCalories = totalCalories;
    _currentRecord!.protein = totalProtein;
    _currentRecord!.totalCarbs = totalCarbs;
    _currentRecord!.totalFats = totalFats;

    _currentRecord!.calculateScore();
    await _storageService.saveRecord(_currentRecord!);
    // Streak is recalculated here synchronously so the next notifyListeners
    // already carries the updated value.
    _recalculateStreak();
    notifyListeners();
  }

  // ─── Streak calculation ──────────────────────────────────────────────────────

  /// Recomputes [_currentStreak] and caches the result.
  ///
  /// Strategy
  /// ────────
  /// 1. All dates are normalised to midnight (year/month/day only) so that
  ///    time-of-day never causes a key mismatch.
  /// 2. If today already has a qualifying record (≥ 50% completion) the loop
  ///    starts from today — today counts in the streak.
  /// 3. If today does NOT yet qualify the loop starts from yesterday.
  ///    This preserves the historical streak during the morning window before
  ///    the user has logged enough for today, instead of incorrectly showing 0.
  /// 4. Edge cases handled:
  ///    • First ever entry  → streak = 1 once day qualifies.
  ///    • Missing day       → loop breaks, streak stops growing.
  ///    • Multiple saves    → idempotent; recomputing always gives same result.
  void _recalculateStreak() {
    final now = DateTime.now();
    // Normalize today to midnight.
    final today = DateTime(now.year, now.month, now.day);

    final todayRecord = _storageService.getRecord(today);
    final todayQualifies =
        todayRecord != null && todayRecord.completionPercentage >= 50.0;

    debugPrint(
      '[Streak] Today (${StorageService.formatDateKey(today)}) qualifies: '
      '$todayQualifies '
      '(completion: ${todayRecord?.completionPercentage.toStringAsFixed(1) ?? "—"}%)',
    );

    // Start from today if it qualifies; otherwise from yesterday so we don't
    // wipe out the historical streak before the user has logged enough today.
    DateTime dateToCheck =
        todayQualifies ? today : today.subtract(const Duration(days: 1));

    int streak = 0;

    while (true) {
      // Always use a normalised date for the lookup.
      final normalised = DateTime(
        dateToCheck.year,
        dateToCheck.month,
        dateToCheck.day,
      );
      final record = _storageService.getRecord(normalised);
      final qualifies =
          record != null && record.completionPercentage >= 50.0;

      debugPrint(
        '[Streak]   ${StorageService.formatDateKey(normalised)} → '
        'found=${record != null}, '
        'completion=${record?.completionPercentage.toStringAsFixed(1) ?? "—"}%, '
        'qualifies=$qualifies',
      );

      if (qualifies) {
        streak++;
        dateToCheck = normalised.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    debugPrint('[Streak] Result: $_currentStreak → $streak days');
    _currentStreak = streak;
  }
}
