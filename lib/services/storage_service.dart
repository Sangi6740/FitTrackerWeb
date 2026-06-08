import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/daily_record.dart';
import '../models/food_item.dart';

import 'dart:async';

class StorageService extends ChangeNotifier {
  static final List<FoodItem> staticFoods = [
    FoodItem(
      id: 'static_2',
      name: 'Boiled Egg',
      calories: 78,
      protein: 6.3,
      carbs: 0.6,
      fats: 5.3,
      unit: 'egg',
    ),
    FoodItem(
      id: 'static_3',
      name: 'Fish',
      calories: 206,
      protein: 22,
      carbs: 0,
      fats: 12,
      unit: 'serving (100g)',
    ),
    FoodItem(
      id: 'static_5',
      name: 'Rice',
      calories: 205,
      protein: 4.3,
      carbs: 45,
      fats: 0.4,
      unit: 'cup',
    ),
    FoodItem(
      id: 'static_6',
      name: 'Oats',
      calories: 195,
      protein: 8.5,
      carbs: 34,
      fats: 3.5,
      unit: 'serving (50g)',
    ),
    FoodItem(
      id: 'static_7',
      name: 'Milk',
      calories: 150,
      protein: 8,
      carbs: 12,
      fats: 8,
      unit: 'glass',
    ),
    FoodItem(
      id: 'static_8',
      name: 'Banana',
      calories: 105,
      protein: 1.3,
      carbs: 27,
      fats: 0.4,
      unit: 'banana',
    ),
    FoodItem(
      id: 'static_9',
      name: 'Paneer',
      calories: 265,
      protein: 18,
      carbs: 1.2,
      fats: 20,
      unit: 'serving (100g)',
    ),
    FoodItem(
      id: 'static_10',
      name: 'Chicken',
      calories: 165,
      protein: 31,
      carbs: 0,
      fats: 3.6,
      unit: 'serving (100g)',
    ),
  ];
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
      return text
          .trim()
          .split(' ')
          .map((word) {
            if (word.isEmpty) return word;
            return word[0].toUpperCase() + word.substring(1).toLowerCase();
          })
          .join(' ');
    }

    void check(String food) {
      if (food.isNotEmpty && food != 'Custom...') {
        final formatted = formatTitleCase(food);
        if (!presets.contains(formatted) && !presets.contains(food)) {
          custom.add(formatted);
        }
      }
    }

    void checkEntries(List<MealEntry> entries) {
      for (var e in entries) {
        check(e.name);
      }
    }

    for (var record in _recordsMap.values) {
      checkEntries(record.preWorkoutEntries);
      checkEntries(record.postWorkoutEntries);
      checkEntries(record.breakfastEntries);
      checkEntries(record.lunchEntries);
      checkEntries(record.snackEntries);
      checkEntries(record.dinnerEntries);
    }
    return custom.toList()..sort();
  }

  Future<List<FoodItem>> getAllFoods() async {
    List<FoodItem> customFoods = [];
    try {
      final snapshot = await _firestore.collection('foods').get();
      customFoods = snapshot.docs
          .map((doc) => FoodItem.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error fetching custom foods: $e');
    }

    // Combine static and custom foods
    return [...staticFoods, ...customFoods];
  }

  Future<void> addFoodToDatabase(FoodItem food) async {
    try {
      final docRef = _firestore.collection('foods').doc();
      final data = food.toJson();
      // Add lowercase name for searching
      data['name_lower'] = food.name.toLowerCase();
      await docRef.set(data);
    } catch (e) {
      debugPrint('Error adding food: $e');
    }
  }

  static String formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> clearAll() async {
    _recordsMap.clear();
    notifyListeners();
  }
}
