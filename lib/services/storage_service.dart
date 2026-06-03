import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/daily_record.dart';

import 'dart:async';

class StorageService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  final Map<String, DailyRecord> _recordsMap = {};
  bool _isLoading = false;
  StreamSubscription<QuerySnapshot>? _recordsSubscription;

  bool get isLoading => _isLoading;

  Future<void> init() async {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _listenToRecordsFromFirestore();
      } else {
        _recordsSubscription?.cancel();
        _recordsMap.clear();
        notifyListeners();
      }
    });
  }

  void _listenToRecordsFromFirestore() {
    final user = _auth.currentUser;
    if (user == null) return;
    
    _isLoading = true;
    notifyListeners();
    
    _recordsSubscription?.cancel();
    _recordsSubscription = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('records')
        .snapshots()
        .listen(
      (snapshot) {
        _recordsMap.clear();
        for (var doc in snapshot.docs) {
          final record = DailyRecord.fromJson(doc.data());
          final key = formatDateKey(record.date);
          _recordsMap[key] = record;
        }
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        debugPrint('Error loading records: $e');
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> saveRecord(DailyRecord record) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final key = formatDateKey(record.date);
    _recordsMap[key] = record;
    notifyListeners(); // Notify app that local state changed

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('records')
          .doc(key)
          .set(record.toJson());
    } catch (e) {
      debugPrint('Error saving record: $e');
    }
  }

  DailyRecord? getRecord(DateTime date) {
    final key = formatDateKey(date);
    return _recordsMap[key];
  }

  List<DailyRecord> getAllRecords() {
    return _recordsMap.values.toList();
  }

  List<String> getCustomFoods(List<String> presets) {
    final Set<String> custom = {};
    
    String formatTitleCase(String text) {
      if (text.isEmpty) return text;
      return text.trim().split(' ').map((word) {
        if (word.isEmpty) return word;
        return word[0].toUpperCase() + word.substring(1).toLowerCase();
      }).join(' ');
    }

    void check(String food) {
      if (food.isNotEmpty && food != 'Custom...') {
        final formatted = formatTitleCase(food);
        if (!presets.contains(formatted) && !presets.contains(food)) {
          custom.add(formatted);
        }
      }
    }
    
    for (var record in _recordsMap.values) {
      check(record.preWorkoutFood);
      check(record.postWorkoutFood);
      check(record.breakfastFood);
      check(record.lunchFood);
      check(record.snackFood);
      check(record.dinnerFood);
    }
    return custom.toList()..sort();
  }

  static String formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> clearAll() async {
    _recordsMap.clear();
    notifyListeners();
  }
}
