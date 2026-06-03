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
  }

  // ─── Field update methods ────────────────────────────────────────────────────

  Future<void> updateGymDone(bool done) async {
    if (_currentRecord == null) return;
    _currentRecord!.gymDone = done;
    await _saveCurrentRecord();
  }

  Future<void> updateProtein(double protein) async {
    if (_currentRecord == null) return;
    _currentRecord!.protein = protein;
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

  Future<void> updateMealFood(String mealType, String food) async {
    if (_currentRecord == null) return;
    switch (mealType) {
      case 'preWorkout':
        _currentRecord!.preWorkoutFood = food;
        break;
      case 'postWorkout':
        _currentRecord!.postWorkoutFood = food;
        break;
      case 'breakfast':
        _currentRecord!.breakfastFood = food;
        break;
      case 'lunch':
        _currentRecord!.lunchFood = food;
        break;
      case 'snack':
        _currentRecord!.snackFood = food;
        break;
      case 'dinner':
        _currentRecord!.dinnerFood = food;
        break;
    }
    await _saveCurrentRecord();
  }

  // ─── Save ────────────────────────────────────────────────────────────────────

  Future<void> _saveCurrentRecord() async {
    if (_currentRecord == null) return;
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
